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
    default_feature do
      property :protocol, body: -> { @host_protocol ||= default_protocol }

      build do |value|
        @host_protocol = find_protocol(value)
      end

      verify(:feature) do
        error_condition { available_protocols.empty? }
        message { 'no protocols are available' }
      end

      private

      def find_protocol(value)
        protocol =
          available_protocols.find(&value.to_sym.method(:casecmp?))
        protocol || (
          error "unknown protocol: #{value.inspect}"
        )
      end

      def available_protocols
        @available_protocols ||= shared_context.available_protocols
      end

      def default_protocol
        available_protocols.first
      end
    end
  end

  sv_rtl do
    shared_context.feature_registry(registry)
  end
end
