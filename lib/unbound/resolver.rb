require 'unbound/bindings'
require 'unbound/result'
require 'unbound/context'
require 'unbound/callbacks_mixin'
require 'unbound/query_store'

module Unbound
  # A simple asynchronous resolver
  class Resolver
    include CallbacksMixin

    # @param [Unbound::Context] ctx The context around which we will wrap this
    #  resolver.
    def initialize(ctx)
      @ctx = ctx
      @queries = QueryStore.new
      @resolve_callback_func = FFI::Function.new(
        :void, [:pointer, :int, :pointer], 
        self.method(:resolve_callback))

      init_callbacks

      on_cancel do |query|
        if query.async_id
          @ctx.cancel_async_query(query.async_id)
        end
      end
      on_finish do |query|
        @queries.delete_query(query)
      end
    end

    # @return [Integer] the number of queries for which we are awaiting reply
    def outstanding_queries
      @queries.count
    end

    # @return [Boolean] true if there are any queries for which we are awaiting
    #  reply
    def outstanding_queries?
      @queries.count > 0
    end

    def resolve_callback(oid_ptr, err, result_ptr)
      query = @queries.get_by_pointer(oid_ptr)
      return if query.nil?

      if err == 0
        query.answer!(Unbound::Result.new(result_ptr))
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

    # Cancel all outstanding queries.
    def cancel_all
      @queries.each do |query|
        query.cancel!
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
      # Add all of our callbacks, if any have been registered.
      query.on_start(*@callbacks_start) unless @callbacks_start.empty?
      query.on_answer(*@callbacks_answer) unless @callbacks_answer.empty?
      query.on_error(*@callbacks_error) unless @callbacks_error.empty?
      query.on_cancel(*@callbacks_cancel)
      query.on_finish(*@callbacks_finish)
      ptr = @queries.store(query)
      async_id = @ctx.resolve_async(
        query.name, 
        query.rrtype, 
        query.rrclass, 
        @resolve_callback_func, 
        ptr)
      query.start!(async_id)
    end
  end
end
