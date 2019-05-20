# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :bit_assignment) do
  register_map do
    property :lsb, body: ->(index = 0) { msb_lsb_bit(index, @lsb) }
    property :msb, body: ->(index = 0) { msb_lsb_bit(index, @lsb + width - 1) }
    property :width, body: -> { @width || 1 }
    property :sequence_size
    property :step, body: -> { @step || width }
    property :sequential?, body: -> { !@sequence_size.nil? }
    property :bit_map, body: -> { @bit_map ||= calc_bit_map }

    ignore_empty_value false
    input_pattern /#{integer}(?::#{integer}){0,3}/,
                  match_automatically: false

    build do |value|
      input_value = preprocess(value)
      @lsb, @width, @sequence_size, @step =
        KEYS.map { |key| parse_value(input_value, key) }
    end

    verify(:feature) do
      error_condition { !@lsb }
      message { 'no lsb is given' }
    end

    verify(:feature) do
      error_condition { lsb.negative? }
      message { "lsb is less than 0: #{lsb}" }
    end

    verify(:feature) do
      error_condition { width < 1 }
      message { "width is less than 1: #{width}" }
    end

    verify(:feature) do
      error_condition { sequential? && sequence_size < 1 }
      message { "sequence size is less than 1: #{sequence_size}" }
    end

    verify(:feature) do
      error_condition { sequential? && step < 1 }
      message { "step is less than 1: #{step}" }
    end

    verify(:feature) do
      error_condition { overlap? }
      message { 'overlap with existing bit field(s)' }
    end

    private

    KEYS = [:lsb, :width, :sequence_size, :step].freeze

    def preprocess(value)
      if value.is_a?(Hash)
        value
      elsif match_pattern(value)
        split_match_data(match_data)
      else
        error "invalid input value for bit assignment: #{value.inspect}"
      end
    end

    def split_match_data(match_data)
      match_data[0]
        .split(':')
        .map.with_index { |value, i| [KEYS[i], value] }
        .to_h
    end

    def parse_value(input_value, key)
      (input_value.key?(key) && Integer(input_value[key])) || nil
    rescue ArgumentError, TypeError
      error "cannot convert #{input_value[key].inspect} into " \
            "bit assignment(#{key.to_s.tr('_', ' ')})"
    end

    def msb_lsb_bit(index, base)
      index = 0 unless sequential?
      calc_bit_position(index, base)
    end

    def calc_bit_position(index, base)
      if index.is_a?(Integer)
        step * index + base
      else
        "#{step}*#{index}+#{base}"
      end
    end

    def calc_bit_map
      Array.new(sequence_size || 1) { |i| (2**width - 1) << lsb(i) }.inject(:|)
    end

    def overlap?
      register
        .bit_fields
        .any? { |bit_field| (bit_field.bit_map & bit_map).positive? }
    end
  end
end
