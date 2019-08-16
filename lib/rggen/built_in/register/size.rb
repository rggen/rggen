# frozen_string_literal: true

RgGen.define_simple_feature(:register, :size) do
  register_map do
    property :size
    property :width, body: -> { @width ||= calc_width }
    property :byte_width, body: -> { width / 8 }
    property :byte_size, body: -> { @byte_size ||= calc_byte_size }
    property :array?, forward_to: :array_register?
    property :array_size, forward_to: :array_registers
    property :count, body: -> { @count ||= calc_count }

    input_pattern [
      /(#{integer}(:?,#{integer})*)/,
      /\[(#{integer}(:?,#{integer})*)\]/
    ], match_automatically: false

    build do |values|
      @size = parse_values(values)
    end

    verify(:feature) do
      error_condition { size && !size.all?(&:positive?) }
      message do
        "non positive value(s) are not allowed for register size: #{size}"
      end
    end

    printable(:array_size) do
      (array_register? || nil) && "[#{array_registers.join(', ')}]"
    end

    private

    def parse_values(values)
      Array(
        values.is_a?(String) && parse_string_values(values) || values
      ).map(&method(:convert_value))
    end

    def parse_string_values(values)
      if match_pattern(values)
        split_match_data(match_data)
      else
        error "illegal input value for register size: #{values.inspect}"
      end
    end

    def split_match_data(match_data)
      match_data.captures.first.split(',')
    end

    def convert_value(value)
      Integer(value)
    rescue ArgumentError, TypeError
      error "cannot convert #{value.inspect} into register size"
    end

    def calc_width
      bus_width = configuration.bus_width
      if register.bit_fields.empty?
        bus_width
      else
        ((max_msb + bus_width) / bus_width) * bus_width
      end
    end

    def max_msb
      register
        .bit_fields
        .map { |bit_field| bit_field.msb((bit_field.sequence_size || 1) - 1) }
        .max
    end

    def calc_byte_size
      if register.settings[:byte_size]
        instance_exec(&register.settings[:byte_size])
      else
        Array(@size).reduce(1, :*) * byte_width
      end
    end

    def array_register?
      register.settings[:support_array] && !@size.nil? || false
    end

    def array_registers
      array_register? && @size || nil
    end

    def calc_count
      Array(array_registers).reduce(1, :*)
    end
  end
end
