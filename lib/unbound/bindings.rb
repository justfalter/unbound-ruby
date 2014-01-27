require 'ffi'
module Unbound
  module Bindings
    extend FFI::Library

    LIBNAMES = ['unbound', 'libunbound.so', 'libunbound.so.2']
    if ENV['LIBUNBOUND']
      LIBNAMES.unshift(ENV['LIBUNBOUND'])
    end

    ffi_lib LIBNAMES


    typedef :pointer, :mydata
    typedef :pointer, :ub_ctx_ptr
    typedef :pointer, :ub_result_ptr
    typedef :pointer, :ub_result_ptrptr

    callback :ub_callback_t, [:mydata, :int, :ub_result_ptr], :void


    attach_function :ub_ctx_create, [], :ub_ctx_ptr
    attach_function :ub_ctx_delete, [:ub_ctx_ptr], :void

    attach_function :ub_ctx_set_option, [:ub_ctx_ptr, :string, :string], :int
    attach_function :ub_ctx_get_option, [:ub_ctx_ptr, :string, :pointer], :int
    attach_function :ub_ctx_config, [:ub_ctx_ptr, :string], :int

    attach_function :ub_ctx_set_fwd, [:ub_ctx_ptr, :string], :int
    attach_function :ub_ctx_resolvconf, [:ub_ctx_ptr, :string], :int
    attach_function :ub_ctx_hosts, [:ub_ctx_ptr, :string], :int

    attach_function :ub_ctx_add_ta, [:ub_ctx_ptr, :string], :int
    attach_function :ub_ctx_add_ta_file, [:ub_ctx_ptr, :string], :int

    attach_function :ub_ctx_trustedkeys, [:ub_ctx_ptr, :string], :int

    attach_function :ub_ctx_debugout, [:ub_ctx_ptr, :pointer], :int # TODO: FILE pointer
    attach_function :ub_ctx_debuglevel, [:ub_ctx_ptr, :int], :int

    attach_function :ub_ctx_async, [:ub_ctx_ptr, :int], :int

    attach_function :ub_poll, [:ub_ctx_ptr], :int
    attach_function :ub_wait, [:ub_ctx_ptr], :int, :blocking => true
    attach_function :ub_fd, [:ub_ctx_ptr], :int
    attach_function :ub_process, [:ub_ctx_ptr], :int, :blocking => true

    attach_function :ub_resolve,       [:ub_ctx_ptr, :string, :int, :int, :ub_result_ptrptr], :int, :blocking => true
    attach_function :ub_resolve_async, [:ub_ctx_ptr, :string, :int, :int, :mydata, :ub_callback_t, :pointer], :int
    attach_function :ub_cancel, [:ub_ctx_ptr, :int], :int

    attach_function :ub_resolve_free, [:ub_result_ptr], :void
    attach_function :ub_strerror, [:int], :string

    attach_function :ub_ctx_print_local_zones, [:ub_ctx_ptr], :int

    attach_function :ub_ctx_zone_add, [:ub_ctx_ptr, :string, :string], :int
    attach_function :ub_ctx_zone_remove, [:ub_ctx_ptr, :string], :int

    attach_function :ub_ctx_data_add, [:ub_ctx_ptr, :string], :int
    attach_function :ub_ctx_data_remove, [:ub_ctx_ptr, :string], :int

    ## This wasn't added until unbound 1.4.15
    # attach_function :ub_version, [], :string
  end
end
