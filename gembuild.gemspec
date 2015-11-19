# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gembuild/version'

Gem::Specification.new do |spec|
  spec.name          = 'gembuild'
  spec.version       = Gembuild::VERSION
  spec.authors       = ['Mario Finelli']
  spec.email         = ['mario@finel.li']

  spec.summary       = %q{Generate PKGBUILDs for ruby gems.}
  spec.description   = %q{Generate PKGBUILDs for ruby gems.}
  spec.homepage      = 'https://github.com/mfinelli/gembuild'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'mechanize'
  spec.add_dependency 'nokogiri'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'mutant-rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'rubycritic'
  spec.add_development_dependency 'ruby-lint'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
end
