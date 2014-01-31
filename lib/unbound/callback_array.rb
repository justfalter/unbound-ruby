module Unbound
  class CallbackArray < Array
    # Registers one or more callbacks
    # @param [Array<#call>] cbs A splat of procs to register as callbacks
    # @yield [] cb_block A block to register as a callback
    # @raise [ArgumentError] if no callbacks are provided
    def add_callback(*cbs, &cb_block)
      cbs.push(cb_block) unless cb_block.nil?
      raise(ArgumentError.new("Missing callback")) if cbs.empty?
      concat(cbs)
    end

    # Calls each registered callback with the provided arguments
    # @param [Array] args A splat of arguments to pass to each callback via #call
    def call(*args)
      each do |cb|
        cb.call(*args)
      end
    end
  end
end
