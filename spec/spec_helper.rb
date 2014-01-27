require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

module UnboundHelper
  require 'pathname'
  SPEC_ROOT = Pathname.new(__FILE__).dirname.expand_path
  PROJECT_ROOT =  (SPEC_ROOT + '../').expand_path
  CONF_ROOT = SPEC_ROOT + 'conf'
  def self.config_file(name)
    (CONF_ROOT + name).to_s
  end
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


