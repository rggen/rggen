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

        def volatile
          @volatility = -> { true }
        end

        def non_volatile
          @volatility = -> { false }
        end

        def volatile?(&block)
          @volatility = block
        end

        attr_reader :volatility

        def need_initial_value(**options)
          @initial_value_options = options.merge(needed: true)
        end

        attr_reader :initial_value_options

        def use_reference(**options)
          @reference_options = options.merge(usable: true)
        end

        attr_reader :reference_options
      end

      property :type
      property :readable?, forward_to_helper: true
      property :writable?, forward_to_helper: true
      property :read_only?, body: -> { readable? && !writable? }
      property :write_only?, body: -> { writable? && !readable? }
      property :reserved?, body: -> { !(readable? || writable?) }
      property :volatile?, forward_to: :volatility

      build { |value| @type = value }

      verify(:component) do
        error_condition { no_initial_value_given? }
        message { 'no initial value is given' }
      end

      verify(:component) do
        error_condition do
          bit_field.initial_value? && not_match_initial_value?
        end
        message do
          "value 0x#{required_initial_value.to_s(16)} is only allowed for " \
          "initial value: 0x#{bit_field.initial_value.to_s(16)}"
        end
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
        helper.initial_value_options&.key?(:needed) &&
          !bit_field.initial_value?
      end

      def not_match_initial_value?
        helper.initial_value_options&.key?(:value) &&
          bit_field.initial_value != required_initial_value
      end

      def required_initial_value
        value = helper.initial_value_options[:value]
        if value.is_a?(Proc)
          instance_exec(&value)
        else
          value
        end
      end

      def no_reference_bit_field_given?
        use_reference? &&
          helper.reference_options[:required] &&
          !bit_field.reference?
      end

      def invalid_reference_width?
        use_reference? &&
          bit_field.reference? &&
          bit_field.reference.width != reference_width
      end

      def use_reference?
        helper.reference_options&.key?(:usable)
      end

      def reference_width
        helper.reference_options[:width] || bit_field.width
      end

      def volatility
        if @volatility.nil?
          @volatility =
            helper.volatility.nil? || instance_exec(&helper.volatility)
        end
        @volatility
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
        types.find(&value.to_sym.method(:casecmp?)) || value
      end

      def select_feature(cell)
        target_features[cell.value]
      end
    end
  end

  sv_rtl do
    base_feature do
      private

      def array_port_format
        configuration.array_port_format
      end

      def full_name
        bit_field.full_name('_')
      end

      def initial_value
        hex(bit_field.initial_value, bit_field.width)
      end

      def mask
        reference_bit_field ||
          hex(2**bit_field.width - 1, bit_field.width)
      end

      def reference_bit_field
        bit_field
          .find_reference(register_block.bit_fields)
          &.value(register.local_index, bit_field.local_index)
      end
    end

    factory do
      def select_feature(_configuration, bit_field)
        target_features[bit_field.type]
      end
    end
  end

  sv_ral do
    base_feature do
      define_helpers do
        attr_setter :access

        def model_name(name = nil, &block)
          @model_name = name || block || @model_name
          @model_name
        end
      end

      export :access
      export :model_name
      export :constructors

      build do
        variable :register, :ral_model, {
          name: bit_field.name,
          data_type: model_name,
          array_size: array_size,
          random: true
        }
      end

      def access
        (helper.access || bit_field.type).to_s.upcase
      end

      def model_name
        if helper.model_name&.is_a?(Proc)
          instance_eval(&helper.model_name)
        else
          helper.model_name || :rggen_ral_field
        end
      end

      def constructors
        (bit_field.sequence_size&.times || [nil]).map do |index|
          macro_call(
            :rggen_ral_create_field_model, arguments(index)
          )
        end
      end

      private

      def array_size
        Array(bit_field.sequence_size)
      end

      def arguments(index)
        [
          ral_model[index], bit_field.lsb(index), bit_field.width,
          access, volatile, reset_value, valid_reset
        ]
      end

      def volatile
        bit_field.volatile? && 1 || 0
      end

      def reset_value
        hex(bit_field.initial_value, bit_field.width)
      end

      def valid_reset
        bit_field.initial_value? && 1 || 0
      end
    end

    default_feature do
    end

    factory do
      def select_feature(_configuration, bit_field)
        target_features[bit_field.type]
      end
    end
  end
end
