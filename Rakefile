require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

begin
  require 'jeweler'
rescue LoadError
else 
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
    gem.name = "unbound"
    gem.homepage = "http://github.com/justfalter/unbound-ruby"
    gem.license = "MIT"
    gem.summary = %Q{Unbound DNS resolver bindings for Ruby}
    gem.description = %Q{Unbound DNS resolver bindings for Ruby}
    gem.email = "falter@gmail.com"
    gem.authors = ["Mike Ryan"]
    gem.files  = Dir.glob("lib/**/*.rb") + 
      Dir.glob("examples/*") + 
      Dir.glob("spec/{*.rb}") + 
      Dir.glob("spec/conf/{*.conf}") + 
      %w(CONTRIBUTING.md CHANGELOG.md LICENSE.txt Gemfile README.md Rakefile VERSION)

  end
  Jeweler::RubygemsDotOrgTasks.new
end

begin
rescue LoadError
else 
  require 'rspec/core'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end
end

task :default => [:spec]
