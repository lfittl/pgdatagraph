# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pgdatagraph/version'

Gem::Specification.new do |s|
  s.name        = "pgdatagraph"
  s.version     = Pgdatagraph::VERSION
  s.authors     = ["Philipp Markovics"]
  s.email       = ["team@pganalyze.com"]
  s.homepage    = "http://pganalyze.com"
  s.summary     = "D3/Rickshaw based chart library"
  s.description = "Nice charts for pganalyze."
  s.license     = "Commercial"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "railties", ">= 3.0", "< 5.0"
  s.add_dependency "coffee-rails", ">= 3.2.1"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end