require 'unbound/bindings'
require 'unbound/exceptions'

module Unbound
  class Context
    def initialize
      @ub_ctx = Unbound::Bindings.ub_ctx_create()
      @raise_on_noid = false
    end

    def raise_on_noid=(b)
      @raise_on_noid = (b == true)
    end

    def raise_on_noid?
      @raise_on_noid
    end

    def check_closed!
      if @ub_ctx.nil?
        raise ContextClosedError.new
      end
    end

    def raise_if_error!(retval)
      return retval if retval == :noerror

      if retval == :noid && @raise_on_noid == false
        return retval
      end
      raise APIError.new(retval)
    end

    def closed?
      @ub_ctx.nil?
    end

    def load_config(filename)
      check_closed!
      raise_if_error!(Unbound::Bindings.ub_ctx_config(@ub_ctx, filename))
    end

    def get_option(varname)
      check_closed!
      ret_ptr = FFI::MemoryPointer.new(:pointer)
      raise_if_error!(Unbound::Bindings.ub_ctx_get_option(@ub_ctx, varname, ret_ptr))
      ret_ptr.read_pointer().read_string()
    end

    def set_option(varname, val)
      check_closed!
      unless varname.end_with?(':')
        varname = varname + ":"
      end
      raise_if_error!(Unbound::Bindings.ub_ctx_set_option(@ub_ctx, varname, val))
    end

    def close
      check_closed!
      Unbound::Bindings.ub_ctx_delete(@ub_ctx)
      @ub_ctx = nil
    end

    def process
      check_closed!
      raise_if_error!(Unbound::Bindings.ub_process(@ub_ctx))
    end

    def cancel_async_query(async_id)
      check_closed!
      raise_if_error!(Unbound::Bindings.ub_cancel(@ub_ctx, async_id))
    end

    # Returns a brand new IO for the file descriptor that can be selected to 
    # determine if processing needs to be done. 
    # Warning: DO NOT CLOSE THIS IO OBJECT! Use Context#close, instead. 
    # @return [FFI::IO] a brand new IO for the context's file descriptor
    def io
      ret = ::FFI::IO.for_fd(self.fd)
      ret.autoclose = false
      return ret
    end

    # Returns the number for the file descriptor.
    def fd
      check_closed!
      Unbound::Bindings.ub_fd(@ub_ctx)
    end

    def resolve(name, rrtype=1, rrclass=1)
      check_closed!
      result_ptr = FFI::MemoryPointer.new :pointer
      raise_if_error!(
        Unbound::Bindings.ub_resolve(
          @ub_ctx, name, rrtype, rrclass, result_ptr))
      ptr = result_ptr.get_pointer(0)
      begin
        Unbound::Result.new(ptr).to_resolv
      ensure
        Unbound::Bindings.ub_resolve_free ptr
      end
    end

    def resolve_async(name, rrtype, rrclass, callback, private_data = nil)
      check_closed!
      async_id_ptr = FFI::MemoryPointer.new :int
      raise_if_error!(
        Unbound::Bindings.ub_resolve_async(
          @ub_ctx, name, rrtype, rrclass, private_data, callback, async_id_ptr))
      return async_id_ptr.get_int(0)
    end
  end
end
