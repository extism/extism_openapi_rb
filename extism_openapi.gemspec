# frozen_string_literal: true

require_relative 'lib/extism_openapi/version'

Gem::Specification.new do |spec|
  spec.name = 'extism_openapi'
  spec.version = ExtismOpenapi::VERSION
  spec.authors = ['Benjamin Eckel']
  spec.email = ['bhelx@simst.im']

  spec.summary = 'no'
  spec.description = 'no'
  spec.homepage = 'https://example.com'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host'] = 'https://example.com'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com'
  spec.metadata['changelog_uri'] = 'https://github.com'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'extism', '1.0.0.pre.rc.5'
  spec.add_dependency 'openapi3_parser', '~> 0.9'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
