lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'version'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-acknowledgements-addons'
  spec.version       = CocoaPodsAcknowledgements::AddOns::VERSION
  spec.authors       = 'bcylin'
  spec.summary       = 'A CocoaPods plugin that adds additional acknowledgements to the plist generated by cocoapods-acknowledgements.'
  spec.homepage      = 'https://github.com/bcylin/cocoapods-acknowledgements-addons'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.0'

  spec.add_dependency 'cocoapods', '>= 0.36'
  spec.add_dependency 'cocoapods-acknowledgements'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
