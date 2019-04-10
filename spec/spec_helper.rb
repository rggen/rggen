# frozen_string_literal: true

require 'bundler/setup'
require 'rggen/devtools/spec_helper'

require 'rggen/core'
builder = RgGen::Core::Builder.create
RgGen.builder(builder)

require 'rggen/systemverilog'
require 'rggen/spreadsheet_loader'

RSpec.configure do |config|
  RgGen::Devtools::SpecHelper.setup(config)
end

require 'rggen'
