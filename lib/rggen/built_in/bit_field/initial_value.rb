# frozen_string_literal: true

RgGen.define_simple_feature(:bit_field, :initial_value) do
  register_map do
    property :initial_value, default: 0
    property :initial_value?, body: -> { !@initial_value.nil? }

    build do |value|
      @initial_value =
        begin
          Integer(value)
        rescue ArgumentError, TypeError
          error "cannot convert #{value.inspect} into initial value"
        end
    end

    verify(:component) do
      error_condition { option[:require] && !initial_value? }
      message { 'no initial value is given' }
    end

    verify(:component) do
      error_condition { initial_value? && initial_value < min_initial_value }
      message do
        'input initial value is less than minimum initial value: ' \
        "initial value #{initial_value} " \
        "minimum initial value #{min_initial_value}"
      end
    end

    verify(:component) do
      error_condition { initial_value? && initial_value > max_initial_value }
      message do
        'input initial value is greater than maximum initial value: ' \
        "initial value #{initial_value} " \
        "maximum initial value #{max_initial_value}"
      end
    end

    verify(:component) do
      error_condition { initial_value? && !match_valid_condition? }
      message do
        "does not match the valid initial value condition: #{initial_value}"
      end
    end

    private

    def option
      @option ||=
        (bit_field.options && bit_field.options[:initial_value]) || {}
    end

    def min_initial_value
      bit_field.width == 1 ? 0 : -(2**(bit_field.width - 1))
    end

    def max_initial_value
      2**bit_field.width - 1
    end

    def match_valid_condition?
      !option.key?(:valid_condition) ||
        instance_exec(@initial_value, &option[:valid_condition])
    end
  end
end
