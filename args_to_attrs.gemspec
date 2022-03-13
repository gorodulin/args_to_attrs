require_relative "lib/args_to_attrs/version"

Gem::Specification.new do |spec|
  spec.name          = "args_to_attrs"
  spec.version       = ArgsToAttrs::VERSION
  spec.authors       = ["Vladimir Gorodulin"]
  spec.email         = ["ru.hostmaster@gmail.com"]
  spec.summary       = %q{Set instance attributes from method arguments}
  spec.description   = %q{Set instance attributes from method arguments}
  spec.homepage      = "https://github.com/gorodulin/args_to_attrs"
  spec.license       = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata = {
    "changelog_uri"     => "https://github.com/gorodulin/args_to_attrs/CHANGELOG.md",
    "homepage_uri"      => spec.homepage,
    "source_code_uri"   => "https://github.com/gorodulin/args_to_attrs",
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin|spec|config|tmp)/}) }
  end

  spec.require_paths = ["lib"]
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
end