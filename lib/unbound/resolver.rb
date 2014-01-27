require 'unbound/bindings'
require 'unbound/result'
require 'unbound/context'

module Unbound
  class Resolver
    def initialize()
      @ctx = Unbound::Context.new
      @ctx.load_config("unbound/etc/unbound.conf")

      cb = Proc.new { |a,b,c| nil }
      self.query("localhost", 1, 1, cb) 
      @ctx.wait()
    end

    def close
      @ctx.close
    end

    def fd
      @ctx.fd
    end

    def process
      @ctx.process
    end

    def cancel(async_id)
      @ctx.cancel_async_query(async_id)
    end

    def query(name, rrtype, rrclass, callback, private_data = nil)
      @ctx.resolve_async(name, rrtype, rrclass, callback, private_data)
    end
  end
end
