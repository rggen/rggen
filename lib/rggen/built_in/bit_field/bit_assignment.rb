# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :bit_assignment) do
  register_map do
    property :lsb, forward_to: :lsb_bit
    property :msb, forward_to: :msb_bit
    property :width, default: 1
    property :sequence_size
    property :step, initial: -> { width }
    property :sequential?, body: -> { !@sequence_size.nil? }
    property :bit_map, initial: -> { calc_bit_map }

    input_pattern /#{integer}(?::#{integer}){0,3}/,
                  match_automatically: false

    build do |value|
      input_value = preprocess(value)
      KEYS.each { |key| parse_value(input_value, key) }
    end

    verify(:feature) do
      error_condition { [@lsb, @width, @sequence_size, @step].none? }
      message { 'no bit assignment is given' }
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

    printable(:bit_assignments) do
      Array.new(@sequence_size || 1) do |i|
        width > 1 && "[#{msb(i)}:#{lsb(i)}]" || "[#{lsb(i)}]"
      end
    end

    private

    KEYS = [:lsb, :width, :sequence_size, :step].freeze

    def preprocess(value)
      if value.is_a?(Hash)
        value
      elsif match_pattern(value)
        split_match_data(match_data)
      else
        error "illegal input value for bit assignment: #{value.inspect}"
      end
    end

    def split_match_data(match_data)
      match_data
        .to_s
        .split(':')
        .map.with_index { |value, i| [KEYS[i], value] }
        .to_h
    end

    def parse_value(input_value, key)
      input_value.key?(key) &&
        instance_variable_set("@#{key}", Integer(input_value[key]))
    rescue ArgumentError, TypeError
      error "cannot convert #{input_value[key].inspect} into " \
            "bit assignment(#{key.to_s.tr('_', ' ')})"
    end

    def lsb_bit(index = 0)
      lsb_msb_bit(index, @lsb)
    end

    def msb_bit(index = 0)
      lsb_msb_bit(index, @lsb + width - 1)
    end

    def lsb_msb_bit(index, base)
      calc_bit_position((sequential? && index) || 0, base)
    end

    def calc_bit_position(index, base)
      if index.is_a?(Integer)
        base + step * index
      else
        "#{base}+#{step}*#{index}"
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
