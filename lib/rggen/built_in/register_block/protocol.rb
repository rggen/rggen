# frozen_string_literal: true

RgGen.define_list_feature(:register_block, :protocol, shared_context: true) do
  shared_context do
    def feature_registry(registry = nil)
      @registry = registry if registry
      @registry
    end

    def available_protocols
      feature_registry
        .enabled_features(:protocol)
        .select(&method(:valid_protocol?))
    end

    def valid_protocol?(protocol)
      feature_registry.feature?(:protocol, protocol)
    end
  end

  configuration do
    base_feature do
      property :protocol
      build { |protocol| @protocol = protocol }
    end

    default_feature do
    end

    factory do
      convert_value do |value, position|
        protocol = find_protocol(value)
        protocol ||
          (error "unknown protocol: #{value.inspect}", position)
      end

      default_value do |position|
        default_protocol ||
          (error 'no protocols are available', position)
      end

      def select_feature(data)
        target_features[data.value]
      end

      private

      def find_protocol(value)
        available_protocols.find(&value.to_sym.method(:casecmp?))
      end

      def default_protocol
        available_protocols.first
      end

      def available_protocols
        @available_protocols ||= shared_context.available_protocols
      end
    end
  end

  sv_rtl do
    shared_context.feature_registry(registry)
  end
end
