require_relative 'logic/spec'

Gem::Specification.new do |spec|
  spec.name    = Logic::Spec[:name]
  spec.version = Logic::Spec[:version]
  spec.authors = [Logic::Spec[:author]]

  spec.summary = Logic::Spec[:summary]
  spec.description = Logic::Spec[:description]

  spec.homepage = Logic::Spec[:github]

  spec.license = Logic::Spec[:license]

  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = Logic::Spec[:github]

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end

  spec.require_paths = %w[ports/in/dsl ports/in/shell]
  spec.bindir        = 'ports/in/shell'
  spec.executables   = %w[sweet-moon]

  spec.add_dependency 'ffi', '~> 1.16', '>= 1.16.3'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
