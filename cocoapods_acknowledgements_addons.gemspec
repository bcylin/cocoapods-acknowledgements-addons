# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "version.rb"

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-acknowledgements-addons"
  spec.version       = CocoaPodsAcknowledgements::AddOns::VERSION
  spec.authors       = "bcylin"
  spec.summary       = %q{A description of cocoapods-acknowledgements-addons.}
  spec.homepage      = "https://github.com/bcylin/cocoapods-acknowledgements-addons"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cocoapods"
  spec.add_dependency "cocoapods-acknowledgements"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
