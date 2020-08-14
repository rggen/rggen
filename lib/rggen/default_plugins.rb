# frozen_string_literal: true

module RgGen
  DEFAULT_PLUGINS = [
    'rggen/default_register_map/setup',
    'rggen/systemverilog/rtl/setup',
    'rggen/systemverilog/ral/setup',
    'rggen/markdown/setup',
    'rggen/spreadsheet_loader/setup'
  ].freeze
end
