require_relative 'lib/smart_health_cards_test_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'smart_health_cards_test_kit'
  spec.version       = SmartHealthCardsTestKit::VERSION
  spec.authors       = ['Yunwei Wang']
  spec.summary       = 'Smart Health Cards test kit'
  spec.description   = 'Smart Health Cards test kit'
  spec.homepage      = 'https://github.com/inferno-framework/smart-health-cards-test-kit'
  spec.license       = 'Apache-2.0'
  spec.add_runtime_dependency 'inferno_core', '~> 1.0', '>= 1.0.2'
  spec.add_runtime_dependency 'rqrcode'
  spec.add_runtime_dependency 'rqrcode_core', '>= 1.2.0'
  spec.add_development_dependency 'database_cleaner-sequel', '~> 1.8'
  spec.add_development_dependency 'factory_bot', '~> 6.1'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'webmock', '~> 3.11'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.6')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/inferno-framework/smart-health-cards-test-kit'
  spec.metadata['inferno_test_kit'] = 'true'
  spec.files         = `[ -d .git ] && git ls-files -z lib config/presets LICENSE`.split("\x0")

  spec.require_paths = ['lib']
end
