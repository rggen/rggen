# frozen_string_literal: true

require 'bundler/setup'
require 'rggen/devtools/spec_helper'

require 'rggen/core'
builder = RgGen::Core::Builder.create
RgGen.builder(builder)

require 'rggen/systemverilog'
require 'rggen/spreadsheet_loader'

require 'support/shared_contexts'

RSpec.configure do |config|
  RgGen::Devtools::SpecHelper.setup(config)
end

require 'rggen/built_in'
