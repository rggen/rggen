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

    verify(:all) do
      if initial_value? && initial_value < min_initial_value
        error 'input initial value is less than minimum initial value: ' \
              "initial value #{initial_value} " \
              "minimum initial value #{min_initial_value}"
      end
    end

    verify(:all) do
      if initial_value? && initial_value > max_initial_value
        error 'input initial value is greater than maximum initial value: ' \
              "initial value #{initial_value} " \
              "maximum initial value #{max_initial_value}"
      end
    end

    private

    def min_initial_value
      bit_field.width == 1 ? 0 : -(2**(bit_field.width - 1))
    end

    def max_initial_value
      2**bit_field.width - 1
    end
  end
end
