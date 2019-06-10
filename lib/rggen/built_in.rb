# frozen_string_literal: true

require_relative 'built_in/version'

module RgGen
  module BuiltIn
    BUILT_IN_FILES = [
      'built_in/global/address_width',
      'built_in/global/data_width',
      'built_in/register_block/byte_size',
      'built_in/register_block/name',
      'built_in/register_block/protocol',
      'built_in/register_block/protocol/apb',
      'built_in/register/name',
      'built_in/register/offset_address',
      'built_in/register/size',
      'built_in/register/type',
      'built_in/register/type/external',
      'built_in/register/type/indirect',
      'built_in/bit_field/bit_assignment',
      'built_in/bit_field/comment',
      'built_in/bit_field/initial_value',
      'built_in/bit_field/name',
      'built_in/bit_field/reference',
      'built_in/bit_field/type',
      'built_in/bit_field/type/rc',
      'built_in/bit_field/type/reserved',
      'built_in/bit_field/type/ro',
      'built_in/bit_field/type/rs',
      'built_in/bit_field/type/rw',
      'built_in/bit_field/type/rwe_rwl',
      'built_in/bit_field/type/w0c_w1c',
      'built_in/bit_field/type/w0s_w1s'
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
