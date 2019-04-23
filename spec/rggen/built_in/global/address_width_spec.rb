# frozen_string_literal: true

RSpec.describe 'global/address_width' do
  include_context 'configuration common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:data_width, :address_width])
  end

  describe '#address_width' do
    specify 'デフォルト値は32である' do
      configuration = create_configuration
      expect(configuration.address_width).to eq 32
    end

    it '入力されたアドレス幅を返す' do
      [
        [8, 1],
        [16, 1],
        [32, 2],
        [64, 3]
      ].each do |data_width, min_address_width|
        [min_address_width, 8, 16, 32, 64, rand(min_address_width..64)].each do |value|
          input_value = value
          configuration = create_configuration(data_width: data_width, address_width: input_value)
          expect(configuration.address_width).to eq value

          input_value = value.to_f
          configuration = create_configuration(data_width: data_width, address_width: input_value)
          expect(configuration.address_width).to eq value

          input_value = value.to_s
          configuration = create_configuration(data_width: data_width, address_width: input_value)
          expect(configuration.address_width).to eq value

          input_value = format('0x%x', value)
          configuration = create_configuration(data_width: data_width, address_width: input_value)
          expect(configuration.address_width).to eq value
        end
      end
    end
  end

  describe 'エラーチェック' do
    context '入力値が整数に変換できない場合' do
      it 'ConfigurationErrorを起こす' do
        [true, false, 'foo', '0x00_gh', Object.new].each do |value|
          expect {
            create_configuration(address_width: value)
          }.to raise_configuration_error "cannot convert #{value.inspect} into address width"
        end
      end
    end

    context 'データ幅から求まる最小値に満たない場合' do
      it 'ConfigurationErrorを起こす' do
        [
          [8, 1],
          [16, 1],
          [32, 2],
          [64, 3]
        ].each do |data_width, min_address_width|
          [-1, 0, (min_address_width - 1)].each do |address_width|
            expect {
              create_configuration(data_width: data_width, address_width: address_width)
            }.to raise_configuration_error 'input address width is less than minimum address width: ' \
                                           "address width #{address_width} minimum address width #{min_address_width}"
          end
        end
      end
    end
  end
end
