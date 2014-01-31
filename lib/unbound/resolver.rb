require 'unbound/bindings'
require 'unbound/result'
require 'unbound/context'

module Unbound
  class Resolver
    def initialize(ctx)
      @ctx = ctx
      @queries = {}
      @resolve_callback_func = FFI::Function.new(
        :void, [:pointer, :int, :pointer], 
        self.method(:resolve_callback))

      @cancel_callback = self.method(:cancel_query_callback).to_proc
      @free_query_callback = self.method(:free_query_callback).to_proc
    end

    def outstanding_queries
      @queries.count
    end

    def outstanding_queries?
      @queries.count > 0
    end

    def resolve_callback(oid_ptr, err, result_ptr)
      return if oid_ptr.nil?
      oid = oid_ptr.address
      query = @queries[oid]
      return if query.nil?

      if err == 0
        query.success!(Unbound::Result.new(result_ptr))
      else 
        # :nocov:
        query.error!(err)
        # :nocov:
      end
    ensure 
      if err == 0
        # Always free the result pointer
        Unbound::Bindings.ub_resolve_free(result_ptr)
      end
    end
    private :resolve_callback

    def free_query_callback(query)
      @queries.delete(query.object_id)
    end
    private :free_query_callback

    # @param [Unbound::Query] query
    def cancel_query_callback(query)
      if query.async_id
        @ctx.cancel_async_query(query.async_id)
      end
    end
    private :cancel_query_callback

    # Cancel all outstanding queries.
    def cancel_all
      @queries.each_value do |query|
        query.timeout!
      end
      @queries.clear
    end

    def closed?
      @ctx.closed?
    end

    # Cancel all queries and close the resolver down.
    def close
      return if self.closed? == true
      self.cancel_all
      @ctx.close
    end

    # @see Unbound::Context#io
    def io
      @ctx.io
    end

    # @see Unbound::Context#process
    def process
      @ctx.process
    end

    # @param [Unbound::Query] query
    def send_query(query)
      if query.started?
        raise QueryAlreadyStarted.new
      end
      @queries[query.object_id] = query
      query.on_timeout(@cancel_callback)
      query.always(@free_query_callback)
      oid_ptr = FFI::Pointer.new query.object_id
      async_id = @ctx.resolve_async(
        query.name, 
        query.rrtype, 
        query.rrclass, 
        @resolve_callback_func, 
        oid_ptr)
      query.start!(async_id)
    end
  end
end
