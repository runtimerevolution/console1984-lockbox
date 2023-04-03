require_relative 'lib/console1984/lockbox/version'

Gem::Specification.new do |spec|
  spec.name          = 'console1984-lockbox'
  spec.version       = Console1984::Lockbox::VERSION
  spec.authors       = ['JcDores', 'runtimerevolution']
  spec.email         = ['j.dores@runtime-revolution.com']

  spec.summary       = 'Inspired in Console1984, this gem extends Console1984 features for Lockbox gem'
  spec.description   = 'Enhances Console1984 gem to include protection for Lockbox encrypted attributes & methods'
  spec.homepage      = 'https://github.com/runtimerevolution/console1986-lockbox'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
    'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'console1984'
  spec.add_dependency 'lockbox'

  spec.add_development_dependency 'rails', '>= 7.0'
  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rubocop', '>= 1.18.4'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-packaging'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'mysql2'
end
