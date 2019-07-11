# frozen_string_literal: true

RSpec.describe 'register/sv_rtl_top' do
  include_context 'sv rtl common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width, :array_port_format])
    RgGen.enable(:register_block, [:name, :byte_size])
    RgGen.enable(:register, [:name, :offset_address, :size, :type])
    RgGen.enable(:register, :type, :external)
    RgGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
    RgGen.enable(:bit_field, :type, :rw)
    RgGen.enable(:register, :sv_rtl_top)
    RgGen.enable(:bit_field, :sv_rtl_top)
  end

  def create_registers(&body)
    create_sv_rtl(&body).registers
  end

  let(:bus_width) { default_configuration.bus_width }

  describe 'bit_field_if' do
    context 'レジスタがビットフィールドを持つ場合' do
      it 'rggen_bit_field_ifのインスタンスを持つ' do
        registers = create_registers do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            offset_address 0x00
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_1'
            offset_address 0x10
            bit_field { name 'bit_field_0'; bit_assignment lsb: 32; type :rw; initial_value 0 }
          end

          register do
            name 'register_2'
            offset_address 0x20
            size [2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_3'
            offset_address 0x30
            size [2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 32; type :rw; initial_value 0 }
          end

          register do
            name 'register_4'
            offset_address 0x40
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_5'
            offset_address 0x50
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 32; type :rw; initial_value 0 }
          end
        end

        expect(registers[0])
          .to have_interface :register, :bit_field_if, {
            name: 'bit_field_if',
            interface_type: 'rggen_bit_field_if',
            parameter_values: [32]
          }
        expect(registers[1])
          .to have_interface :register, :bit_field_if, {
            name: 'bit_field_if',
            interface_type: 'rggen_bit_field_if',
            parameter_values: [64]
          }
        expect(registers[2])
          .to have_interface :register, :bit_field_if, {
            name: 'bit_field_if',
            interface_type: 'rggen_bit_field_if',
            parameter_values: [32]
          }
        expect(registers[3])
          .to have_interface :register, :bit_field_if, {
            name: 'bit_field_if',
            interface_type: 'rggen_bit_field_if',
            parameter_values: [64]
          }
        expect(registers[4])
          .to have_interface :register, :bit_field_if, {
            name: 'bit_field_if',
            interface_type: 'rggen_bit_field_if',
            parameter_values: [32]
          }
        expect(registers[5])
          .to have_interface :register, :bit_field_if, {
            name: 'bit_field_if',
            interface_type: 'rggen_bit_field_if',
            parameter_values: [64]
          }
      end
    end

    context 'レジスタがビットフィールドを持たない場合' do
      it 'rggen_bit_field_ifのインスタンスを持たない' do
        registers = create_registers do
          name 'block_0'
          byte_size 256
          register do
            name 'register_0'
            offset_address 0x00
            size [64]
            type :external
          end
        end

        expect(registers[0])
          .to not_have_interface :register, :bit_field_if, {
            name: 'bit_field_if',
            interface_type: 'rggen_bit_field_if',
            parameter_values: [32]
          }
      end
    end
  end

  describe '#index' do
    it 'レジスタブロック内でのインデックスを返す' do
      registers = create_registers do
        name 'block_0'
        byte_size 256

        register do
          name 'register_0'
          offset_address 0x00
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end

        register do
          name 'register_1'
          offset_address 0x10
          size [4]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end

        register do
          name 'register_2'
          offset_address 0x20
          size [2, 2]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end

        register do
          name 'register_3'
          offset_address 0x30
          size [4]
          type :external
        end

        register do
          name 'register_4'
          offset_address 0x40
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
      end

      expect(registers[0].index).to eq 0
      expect(registers[1].index).to eq '1+i'
      expect(registers[2].index).to eq '5+2*i+j'
      expect(registers[3].index).to eq 9
      expect(registers[4].index).to eq 10
    end
  end

  describe '#local_index' do
    context '配列レジスタではない場合' do
      it 'nilを返す' do
        registers = create_registers do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            offset_address 0x00
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_1'
            offset_address 0x10
            size [4]
            type :external
          end
        end

        expect(registers[0].local_index).to be_nil
        expect(registers[1].local_index).to be_nil
      end
    end

    context '配列ジレスタの場合' do
      it 'スコープ中のインデックスを返す' do
        registers = create_registers do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            offset_address 0x00
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_1'
            offset_address 0x10
            size [2, 4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_2'
            offset_address 0x30
            size [1, 2, 3]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
        end

        expect(registers[0].local_index).to eq 'i'
        expect(registers[1].local_index).to eq '4*i+j'
        expect(registers[2].local_index).to eq '6*i+3*j+k'
      end
    end
  end

  describe '#loop_variables' do
    context '配列レジスタではない場合' do
      it 'nilを返す' do
        registers = create_registers do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            offset_address 0x00
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_1'
            offset_address 0x10
            size [4]
            type :external
          end
        end

        expect(registers[0].loop_variables).to be_nil
        expect(registers[1].loop_variables).to be_nil
      end
    end

    context '配列レジスタの場合' do
      it 'ループ変数一覧を返す' do
        registers = create_registers do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            offset_address 0x00
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_1'
            offset_address 0x10
            size [2, 4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_2'
            offset_address 0x30
            size [1, 2, 3]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
        end

        expect(registers[0].loop_variables).to match([
          match_identifier('i')
        ])
        expect(registers[1].loop_variables).to match([
          match_identifier('i'), match_identifier('j')
        ])
        expect(registers[2].loop_variables).to match([
          match_identifier('i'), match_identifier('j'), match_identifier('k')
        ])
      end
    end
  end
end
