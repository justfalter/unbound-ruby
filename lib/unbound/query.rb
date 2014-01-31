require 'unbound/exceptions'
require 'unbound/callbacks_mixin'
module Unbound
  # A representation of a query, as used by Unbound::Resolver
  class Query
    include CallbacksMixin
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
      init_callbacks
    end
    
    # @return [Boolean] whether the query has finished or not
    def finished?
      @state >= STATE_FINISHED
    end
    
    # @return [Boolean] whether the query has been started or not
    def started?
      @state >= STATE_STARTED
    end

    # Called by the resolver just after it has sent the query, and received an
    # asynchronous ID.
    def start!(async_id)
      @state = STATE_STARTED
      @async_id = async_id
      @callbacks_start.call(self)
      @callbacks_start.clear
    end

    # Called by the resolver when it has received an answer
    # @param [Unbound::Result] result The result structure
    def success!(result)
      @callbacks_success.call(self, result)
      finish!()
    end

    # Called by the resolver when it has encountered an internal unbound error
    # @param [Unbound::Bindings::error_codes] error_code 
    def error!(error_code)
      @callbacks_error.call(self, error_code)
      finish!()
    end

    # Called by the resolver after a cancel has occurred.
    def cancel!()
      @callbacks_cancel.call(self)
      finish!()
    end

    private
    def finish!()
      @state = STATE_FINISHED
      @callbacks_finish.call(self)
      clear_callbacks!
    end
  end
end
