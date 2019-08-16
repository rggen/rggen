# frozen_string_literal: true

RSpec.describe 'globa/bus_width' do
  include_context 'configuration common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, :bus_width)
  end

  describe '#bus_width/#byte_width' do
    specify 'デフォル値は32/4である' do
      configuration = create_configuration
      expect(configuration.bus_width).to eq 32
      expect(configuration.byte_width).to eq 4
    end

    it '入力されたバス幅/バイト幅を返す' do
      [8, 16, 32, 64, 128].each do |value|
        input_value = value
        configuration = create_configuration { bus_width input_value }
        expect(configuration.bus_width).to eq value
        expect(configuration.byte_width).to eq value / 8

        input_value = value.to_f
        configuration = create_configuration { bus_width input_value }
        expect(configuration.bus_width).to eq value
        expect(configuration.byte_width).to eq value / 8

        input_value = value.to_s
        configuration = create_configuration { bus_width input_value }
        expect(configuration.bus_width).to eq value
        expect(configuration.byte_width).to eq value / 8

        input_value = format('0x%x', value)
        configuration = create_configuration { bus_width input_value }
        expect(configuration.bus_width).to eq value
        expect(configuration.byte_width).to eq value / 8
      end
    end
  end

  it '表示可能オブジェクトとして、入力されたバス幅を返す' do
    width = [8, 16, 32, 64].sample
    configuration = create_configuration(bus_width: width)
    expect(configuration.printables[:bus_width]).to eq width
  end

  describe 'エラーチェック' do
    context '入力が整数に変換できない場合' do
      it 'ConfigurationErrorを起こす' do
        [true, false, 'foo', '0xef_gh', Object.new].each do |value|
          expect {
            create_configuration { bus_width value }
          }.to raise_configuration_error "cannot convert #{value.inspect} into bus width"
        end
      end
    end

    context '入力が8未満の場合' do
      it 'ConfigurationErrorを起こす' do
        [-1, 0, 1, 7].each do |value|
          expect {
            create_configuration { bus_width value }
          }.to raise_configuration_error "input bus width is less than 8: #{value}"
        end
      end
    end

    context '入力が2のべき乗ではない場合' do
      it 'ConfigurationErrorを起こす' do
        [31, 33, 63, 65].each do |value|
          expect {
            create_configuration { bus_width value }
          }.to raise_configuration_error "input bus width is not power of 2: #{value}"
        end
      end
    end
  end
end
