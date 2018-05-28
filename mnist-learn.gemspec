# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mnist-learn/version'

Gem::Specification.new do |spec|
  spec.name          = "mnist-learn"
  spec.version       = Mnist::VERSION
  spec.authors       = ["Joseph Dayo"]
  spec.email         = ["joseph.dayo@gmail.com"]

  spec.summary       = %q{Utilities for MNIST handwritten digits data}
  spec.description   = %q{Utilities for MNIST handwritten digits data}
  spec.homepage      = "https://github.com/jedld/ruby-mnist"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "awesome_print"
end
