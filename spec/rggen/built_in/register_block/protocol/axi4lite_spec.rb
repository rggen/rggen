# frozen_string_literal: true

RSpec.describe 'register_block/protocol/apb' do
  include_context 'configuration common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:data_width, :address_width])
    RgGen.enable(:register_block, :protocol)
    RgGen.enable(:register_block, :protocol, [:axi4lite])
  end

  describe 'configuration' do
    specify 'プロトコル名は:axi4lite' do
      configuration = create_configuration(protocol: :axi4lite)
      expect(configuration).to have_property(:protocol, :axi4lite)
    end

    specify '32/64ビット以外のデータ幅は未対応' do
      [32, 64].each do |data_width|
        expect {
          create_configuration(data_width: data_width, protocol: :axi4lite)
        }.not_to raise_error
      end

      [8, 16, 128, 256].each do |data_width|
        expect {
          create_configuration(data_width: data_width, protocol: :axi4lite)
        }.to raise_configuration_error "data width eigher 32 bit or 64 bit is only supported: #{data_width}"
      end
    end
  end
end
