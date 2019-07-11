# frozen_string_literal: true

RSpec.describe 'register_block/protocol/apb' do
  include_context 'configuration common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width])
    RgGen.enable(:register_block, :protocol)
    RgGen.enable(:register_block, :protocol, [:apb])
  end

  describe 'configuration' do
    specify 'プロトコル名は:apb' do
      configuration = create_configuration(protocol: :apb)
      expect(configuration).to have_property(:protocol, :apb)
    end

    it '32ビットを超えるバス幅に対応しない' do
      [8, 16, 32].each do |bus_width|
        expect {
          create_configuration(bus_width: bus_width, protocol: :apb)
        }.not_to raise_error
      end

      [64, 128, 256].each do |bus_width|
        expect {
          create_configuration(bus_width: bus_width, protocol: :apb)
        }.to raise_configuration_error "bus width over 32 bit is not supported: #{bus_width}"
      end
    end

    it '32ビットを超えるアドレス幅に対応しない' do
      [2, 32, rand(3..31)].each do |address_width|
        expect {
          create_configuration(address_width: address_width, protocol: :apb)
        }.not_to raise_error
      end

      [33, 34, rand(35..64)].each do |address_width|
        expect {
          create_configuration(address_width: address_width, protocol: :apb)
        }.to raise_configuration_error "address width over 32 bit is not supported: #{address_width}"
      end
    end
  end
end
