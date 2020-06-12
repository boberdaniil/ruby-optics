# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'pathname'

SPEC_ROOT = Pathname(__FILE__).dirname

begin
  require 'pry'
  require 'pry-byebug'
rescue LoadError
end

$VERBOSE = true

require 'ruby-optics'

RSpec.configure do |config|
  unless RUBY_VERSION >= '2.7'
    config.exclude_pattern = "**/pattern_matching_spec.rb"
  end

  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
end
