# frozen_string_literal: true

RSpec.describe 'bit_field/type/ro' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, [:name, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:ro, :rw])
  end

  describe 'register_map' do
    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    def create_bit_fields(&block)
      create_register_map { register_block(&block) }.bit_fields
    end

    specify 'ビットフィールド型は:ro' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 0; type :ro }
        end
      end
      expect(bit_fields[0]).to have_property(:type, :ro)
    end

    it '揮発性ビットフィールドである' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 0; type :ro }
        end
      end
      expect(bit_fields[0]).to have_property(:volatile?, true)
    end

    specify 'アクセス属性は読み込みのみ可' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 0; type :ro }
        end
      end
      expect(bit_fields[0]).to match_access(:read_only)
    end

    specify '初期値の指定は不要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo; bit_assignment lsb: 0; type :ro; initial_value 0 }
          end
          register do
            name :bar
            bit_field { name :bar; bit_assignment lsb: 0; type :ro }
          end
        end
      }.not_to raise_error
    end

    context '参照ビットフィールドの指定がある場合' do
      specify '同一幅のビットフィールドの指定が必要' do
        expect {
          create_bit_fields do
            register do
              name :foo
              bit_field { name :foo_0; bit_assignment lsb: 0, width: 1; type :ro; reference 'bar.bar_0' }
              bit_field { name :foo_1; bit_assignment lsb: 1, width: 2; type :ro; reference 'bar.bar_1' }
            end
            register do
              name :bar
              bit_field { name :bar_0; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
              bit_field { name :bar_1; bit_assignment lsb: 1, width: 2; type :rw; initial_value 0 }
            end
          end
        }.not_to raise_error

        expect {
          create_bit_fields do
            register do
              name :foo
              bit_field { name :foo_0; bit_assignment lsb: 0, width: 1; type :ro; reference 'bar.bar_0' }
              bit_field { name :foo_1; bit_assignment lsb: 1, width: 2; type :ro; reference 'bar.bar_1' }
            end
            register do
              name :bar
              bit_field { name :bar_0; bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
              bit_field { name :bar_1; bit_assignment lsb: 2, width: 1; type :rw; initial_value 0 }
            end
          end
        }.to raise_register_map_error
      end
    end
  end

  describe 'sv_rtl' do
    include_context 'sv rtl common'

    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:global, [:bus_width, :address_width, :array_port_format])
      RgGen.enable(:register_block, [:name, :byte_size])
      RgGen.enable(:register_block, :sv_rtl_top)
      RgGen.enable(:register, :sv_rtl_top)
      RgGen.enable(:bit_field, :sv_rtl_top)
    end

    after(:all) do
      RgGen.disable(:global, [:bus_width, :address_width, :array_port_format])
      RgGen.disable(:register_block, [:name, :byte_size])
    end

    def create_bit_fields(&body)
      configuration = create_configuration(array_port_format: array_port_format)
      create_sv_rtl(configuration, &body).bit_fields
    end

    let(:array_port_format) do
      [:packed, :unpacked, :vectorized].sample
    end

    context '参照ビットフィールドを持たない場合' do
      it '入力ポート#value_inを持つ' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :ro }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :ro }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :ro }
          end

          register do
            name 'register_1'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 64; type :ro }
          end

          register do
            name 'register_2'
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :ro }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :ro }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :ro }
          end

          register do
            name 'register_3'
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :ro }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :ro }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :ro }
          end
        end

        expect(bit_fields[0])
          .to have_port :register_block, :value_in, {
            name: 'i_register_0_bit_field_0',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(bit_fields[1])
          .to have_port :register_block, :value_in, {
            name: 'i_register_0_bit_field_1',
            direction: :input,
            data_type: :logic,
            width: 2
          }
        expect(bit_fields[2])
          .to have_port :register_block, :value_in, {
            name: 'i_register_0_bit_field_2',
            direction: :input,
            data_type: :logic,
            width: 4,
            array_size: [2],
            array_format: array_port_format
          }

        expect(bit_fields[3])
          .to have_port :register_block, :value_in, {
            name: 'i_register_1_bit_field_0',
            direction: :input,
            data_type: :logic,
            width: 64
          }

        expect(bit_fields[4])
          .to have_port :register_block, :value_in, {
            name: 'i_register_2_bit_field_0',
            direction: :input,
            data_type: :logic,
            width: 1,
            array_size: [4],
            array_format: array_port_format
          }
        expect(bit_fields[5])
          .to have_port :register_block, :value_in, {
            name: 'i_register_2_bit_field_1',
            direction: :input,
            data_type: :logic,
            width: 2,
            array_size: [4],
            array_format: array_port_format
          }
        expect(bit_fields[6])
          .to have_port :register_block, :value_in, {
            name: 'i_register_2_bit_field_2',
            direction: :input,
            data_type: :logic,
            width: 4,
            array_size: [4, 2],
            array_format: array_port_format
          }

        expect(bit_fields[7])
          .to have_port :register_block, :value_in, {
            name: 'i_register_3_bit_field_0',
            direction: :input,
            data_type: :logic,
            width: 1,
            array_size: [2, 2],
            array_format: array_port_format
          }
        expect(bit_fields[8])
          .to have_port :register_block, :value_in, {
            name: 'i_register_3_bit_field_1',
            direction: :input,
            data_type: :logic,
            width: 2,
            array_size: [2, 2],
            array_format: array_port_format
          }
        expect(bit_fields[9])
          .to have_port :register_block, :value_in, {
            name: 'i_register_3_bit_field_2',
            direction: :input,
            data_type: :logic,
            width: 4,
            array_size: [2, 2, 2],
            array_format: array_port_format
          }
      end
    end

    context '参照ビットフィールドを持つ場合' do
      it '入力ポート#value_inを持たない' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :ro; reference 'register_4.bit_field_0' }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :ro; reference 'register_4.bit_field_1' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :ro; reference 'register_4.bit_field_2' }
          end

          register do
            name 'register_1'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 64; type :ro; reference 'register_4.bit_field_3' }
          end

          register do
            name 'register_2'
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :ro; reference 'register_4.bit_field_0' }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :ro; reference 'register_4.bit_field_1' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :ro; reference 'register_4.bit_field_2' }
          end

          register do
            name 'register_3'
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :ro; reference 'register_4.bit_field_0' }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :ro; reference 'register_4.bit_field_1' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :ro; reference 'register_4.bit_field_2' }
          end

          register do
            name 'register_4'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :rw; initial_value 0 }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4; type :rw; initial_value 0 }
            bit_field { name 'bit_field_3'; bit_assignment lsb: 32, width: 64; type :rw; initial_value 0 }
          end
        end

        expect(bit_fields[0])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_0_bit_field_0',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(bit_fields[1])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_0_bit_field_1',
            direction: :input,
            data_type: :logic,
            width: 2
          }
        expect(bit_fields[2])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_0_bit_field_2',
            direction: :input,
            data_type: :logic,
            width: 4,
            array_size: [2],
            array_format: array_port_format
          }

        expect(bit_fields[3])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_1_bit_field_0',
            direction: :input,
            data_type: :logic,
            width: 64
          }

        expect(bit_fields[4])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_2_bit_field_0',
            direction: :input,
            data_type: :logic,
            width: 1,
            array_size: [4],
            array_format: array_port_format
          }
        expect(bit_fields[5])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_2_bit_field_1',
            direction: :input,
            data_type: :logic,
            width: 2,
            array_size: [4],
            array_format: array_port_format
          }
        expect(bit_fields[6])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_2_bit_field_2',
            direction: :input,
            data_type: :logic,
            width: 4,
            array_size: [4, 2],
            array_format: array_port_format
          }

        expect(bit_fields[7])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_3_bit_field_0',
            direction: :input,
            data_type: :logic,
            width: 1,
            array_size: [2, 2],
            array_format: array_port_format
          }
        expect(bit_fields[8])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_3_bit_field_1',
            direction: :input,
            data_type: :logic,
            width: 2,
            array_size: [2, 2],
            array_format: array_port_format
          }
        expect(bit_fields[9])
          .to not_have_port :register_block, :value_in, {
            name: 'i_register_3_bit_field_2',
            direction: :input,
            data_type: :logic,
            width: 4,
            array_size: [2, 2, 2],
            array_format: array_port_format
          }
      end
    end

    describe '#generate_code' do
      let(:array_port_format) { :packed }

      it 'rggen_bit_field_roをインスタンスするコードを生成する' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :ro }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 1; type :ro; reference 'register_1.bit_field_0' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 8, width: 8; type :ro }
            bit_field { name 'bit_field_3'; bit_assignment lsb: 16, width: 8; type :ro; reference 'register_1.bit_field_1' }
          end

          register do
            name 'register_1'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 1; type :rw; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 16, width: 8; type :rw; initial_value 0 }
          end

          register do
            name 'register_2'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 64; type :ro }
          end

          register do
            name 'register_3'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 2, step: 16; type :ro }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 4, width: 4, sequence_size: 2, step: 16; type :ro; reference 'register_4.bit_field_0' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 8, width: 4, sequence_size: 2, step: 16; type :ro; reference 'register_4.bit_field_1' }
          end

          register do
            name 'register_4'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 4, sequence_size: 2; type :rw; initial_value 0 }
          end

          register do
            name 'register_5'
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 2, step: 16; type :ro }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 4, width: 4, sequence_size: 2, step: 16; type :ro; reference 'register_6.bit_field_0' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 8, width: 4, sequence_size: 2, step: 16; type :ro; reference 'register_7.bit_field_0' }
          end

          register do
            name 'register_6'
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 4, width: 4, sequence_size: 2; type :rw; initial_value 0 }
          end

          register do
            name 'register_7'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
          end

          register do
            name 'register_8'
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 2, step: 16; type :ro }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 4, width: 4, sequence_size: 2, step: 16; type :ro; reference 'register_9.bit_field_0' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 8, width: 4, sequence_size: 2, step: 16; type :ro; reference 'register_10.bit_field_0' }
          end

          register do
            name 'register_9'
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 4, width: 4, sequence_size: 2; type :rw; initial_value 0 }
          end

          register do
            name 'register_10'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
          end
        end

        expect(bit_fields[0]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (1)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (i_register_0_bit_field_0)
          );
        CODE

        expect(bit_fields[1]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (1)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (register_if[1].value[1+:1])
          );
        CODE

        expect(bit_fields[2]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (8)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (i_register_0_bit_field_2)
          );
        CODE

        expect(bit_fields[3]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (8)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (register_if[1].value[16+:8])
          );
        CODE

        expect(bit_fields[6]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (64)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (i_register_2_bit_field_0)
          );
        CODE

        expect(bit_fields[7]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (4)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (i_register_3_bit_field_0[i])
          );
        CODE

        expect(bit_fields[8]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (4)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (register_if[4].value[4+:4])
          );
        CODE

        expect(bit_fields[9]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (4)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (register_if[4].value[8+4*i+:4])
          );
        CODE

        expect(bit_fields[12]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (4)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (i_register_5_bit_field_0[i][j])
          );
        CODE

        expect(bit_fields[13]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (4)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (register_if[9+i].value[4+4*j+:4])
          );
        CODE

        expect(bit_fields[14]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (4)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (register_if[13].value[4+:4])
          );
        CODE

        expect(bit_fields[17]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (4)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (i_register_8_bit_field_0[i][j][k])
          );
        CODE

        expect(bit_fields[18]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (4)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (register_if[18+2*i+j].value[4+4*k+:4])
          );
        CODE

        expect(bit_fields[19]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_ro #(
            .WIDTH  (4)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_value      (register_if[22].value[4+:4])
          );
        CODE
      end
    end
  end
end
