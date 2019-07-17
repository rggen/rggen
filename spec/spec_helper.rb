# frozen_string_literal: true

require 'bundler/setup'

require 'rggen/core'
require 'rggen/devtools/spec_helper'

builder = RgGen::Core::Builder.create
RgGen.builder(builder)

RSpec.configure do |config|
  RgGen::Devtools::SpecHelper.setup(config)
end

RGGEN_ROOT = File.expand_path('..', __dir__)

require 'rggen/systemverilog'
require 'rggen/spreadsheet_loader'
require 'rggen'
