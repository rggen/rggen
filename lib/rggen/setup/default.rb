# frozen_string_literal: true

require 'rggen/systemverilog'
require 'rggen/built_in'
require 'rggen/spreadsheet_loader'

RgGen.enable :global, [:data_width, :address_width]

RgGen.enable :register_block, [:name, :byte_size, :protocol]
RgGen.enable :register_block, :protocol, [:apb, :axi4lite]

RgGen.enable :register, [:name, :offset_address, :size, :type]
RgGen.enable :register, :type, [:external, :indirect]

RgGen.enable :bit_field, [
  :name, :bit_assignment, :type, :initial_value, :reference, :comment
]
RgGen.enable :bit_field, :type, [
  :rc, :reserved, :ro, :rs, :rw, :rwe, :rwl, :w0c, :w1c, :w0s, :w1s
]
