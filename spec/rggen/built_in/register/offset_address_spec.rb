# frozen_string_literal: true

RSpec.describe 'register/offset_address' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:global, :data_width)
    RgGen.enable(:register, :offset_address)
  end

  def create_registers(data_width, &block)
    configuration = create_configuration(data_width: data_width)
    create_register_map(configuration) { register_block(&block) }.registers
  end

  describe '#offset_address' do
    it '入力されたオフセットアドレスを返す' do
      offset_address_list = [
        0, 2, 4, 8, 2 * rand(5..10)
      ]
      registers = create_registers(16) do
        register { offset_address offset_address_list[0] }
        register { offset_address offset_address_list[1] }
        register { offset_address offset_address_list[2] }
        register { offset_address offset_address_list[3] }
        register { offset_address offset_address_list[4] }
      end

      expect(registers[0]).to have_property(:offset_address, offset_address_list[0])
      expect(registers[1]).to have_property(:offset_address, offset_address_list[1])
      expect(registers[2]).to have_property(:offset_address, offset_address_list[2])
      expect(registers[3]).to have_property(:offset_address, offset_address_list[3])
      expect(registers[4]).to have_property(:offset_address, offset_address_list[4])

      offset_address_list = [
        0, 4, 8, 4 * rand(3..10)
      ]
      registers = create_registers(32) do
        register { offset_address offset_address_list[0] }
        register { offset_address offset_address_list[1] }
        register { offset_address offset_address_list[2] }
        register { offset_address offset_address_list[3] }
      end

      expect(registers[0]).to have_property(:offset_address, offset_address_list[0])
      expect(registers[1]).to have_property(:offset_address, offset_address_list[1])
      expect(registers[2]).to have_property(:offset_address, offset_address_list[2])
      expect(registers[3]).to have_property(:offset_address, offset_address_list[3])

      offset_address_list = [
        0, 8, 16, 8 * rand(3..10)
      ]
      registers = create_registers(64) do
        register { offset_address offset_address_list[0] }
        register { offset_address offset_address_list[1] }
        register { offset_address offset_address_list[2] }
      end

      expect(registers[0]).to have_property(:offset_address, offset_address_list[0])
      expect(registers[1]).to have_property(:offset_address, offset_address_list[1])
      expect(registers[2]).to have_property(:offset_address, offset_address_list[2])
    end
  end

  describe 'エラーチェック' do
    context 'オフセットアドレスが未指定の場合' do
      it 'RegisterMapErrorを起こす' do
        expect {
          create_registers([16, 32, 64].sample) do
            register {}
          end
        }.to raise_register_map_error 'no offset address is given'

        expect {
          create_registers([16, 32, 64].sample) do
            register { offset_address nil }
          end
        }.to raise_register_map_error 'no offset address is given'

        expect {
          create_registers([16, 32, 64].sample) do
            register { offset_address '' }
          end
        }.to raise_register_map_error 'no offset address is given'
      end
    end

    context '入力値が整数に変換できない場合' do
      it 'RegisterMapErrorを起こす' do
        [true, false, ' ', 'foo', '0xef_gh', Object.new].each do |value|
          expect {
            create_registers([16, 32, 64].sample) do
              register { offset_address value }
            end
          }.to raise_register_map_error "cannot convert #{value.inspect} into offset address"
        end
      end
    end

    context '入力値が 0 未満の場合' do
      it 'RegisterMapErrorを起こす' do
        [-1, -2, rand(-10..-3)].each do |value|
          expect {
            create_registers([16, 32, 64].sample) do
              register { offset_address value }
            end
          }.to raise_register_map_error "offset address is less than 0: #{value}"
        end
      end
    end

    context 'データ幅に揃っていない場合' do
      it 'RegisterMapErrorを起こす' do
        [1, 3, 7, 9, 15, 17].each do |value|
          expect {
            create_registers(16) do
              register { offset_address value }
            end
          }.to raise_register_map_error "offset address is not aligned with data width(16): 0x#{value.to_s(16)}"
        end

        [1, 2, 3, 5, 15, 17].each do |value|
          expect {
            create_registers(32) do
              register { offset_address value }
            end
          }.to raise_register_map_error "offset address is not aligned with data width(32): 0x#{value.to_s(16)}"
        end

        [1, 2, 3, 4, 5, 6, 7, 9, 15, 17].each do |value|
          expect {
            create_registers(64) do
              register { offset_address value }
            end
          }.to raise_register_map_error "offset address is not aligned with data width(64): 0x#{value.to_s(16)}"
        end
      end
    end
  end
end
