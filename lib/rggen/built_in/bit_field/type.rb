# frozen_string_literal: true

RgGen.define_list_feature(:bit_field, :type) do
  register_map do
    base_feature do
      define_helpers do
        def read_write
          @readable = true
          @writable = true
        end

        def read_only
          @readable = true
          @writable = false
        end

        def write_only
          @readable = false
          @writable = true
        end

        def reserved
          @readable = false
          @writable = false
        end

        def readable?
          @readable.nil? || @readable
        end

        def writable?
          @writable.nil? || @writable
        end

        def need_initial_value
          @need_initial_value = true
        end

        def need_initial_value?
          @need_initial_value
        end

        def use_reference(**options)
          @use_reference = true
          @reference_options = options
        end

        def use_reference?
          @use_reference
        end

        attr_reader :reference_options
      end

      property :type
      property :readable?, forward_to_helper: true
      property :writable?, forward_to_helper: true
      property :read_only?, body: -> { readable? && !writable? }
      property :write_only?, body: -> { writable? && !readable? }
      property :reserved?, body: -> { !(readable? || writable?) }

      build { |value| @type = value }

      verify(:component) do
        error_condition { no_initial_value_given? }
        message { 'no initial value is given' }
      end

      verify(:component) do
        error_condition { no_reference_bit_field_given? }
        message { 'no reference bit field is given' }
      end

      verify(:all) do
        error_condition { invalid_reference_width? }
        message do
          "#{reference_width} bit(s) reference bit field is required: " \
          "#{bit_field.reference.full_name} " \
          "#{bit_field.reference.width} bit(s)"
        end
      end

      private

      def no_initial_value_given?
        helper.need_initial_value? && !bit_field.initial_value?
      end

      def no_reference_bit_field_given?
        helper.use_reference? && (
          helper.reference_options[:required] &&
          !bit_field.reference?
        )
      end

      def invalid_reference_width?
        helper.use_reference? && (
          bit_field.reference? &&
          bit_field.reference.width != reference_width
        )
      end

      def reference_width
        helper.reference_options.fetch(:width) { bit_field.width }
      end
    end

    default_feature do
      verify(:feature) do
        error_condition { !type }
        message { 'no bit field type is given' }
      end

      verify(:feature) do
        error_condition { type }
        message { "unknown bit field type: #{type.inspect}" }
      end
    end

    factory do
      convert_value do |value|
        types = target_features.keys
        types.find { |type| type.casecmp?(value.to_sym) } || value
      end

      def select_feature(cell)
        target_features[cell.value]
      end
    end
  end
end
