# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itunes/version'

Gem::Specification.new do |spec|
  spec.name          = "itunes"
  spec.version       = ITunes::VERSION
  spec.authors       = ["JJ Buckley"]
  spec.email         = ["jj@bjjbuckley.com"]
  spec.description   = %q{Ruby CLI/API for controlling iTunes on a Mac}
  spec.summary       = %q{itunes provides a thin Ruby wrapper and command-line client for controlling iTunes on your Mac using Applescripts.}
  spec.homepage      = "http://bjjb.github.io/itunes"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'applescript', '~> 1.0'
  spec.add_runtime_dependency 'commander', '~> 4.1.5'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
