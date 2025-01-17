# frozen_string_literal: true

RgGen.load_plugin 'rggen-default-register-map'
RgGen.load_plugin 'rggen-systemverilog/rtl'
RgGen.load_plugin 'rggen-systemverilog/ral'
RgGen.load_plugin 'rggen-c-header'
RgGen.load_plugin 'rggen-markdown'
RgGen.load_plugin 'rggen-spreadsheet-loader'

RgGen.update_plugin :'rggen-spreadsheet-loader' do |plugin|
  plugin.setup_loader :register_map, :spreadsheet do |entry|
    entry.ignore_value :register_block, :comment
    entry.ignore_value :register, :comment
  end
end
