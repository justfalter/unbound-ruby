require 'ffi'
require 'unbound/result'
module Unbound
  module Bindings
    extend FFI::Library

    LIBNAMES = ['unbound', 'libunbound.so', 'libunbound.so.2']
    if ENV['LIBUNBOUND']
      # :nocov:
      LIBNAMES.unshift(ENV['LIBUNBOUND'])
      # :nocov:
    end

    ffi_lib LIBNAMES

    enum :error_code,
      [
        # /** no error */
        :noerror , 0,
        # /** socket operation. Set to -1, so that if an error from _fd() is
        #  * passed (-1) it gives a socket error. */
        :socket , -1,
        # /** alloc failure */
        :nomem , -2,
        # /** syntax error */
        :syntax , -3,
        # /** DNS service failed */
        :servfail , -4,
        # /** fork() failed */
        :forkfail , -5,
        # /** cfg change after finalize() */
        :afterfinal , -6,
        # /** initialization failed (bad settings) */
        :initfail , -7,
        # /** error in pipe communication with async bg worker */
        :pipe , -8,
        # /** error reading from file (resolv.conf) */
        :readfile , -9,
        # /** error async_id does not exist or result already been delivered */
        :noid , -10
    ]
      
    

    typedef :pointer, :mydata
    typedef :pointer, :ub_ctx_ptr
    typedef :pointer, :ub_result_ptr
    typedef :pointer, :ub_result_ptrptr

    callback :ub_callback_t, [:mydata, :int, :ub_result_ptr], :void


    attach_function :ub_ctx_create, [], :ub_ctx_ptr
    attach_function :ub_ctx_delete, [:ub_ctx_ptr], :void

    attach_function :ub_ctx_set_option, [:ub_ctx_ptr, :string, :string], :error_code
    attach_function :ub_ctx_get_option, [:ub_ctx_ptr, :string, :pointer], :error_code
    attach_function :ub_ctx_config, [:ub_ctx_ptr, :string], :error_code

    attach_function :ub_ctx_set_fwd, [:ub_ctx_ptr, :string], :error_code
    attach_function :ub_ctx_resolvconf, [:ub_ctx_ptr, :string], :error_code
    attach_function :ub_ctx_hosts, [:ub_ctx_ptr, :string], :error_code

    attach_function :ub_ctx_add_ta, [:ub_ctx_ptr, :string], :error_code
    attach_function :ub_ctx_add_ta_file, [:ub_ctx_ptr, :string], :error_code

    attach_function :ub_ctx_trustedkeys, [:ub_ctx_ptr, :string], :error_code

    attach_function :ub_ctx_debugout, [:ub_ctx_ptr, :pointer], :error_code # TODO: FILE pointer
    attach_function :ub_ctx_debuglevel, [:ub_ctx_ptr, :int], :error_code

    attach_function :ub_ctx_async, [:ub_ctx_ptr, :int], :error_code

    attach_function :ub_poll, [:ub_ctx_ptr], :error_code
    attach_function :ub_wait, [:ub_ctx_ptr], :error_code, :blocking => true
    attach_function :ub_fd, [:ub_ctx_ptr], :error_code
    attach_function :ub_process, [:ub_ctx_ptr], :error_code, :blocking => true

    attach_function :ub_resolve,       [:ub_ctx_ptr, :string, :int, :int, :ub_result_ptrptr], :error_code, :blocking => true
    attach_function :ub_resolve_async, [:ub_ctx_ptr, :string, :int, :int, :mydata, :ub_callback_t, :pointer], :error_code
    attach_function :ub_cancel, [:ub_ctx_ptr, :int], :error_code

    attach_function :ub_resolve_free, [:ub_result_ptr], :void
    attach_function :ub_strerror, [:error_code], :string

    attach_function :ub_ctx_print_local_zones, [:ub_ctx_ptr], :error_code

    attach_function :ub_ctx_zone_add, [:ub_ctx_ptr, :string, :string], :error_code
    attach_function :ub_ctx_zone_remove, [:ub_ctx_ptr, :string], :error_code

    attach_function :ub_ctx_data_add, [:ub_ctx_ptr, :string], :error_code
    attach_function :ub_ctx_data_remove, [:ub_ctx_ptr, :string], :error_code

    ## This wasn't added until unbound 1.4.15
    # attach_function :ub_version, [], :string
  end
end
