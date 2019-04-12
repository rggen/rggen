# frozen_string_literal: true

RSpec.shared_context 'clean-up builder' do
  def disable_all_features(builder)
    categories =
      builder
        .instance_variable_get(:@categories)
        .values
    feature_registries = categories.flat_map do |category|
      category.instance_variable_get(:@feature_registries).values
    end
    feature_registries.each do |registry|
      registry.instance_exec { @enabled_features.clear }
    end
  end

  after(:all) do
    disable_all_features(RgGen.builder)
  end
end

RSpec.shared_context 'configuration common' do
  class ConfigurationDummyLoader < RgGen::Core::Configuration::Loader
    class << self
      def support?(_file)
        true
      end

      attr_accessor :data_block
    end

    def load_file(_file)
      data_block = self.class.data_block
      input_data.__send__(:build_by_block, data_block)
    end
  end

  def build_configuration_factory(builder)
    factory = builder.build_input_component_factory(:configuration)
    factory.loaders([ConfigurationDummyLoader])
    factory
  end

  def create_configuration(&data_block)
    ConfigurationDummyLoader.data_block = data_block || proc {}
    @configuration_factory[0] ||= build_configuration_factory(RgGen.builder)
    @configuration_factory[0].create([''])
  end

  def raise_configuration_error(message, position = nil)
    raise_rggen_error(RgGen::Core::Configuration::ConfigurationError, message, position)
  end

  before(:all) do
    @configuration_factory ||= []
  end
end
