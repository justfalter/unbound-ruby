require 'unbound/exceptions'
module Unbound
  # A representation of a query, as used by Unbound::Resolver
  class Query
    attr_reader :name, :rrtype, :rrclass, :async_id

    STATE_INIT = 0
    STATE_STARTED = 1
    STATE_FINISHED = 100

    # @param [String] name
    # @param [Integer] rrtype
    # @param [Integer] rrclass
    def initialize(name, rrtype, rrclass)
      @name = name
      @rrtype = rrtype
      @rrclass = rrclass
      @async_id = nil

      @state = STATE_INIT
      @callbacks_start = []
      @callbacks_success = []
      @callbacks_error = []
      @callbacks_timeout = []
      @callbacks_always = []
    end
    
    # @return [Boolean] whether the query has finished or not
    def finished?
      @state >= STATE_FINISHED
    end
    
    # @return [Boolean] whether the query has been started or not
    def started?
      @state >= STATE_STARTED
    end

    # Adds a callback that will be called just after the query is sent
    # @param [Proc] cb
    def on_start(cb_as_arg = nil, &cb_block)
      cb = cb_as_arg || cb_block || raise(ArgumentError.new("Missing callback"))
      @callbacks_start.push(cb)
    end

    # Adds a callback that will be called when we receive an answer to the query
    # @param [Proc] cb
    def on_success(cb_as_arg = nil, &cb_block)
      cb = cb_as_arg || cb_block || raise(ArgumentError.new("Missing callback"))
      @callbacks_success.push(cb)
    end

    # Adds a callback that will be called when an error internal to unbound occurs
    # @param [Proc] cb
    def on_error(cb_as_arg = nil, &cb_block)
      cb = cb_as_arg || cb_block || raise(ArgumentError.new("Missing callback"))
      @callbacks_error.push(cb)
    end

    # Adds a callback that will be called if the query times out (dependant on 
    # the resolver)
    # @param [Proc] cb
    def on_timeout(cb_as_arg = nil, &cb_block)
      cb = cb_as_arg || cb_block || raise(ArgumentError.new("Missing callback"))
      @callbacks_timeout.push(cb)
    end

    # Adds a callback will *always* be called when the query is finished 
    # whether successfully, in error, or due to timeout.
    # @param [Proc] cb
    def always(cb_as_arg = nil, &cb_block)
      cb = cb_as_arg || cb_block || raise(ArgumentError.new("Missing callback"))
      @callbacks_always.push(cb)
    end

    # Called by the resolver just after it has sent the query, and received an
    # asynchronous ID.
    def start!(async_id)
      @state = STATE_STARTED
      @async_id = async_id
      @callbacks_start.each do |cb|
        cb.call(self)
      end
      @callbacks_start.clear
    end

    # Called by the resolver when it has received an answer
    # @param [Unbound::Result] result The result structure
    def success!(result)
      @callbacks_success.each do |cb|
        cb.call(self, result)
      end
      finish!()
    end

    # Called by the resolver when it has encountered an internal unbound error
    # @param [Unbound::Bindings::error_codes] error_code 
    def error!(error_code)
      @callbacks_error.each do |cb|
        cb.call(self, error_code)
      end
      finish!()
    end

    # Called by the resolver after a timeout has occurred.
    def timeout!()
      @callbacks_timeout.each do |cb|
        cb.call(self)
      end
      finish!()
    end

    private
    def finish!()
      @state = STATE_FINISHED
      @callbacks_success.clear
      @callbacks_error.clear
      @callbacks_timeout.clear

      @callbacks_always.each do |cb|
        cb.call(self)
      end
      @callbacks_always.clear
    end
  end
end
