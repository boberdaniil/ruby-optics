# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ruby-optics'

Gem::Specification.new do |spec|
  spec.name          = 'ruby-optics'
  spec.authors       = ["Daniil Bober"]
  spec.email         = ["cardinal.ximinez.again@gmail.com"]
  spec.license       = 'MIT'
  spec.version       = Optics::VERSION.dup
  spec.homepage      = "https://github.com/boberdaniil/ruby-optics"
  spec.summary       = "Common optics for Ruby"
  spec.description   = spec.summary
  spec.files         = Dir["LICENSE", "README.md", "ruby-optics.gemspec", "lib/**/*"]
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
