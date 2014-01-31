require 'unbound/callback_array'
module Unbound
  module CallbacksMixin
    def init_callbacks
      @callbacks_start = CallbackArray.new
      @callbacks_success = CallbackArray.new
      @callbacks_error = CallbackArray.new
      @callbacks_cancel = CallbackArray.new
      @callbacks_finish = CallbackArray.new
    end
    private :init_callbacks

    def clear_callbacks!
      @callbacks_start.clear
      @callbacks_success.clear
      @callbacks_error.clear
      @callbacks_cancel.clear
      @callbacks_finish.clear
    end
    private :clear_callbacks!

    # Adds a callback that will be called just after the query is sent
    # @param [Proc] cb
    def on_start(*cbs, &cb_block)
      @callbacks_start.add_callback(*cbs, &cb_block)
    end

    # Adds a callback that will be called when we receive an answer to the query
    # @param [Proc] cb
    def on_success(*cbs, &cb_block)
      @callbacks_success.add_callback(*cbs, &cb_block)
    end

    # Adds a callback that will be called when an error internal to unbound occurs
    # @param [Proc] cb
    def on_error(*cbs, &cb_block)
      @callbacks_error.add_callback(*cbs, &cb_block)
    end

    # Adds a callback that will be called if the query times out (dependant on 
    # the resolver)
    # @param [Proc] cb
    def on_cancel(*cbs, &cb_block)
      @callbacks_cancel.add_callback(*cbs, &cb_block)
    end

    # Adds a callback will *always* be called when the query is finished 
    # whether successfully, in error, or due to cancel.
    # @param [Proc] cb
    def on_finish(*cbs, &cb_block)
      @callbacks_finish.add_callback(*cbs, &cb_block)
    end

  end
end
