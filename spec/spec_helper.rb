# frozen_string_literal: true

require 'bundler/setup'

require 'rggen/core'
require 'rggen/devtools/spec_helper'

RSpec.configure do |config|
  RgGen::Devtools::SpecHelper.setup(config)
end

RGGEN_SAMPLE_DIRECTORY =
  ENV['RGGEN_SAMPLE_DIRECTORY'] || '../rggen-sample'
