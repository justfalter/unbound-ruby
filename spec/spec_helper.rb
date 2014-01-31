require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

module UnboundHelper
  require 'pathname'
  SPEC_ROOT = Pathname.new(__FILE__).dirname.expand_path
  PROJECT_ROOT =  (SPEC_ROOT + '../').expand_path
  CONF_ROOT = SPEC_ROOT + 'conf'

  def config_file(name)
    (CONF_ROOT + name).to_s
  end
  module_function :config_file

  def hex2bin(hexstring)
    ret = "\x00" * (hexstring.length / 2)
    ret.force_encoding("BINARY")
    offset = 0
    while offset < hexstring.length
      hex_byte = hexstring[offset..(offset+1)]
      ret.setbyte(offset/2, hex_byte.to_i(16))
      offset += 2
    end
    ret
  end
  module_function :hex2bin
end

require 'simplecov'
SimpleCov.start


SimpleCov.start do
  project_root = RSpec::Core::RubyProject.root
  add_filter UnboundHelper::PROJECT_ROOT.join('spec').to_s
  add_filter UnboundHelper::PROJECT_ROOT.join('.gem').to_s
end 

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'unbound'
