# encoding: utf-8
require File.expand_path('../lib/viadeo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'hashie', '>= 1.1.0'
  gem.add_dependency 'multi_json', '>= 1.0.3'
  gem.add_dependency 'oauth', '>= 0.4.5'
  gem.add_dependency 'curb', '~> 0.8'
  gem.add_dependency 'activesupport', '~> 3.2'
  gem.add_development_dependency 'json', '>= 1.6'
  gem.add_development_dependency 'rake', '>= 0.9'
  gem.add_development_dependency 'rdoc', '>= 3.8'
  gem.add_development_dependency 'rspec', '>= 2.6'
  gem.add_development_dependency 'simplecov', '>= 0.5'
  gem.add_development_dependency 'vcr', '>= 1.10'
  gem.add_development_dependency 'webmock', '>= 1.7'
  gem.authors = ["Gaël Flores", "Yann Hourdel"]
  gem.description = %q{Ruby wrapper for the Viadeo API}
  gem.email = ['']
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'http://github.com/yhourdel/viadeo'
  gem.name = 'viadeo'
  gem.require_paths = ['lib']
  gem.summary = gem.description
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version = Viadeo::VERSION::STRING
end
