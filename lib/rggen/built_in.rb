# frozen_string_literal: true

require 'rggen/systemverilog'
require 'rggen/markdown'
require_relative 'built_in/version'

module RgGen
  module BuiltIn
    BUILT_IN_FILES = [
      'built_in/global/address_width',
      'built_in/global/array_port_format',
      'built_in/global/bus_width',
      'built_in/global/fold_sv_interface_port',
      'built_in/register_block/byte_size',
      'built_in/register_block/markdown',
      'built_in/register_block/name',
      'built_in/register_block/protocol',
      'built_in/register_block/protocol/apb',
      'built_in/register_block/protocol/axi4lite',
      'built_in/register_block/sv_ral_package',
      'built_in/register_block/sv_rtl_top',
      'built_in/register/markdown',
      'built_in/register/name',
      'built_in/register/offset_address',
      'built_in/register/size',
      'built_in/register/sv_rtl_top',
      'built_in/register/type',
      'built_in/register/type/external',
      'built_in/register/type/indirect',
      'built_in/bit_field/bit_assignment',
      'built_in/bit_field/comment',
      'built_in/bit_field/initial_value',
      'built_in/bit_field/markdown',
      'built_in/bit_field/name',
      'built_in/bit_field/reference',
      'built_in/bit_field/sv_rtl_top',
      'built_in/bit_field/type',
      'built_in/bit_field/type/rc_w0c_w1c',
      'built_in/bit_field/type/reserved',
      'built_in/bit_field/type/ro',
      'built_in/bit_field/type/rof',
      'built_in/bit_field/type/rs_w0s_w1s',
      'built_in/bit_field/type/rw_wo',
      'built_in/bit_field/type/rwc_rwe_rwl',
      'built_in/bit_field/type/w0trg_w1trg'
    ].freeze

    def self.load_built_in
      BUILT_IN_FILES.each { |file| require_relative file }
    end

    def self.setup(_builder)
      load_built_in
    end
  end

  setup :'built-in', BuiltIn
end
