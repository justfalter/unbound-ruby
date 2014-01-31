require 'unbound/bindings'

module Unbound
  class Error < StandardError
  end

  # An APIError is the result of a failure in an unbound api call. It expects
  # an error code and translates that into a human-readable string.
  class APIError < Error
    attr_reader :error_code
    def initialize(error_code)
      @error_code = error_code
      msg = Unbound::Bindings.ub_strerror(@error_code)
      super(msg)
    end
  end

  # Indicates that an API call was attempted, but no context was provided.
  class MissingContextError < Error
  end

  # Indicates that the context was closed (for Unbound::Context)
  class ContextClosedError < MissingContextError
  end

  # Indicates that an identical query object has already been submitted.
  class QueryAlreadyStarted < Error
  end

end
