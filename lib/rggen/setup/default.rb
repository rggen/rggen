# frozen_string_literal: true

require 'rggen/built_in'
require 'rggen/spreadsheet_loader'

RgGen.enable :global, [
  :bus_width, :address_width, :array_port_format, :fold_sv_interface_port
]

RgGen.enable :register_block, [:name, :byte_size]
RgGen.enable :register, [:name, :offset_address, :size, :type]
RgGen.enable :register, :type, [:external, :indirect]
RgGen.enable :bit_field, [
  :name, :bit_assignment, :type, :initial_value, :reference, :comment
]
RgGen.enable :bit_field, :type, [
  :rc, :reserved, :ro, :rof, :rs,
  :rw, :rwc, :rwe, :rwl, :w0c, :w1c, :w0s, :w1s,
  :w0trg, :w1trg, :wo
]

RgGen.enable :register_block, [:sv_rtl_top, :protocol]
RgGen.enable :register_block, :protocol, [:apb, :axi4lite]
RgGen.enable :register, [:sv_rtl_top]
RgGen.enable :bit_field, [:sv_rtl_top]

RgGen.enable :register_block, [:sv_ral_package]

RgGen.enable :register_block, [:markdown]
RgGen.enable :register, [:markdown]
