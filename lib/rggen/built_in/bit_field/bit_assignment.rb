# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :bit_assignment) do
  register_map do
    property :lsb, forward_to: :get_lsb
    property :msb, forward_to: :get_msb
    property :width, body: -> { @width || 1 }
    property :sequence_size
    property :step, body: -> { @step || width }
    property :sequential?, body: -> { !@sequence_size.nil? }
    property :bit_map, body: -> { @bit_map ||= calc_bit_map }

    ignore_empty_value false
    input_pattern /#{integer}(?::#{integer}){0,3}/

    build do |values|
      input_values = preprocess(values)
      @lsb, @width, @sequence_size, @step =
        KEYS.map { |key| parse_value(input_values, key) }
    end

    verify(:feature) do
      error 'no lsb is given' unless lsb
    end

    verify(:feature) do
      error "lsb is less than 0: #{lsb}" if lsb.negative?
    end

    verify(:feature) do
      error "width is less than 1: #{width}" if width < 1
    end

    verify(:feature) do
      if sequential? && sequence_size < 1
        error "sequence size is less than 1: #{sequence_size}"
      end
    end

    verify(:feature) do
      error "step is less than 1: #{step}" if sequential? && step < 1
    end

    verify(:feature) do
      error 'overlap with existing bit field(s)' if overlap?
    end

    private

    KEYS = [:lsb, :width, :sequence_size, :step].freeze

    def preprocess(values)
      return split_match_data(match_data) if pattern_matched?
      return values if values.is_a?(Hash)
      error "invalid input value for bit assignment: #{values.inspect}"
    end

    def split_match_data(match_data)
      match_data[0]
        .split(':')
        .map.with_index { |value, i| [KEYS[i], value] }
        .to_h
    end

    def parse_value(input_values, key)
      return unless input_values.key?(key)
      Integer(input_values[key])
    rescue ArgumentError, TypeError
      error "cannot convert #{input_values[key].inspect} into " \
            "bit assignment(#{key.to_s.tr('_', ' ')})"
    end

    def get_lsb(index = nil)
      if index && sequential?
        index.is_a?(Integer) ? step * index + lsb : "#{step}*#{index}+#{lsb}"
      else
        @lsb
      end
    end

    def get_msb(index = nil)
      if index && sequential?
        index.is_a?(Integer) ? step * index + msb : "#{step}*#{index}+#{msb}"
      else
        lsb + width - 1
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
