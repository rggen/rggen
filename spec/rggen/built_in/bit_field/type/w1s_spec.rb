# frozen_string_literal: true

RSpec.describe 'bit_field/type/w1s' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, [:name, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:w1s, :rw])
  end

  describe 'register_map' do
    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    def create_bit_fields(&block)
      create_register_map { register_block(&block) }.bit_fields
    end

    specify 'ビットフィールド型は:w1s' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 0; type :w1s; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to have_property(:type, :w1s)
    end

    specify 'アクセス属性は読み書き可' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 0; type :w1s; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to match_access(:read_write)
    end

    specify '初期値の指定が必要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo_0; bit_assignment lsb: 0, width: 1; type :w1s; initial_value 0 }
            bit_field { name :foo_1; bit_assignment lsb: 1, width: 2; type :w1s; initial_value 1 }
          end
        end
      }.not_to raise_error

      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo_0; bit_assignment lsb: 0, width: 1; type :w1s }
          end
        end
      }.to raise_register_map_error
    end

    specify '参照ビットフィールドの指定は不要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo_0; bit_assignment lsb: 0; type :w1s; initial_value 0 }
            bit_field { name :foo_1; bit_assignment lsb: 1; type :w1s; initial_value 0; reference 'bar.bar' }
          end
          register do
            name :bar
            bit_field { name :bar; bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
          end
        end
      }.not_to raise_error
    end
  end

  describe 'sv rtl' do
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

    it '出力ポート#value_out.入力ポート#clearを持つ' do
      bit_fields = create_bit_fields do
        name 'block_0'
        byte_size 256

        register do
          name 'register_0'
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1s; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1s; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1s; initial_value 0 }
        end

        register do
          name 'register_1'
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 64; type :w1s; initial_value 0 }
        end

        register do
          name 'register_2'
          size [4]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1s; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1s; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1s; initial_value 0 }
        end

        register do
          name 'register_3'
          size [2, 2]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1s; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1s; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1s; initial_value 0 }
        end
      end

      expect(bit_fields[0])
        .to have_port :register_block, :value_out, {
          name: 'o_register_0_bit_field_0',
          direction: :output,
          data_type: :logic,
          width: 1
        }
      expect(bit_fields[0])
        .to have_port :register_block, :clear, {
          name: 'i_register_0_bit_field_0_clear',
          direction: :input,
          data_type: :logic,
          width: 1
        }

      expect(bit_fields[1])
        .to have_port :register_block, :value_out, {
          name: 'o_register_0_bit_field_1',
          direction: :output,
          data_type: :logic,
          width: 2
        }
      expect(bit_fields[1])
        .to have_port :register_block, :clear, {
          name: 'i_register_0_bit_field_1_clear',
          direction: :input,
          data_type: :logic,
          width: 2
        }

      expect(bit_fields[2])
        .to have_port :register_block, :value_out, {
          name: 'o_register_0_bit_field_2',
          direction: :output,
          data_type: :logic,
          width: 4,
          array_size: [2],
          array_format: array_port_format
        }
      expect(bit_fields[2])
        .to have_port :register_block, :clear, {
          name: 'i_register_0_bit_field_2_clear',
          direction: :input,
          data_type: :logic,
          width: 4,
          array_size: [2],
          array_format: array_port_format
        }

      expect(bit_fields[3])
        .to have_port :register_block, :value_out, {
          name: 'o_register_1_bit_field_0',
          direction: :output,
          data_type: :logic,
          width: 64
        }
      expect(bit_fields[3])
        .to have_port :register_block, :clear, {
          name: 'i_register_1_bit_field_0_clear',
          direction: :input,
          data_type: :logic,
          width: 64
        }

      expect(bit_fields[4])
        .to have_port :register_block, :value_out, {
          name: 'o_register_2_bit_field_0',
          direction: :output,
          data_type: :logic,
          width: 1,
          array_size: [4],
          array_format: array_port_format
        }
      expect(bit_fields[4])
        .to have_port :register_block, :clear, {
          name: 'i_register_2_bit_field_0_clear',
          direction: :input,
          data_type: :logic,
          width: 1,
          array_size: [4],
          array_format: array_port_format
        }

      expect(bit_fields[5])
        .to have_port :register_block, :value_out, {
          name: 'o_register_2_bit_field_1',
          direction: :output,
          data_type: :logic,
          width: 2,
          array_size: [4],
          array_format: array_port_format
        }
      expect(bit_fields[5])
        .to have_port :register_block, :clear, {
          name: 'i_register_2_bit_field_1_clear',
          direction: :input,
          data_type: :logic,
          width: 2,
          array_size: [4],
          array_format: array_port_format
        }

      expect(bit_fields[6])
        .to have_port :register_block, :value_out, {
          name: 'o_register_2_bit_field_2',
          direction: :output,
          data_type: :logic,
          width: 4,
          array_size: [4, 2],
          array_format: array_port_format
        }
      expect(bit_fields[6])
        .to have_port :register_block, :clear, {
          name: 'i_register_2_bit_field_2_clear',
          direction: :input,
          data_type: :logic,
          width: 4,
          array_size: [4, 2],
          array_format: array_port_format
        }

      expect(bit_fields[7])
        .to have_port :register_block, :value_out, {
          name: 'o_register_3_bit_field_0',
          direction: :output,
          data_type: :logic,
          width: 1,
          array_size: [2, 2],
          array_format: array_port_format
        }
      expect(bit_fields[7])
        .to have_port :register_block, :clear, {
          name: 'i_register_3_bit_field_0_clear',
          direction: :input,
          data_type: :logic,
          width: 1,
          array_size: [2, 2],
          array_format: array_port_format
        }

      expect(bit_fields[8])
        .to have_port :register_block, :value_out, {
          name: 'o_register_3_bit_field_1',
          direction: :output,
          data_type: :logic,
          width: 2,
          array_size: [2, 2],
          array_format: array_port_format
        }
      expect(bit_fields[8])
        .to have_port :register_block, :clear, {
          name: 'i_register_3_bit_field_1_clear',
          direction: :input,
          data_type: :logic,
          width: 2,
          array_size: [2, 2],
          array_format: array_port_format
        }

      expect(bit_fields[9])
        .to have_port :register_block, :value_out, {
          name: 'o_register_3_bit_field_2',
          direction: :output,
          data_type: :logic,
          width: 4,
          array_size: [2, 2, 2],
          array_format: array_port_format
        }
      expect(bit_fields[9])
        .to have_port :register_block, :clear, {
          name: 'i_register_3_bit_field_2_clear',
          direction: :input,
          data_type: :logic,
          width: 4,
          array_size: [2, 2, 2],
          array_format: array_port_format
        }
    end

    describe '#generate_code' do
      let(:array_port_format) { :packed }

      it 'rggen_bit_field_w01sをインスタンスするコードを出力する' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1s; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 16, width: 16; type :w1s; initial_value 0xabcd }
          end

          register do
            name 'register_1'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 64; type :w1s; initial_value 0 }
          end

          register do
            name 'register_2'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :w1s; initial_value 0 }
          end

          register do
            name 'register_3'
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :w1s; initial_value 0 }
          end

          register do
            name 'register_4'
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :w1s; initial_value 0 }
          end
        end

        expect(bit_fields[0]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01s #(
            .SET_VALUE      (1'b1),
            .WIDTH          (1),
            .INITIAL_VALUE  (1'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_clear      (i_register_0_bit_field_0_clear),
            .o_value      (o_register_0_bit_field_0)
          );
        CODE

        expect(bit_fields[1]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01s #(
            .SET_VALUE      (1'b1),
            .WIDTH          (16),
            .INITIAL_VALUE  (16'habcd)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_clear      (i_register_0_bit_field_1_clear),
            .o_value      (o_register_0_bit_field_1)
          );
        CODE

        expect(bit_fields[2]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01s #(
            .SET_VALUE      (1'b1),
            .WIDTH          (64),
            .INITIAL_VALUE  (64'h0000000000000000)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_clear      (i_register_1_bit_field_0_clear),
            .o_value      (o_register_1_bit_field_0)
          );
        CODE

        expect(bit_fields[3]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01s #(
            .SET_VALUE      (1'b1),
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_clear      (i_register_2_bit_field_0_clear[i]),
            .o_value      (o_register_2_bit_field_0[i])
          );
        CODE

        expect(bit_fields[4]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01s #(
            .SET_VALUE      (1'b1),
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_clear      (i_register_3_bit_field_0_clear[i][j]),
            .o_value      (o_register_3_bit_field_0[i][j])
          );
        CODE

        expect(bit_fields[5]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01s #(
            .SET_VALUE      (1'b1),
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_clear      (i_register_4_bit_field_0_clear[i][j][k]),
            .o_value      (o_register_4_bit_field_0[i][j][k])
          );
        CODE
      end
    end
  end
end
