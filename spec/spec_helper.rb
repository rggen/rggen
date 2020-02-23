# frozen_string_literal: true

require 'bundler/setup'

require 'rggen/core'
require 'rggen/devtools/spec_helper'

RSpec.configure do |config|
  RgGen::Devtools::SpecHelper.setup(
    config,
    coverage_filter: [/rggen-/]
  )
end

RGGEN_SAMPLE_DIRECTORY =
  File.join(
    ENV['RGGEN_ROOT'] || File.expand_path('../..', __dir__),
    'rggen-sample'
  )
