# frozen_string_literal: true

RSpec.describe 'bit_field/sv_rtl_top' do
  include_context 'sv rtl common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:data_width, :address_width])
    RgGen.enable(:register_block, [:name, :byte_size])
    RgGen.enable(:register, [:name, :offset_address, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
    RgGen.enable(:bit_field, :type, :rw)
    RgGen.enable(:register_block, :sv_rtl_top)
    RgGen.enable(:register, :sv_rtl_top)
    RgGen.enable(:bit_field, :sv_rtl_top)
  end

  def create_bit_fields(&body)
    create_sv_rtl(&body).bit_fields
  end

  describe 'bit_field_sub_if' do
    it 'rggen_bit_field_ifのインスタンスを持つ' do
      bit_fields = create_bit_fields do
        name 'block_0'
        byte_size 256

        register do
          name 'register_0'
          offset_address 0x00
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8; type :rw; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 8, sequence_size: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_3'; bit_assignment lsb: 32, width: 64; type :rw; initial_value 0 }
        end
      end

      expect(bit_fields[0])
        .to have_interface :bit_field, :bit_field_sub_if, {
          name: 'bit_field_sub_if',
          interface_type: 'rggen_bit_field_if',
          parameter_values: [1]
        }
      expect(bit_fields[1])
        .to have_interface :bit_field, :bit_field_sub_if, {
          name: 'bit_field_sub_if',
          interface_type: 'rggen_bit_field_if',
          parameter_values: [8]
        }
      expect(bit_fields[2])
        .to have_interface :bit_field, :bit_field_sub_if, {
          name: 'bit_field_sub_if',
          interface_type: 'rggen_bit_field_if',
          parameter_values: [8]
        }
       expect(bit_fields[3])
        .to have_interface :bit_field, :bit_field_sub_if, {
          name: 'bit_field_sub_if',
          interface_type: 'rggen_bit_field_if',
          parameter_values: [64]
        }
    end
  end

  describe '#local_index' do
    context 'ビットフィールドが連番ではない場合' do
      it 'nilを返す' do
        bit_fields = create_bit_fields do
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
        end

        expect(bit_fields[0].local_index).to be_nil
        expect(bit_fields[1].local_index).to be_nil
        expect(bit_fields[2].local_index).to be_nil
      end
    end

    context 'ビットフィールドが連番になっている場合' do
      it 'スコープ中のインデックスを返す' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            offset_address 0x00
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, sequence_size: 2; type :rw; initial_value 0 }
          end

          register do
            name 'register_1'
            offset_address 0x10
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, sequence_size: 2; type :rw; initial_value 0 }
          end

          register do
            name 'register_2'
            offset_address 0x20
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, sequence_size: 2; type :rw; initial_value 0 }
          end
        end

        expect(bit_fields[0].local_index).to match_identifier('i')
        expect(bit_fields[1].local_index).to match_identifier('j')
        expect(bit_fields[2].local_index).to match_identifier('k')
      end
    end
  end

  describe '#loop_variables' do
    context 'ビットフィールドがループ中にある場合' do
      it 'ループ変数の一覧を返す' do
        bit_fields = create_bit_fields do
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
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end

          register do
            name 'register_2'
            offset_address 0x20
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, sequence_size: 2; type :rw; initial_value 0 }
          end

          register do
            name 'register_3'
            offset_address 0x30
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, sequence_size: 2; type :rw; initial_value 0 }
          end

          register do
            name 'register_4'
            offset_address 0x40
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, sequence_size: 2; type :rw; initial_value 0 }
          end
        end

        expect(bit_fields[0].loop_variables).to match([
          match_identifier('i')
        ])
        expect(bit_fields[1].loop_variables).to match([
          match_identifier('i'), match_identifier('j')
        ])
        expect(bit_fields[2].loop_variables).to match([
          match_identifier('i')
        ])
        expect(bit_fields[3].loop_variables).to match([
          match_identifier('i'), match_identifier('j')
        ])
        expect(bit_fields[4].loop_variables).to match([
          match_identifier('i'), match_identifier('j'), match_identifier('k')
        ])
      end
    end

    context 'ビットフィールドがループ中にないばあい' do
      it 'nilを返す' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            offset_address 0x00
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
        end
        expect(bit_fields[0].loop_variables).to be_nil
      end
    end
  end

  describe '#value' do
    it '自身が保持する値への参照を返す' do
      bit_fields = create_bit_fields do
        name 'block_0'
        byte_size 256

        register do
          name 'register_0'
          offset_address 0x00
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8; type :rw; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, sequence_size: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_3'; bit_assignment lsb: 20, width: 2, sequence_size: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_4'; bit_assignment lsb: 24, width: 2, sequence_size: 2, step: 4; type :rw; initial_value 0 }
        end

        register do
          name 'register_1'
          offset_address 0x10
          size [4]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8; type :rw; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, sequence_size: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_3'; bit_assignment lsb: 20, width: 2, sequence_size: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_4'; bit_assignment lsb: 24, width: 2, sequence_size: 2, step: 4; type :rw; initial_value 0 }
        end

        register do
          name 'register_2'
          offset_address 0x20
          size [2, 2]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8; type :rw; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, sequence_size: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_3'; bit_assignment lsb: 20, width: 2, sequence_size: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_4'; bit_assignment lsb: 24, width: 2, sequence_size: 2, step: 4; type :rw; initial_value 0 }
        end
      end

      expect(bit_fields[0].value).to match_identifier('register_if[0].value[0+:1]')
      expect(bit_fields[1].value).to match_identifier('register_if[0].value[8+:8]')
      expect(bit_fields[2].value).to match_identifier('register_if[0].value[16+1*i+:1]')
      expect(bit_fields[3].value).to match_identifier('register_if[0].value[20+2*i+:2]')
      expect(bit_fields[4].value).to match_identifier('register_if[0].value[24+4*i+:2]')

      expect(bit_fields[5].value).to match_identifier('register_if[1+i].value[0+:1]')
      expect(bit_fields[6].value).to match_identifier('register_if[1+i].value[8+:8]')
      expect(bit_fields[7].value).to match_identifier('register_if[1+i].value[16+1*j+:1]')
      expect(bit_fields[8].value).to match_identifier('register_if[1+i].value[20+2*j+:2]')
      expect(bit_fields[9].value).to match_identifier('register_if[1+i].value[24+4*j+:2]')

      expect(bit_fields[10].value).to match_identifier('register_if[5+2*i+j].value[0+:1]')
      expect(bit_fields[11].value).to match_identifier('register_if[5+2*i+j].value[8+:8]')
      expect(bit_fields[12].value).to match_identifier('register_if[5+2*i+j].value[16+1*k+:1]')
      expect(bit_fields[13].value).to match_identifier('register_if[5+2*i+j].value[20+2*k+:2]')
      expect(bit_fields[14].value).to match_identifier('register_if[5+2*i+j].value[24+4*k+:2]')
    end
  end
end
