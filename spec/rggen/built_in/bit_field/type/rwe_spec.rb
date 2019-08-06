# frozen_string_literal: true

RSpec.describe 'bit_field/type/rwe' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, [:name, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:rw, :rwe])
  end

  describe 'register_map' do
    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    def create_bit_fields(&block)
      create_register_map { register_block(&block) }.bit_fields
    end

    specify 'ビットフィール型は:rwe' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo_0; bit_assignment lsb: 0; type :rwe; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to have_property(:type, :rwe)
    end

    context '参照ビットフィールドの指定がない場合' do
      it '揮発性ビットフィールドである' do
        bit_fields = create_bit_fields do
          register do
            name :foo
            bit_field { name :foo_0; bit_assignment lsb: 0; type :rwe; initial_value 0 }
          end
        end
        expect(bit_fields[0]).to have_property(:volatile?, true)
      end
    end

    context '参照ビットフィールドの指定がある場合' do
      it '不揮発性ビットフィールドである' do
        bit_fields = create_bit_fields do
          register do
            name :foo
            bit_field { name :foo_0; bit_assignment lsb: 0; type :rwe; initial_value 0; reference 'foo.foo_1' }
            bit_field { name :foo_1; bit_assignment lsb: 1; type :rw; initial_value 0 }
          end
        end
        expect(bit_fields[0]).to have_property(:volatile?, false)
      end
    end

    specify 'アクセス属性は読み書き可' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo_0; bit_assignment lsb: 0; type :rwe; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to match_access(:read_write)
    end

    specify '初期値の指定が必要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo_0; bit_assignment lsb: 0; type :rwe }
          end
        end
      }.to raise_register_map_error
    end

    context '参照ビットフィールドの指定がある場合' do
      specify '1ビット幅の参照ビットフィールドの指定が必要' do
        expect {
          create_bit_fields do
            register do
              name :foo
              bit_field { name :foo_0; bit_assignment lsb: 0, width: 2; type :rwe; initial_value 0; reference 'foo.foo_1' }
              bit_field { name :foo_1; bit_assignment lsb: 8, width: 1; type :rw; initial_value 0 }
            end
          end
        }.not_to raise_error

        expect {
          create_bit_fields do
            register do
              name :foo
              bit_field { name :foo_0; bit_assignment lsb: 0, width: 2; type :rwe; initial_value 0; reference 'foo.foo_1' }
              bit_field { name :foo_1; bit_assignment lsb: 8, width: 2; type :rw; initial_value 0 }
            end
          end
        }.to raise_register_map_error
      end
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

    let(:bit_fields) do
      create_bit_fields do
        name 'block_0'
        byte_size 256

        register do
          name 'register_0'
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 1, width: 1; type :rwe; initial_value 0; reference 'register_3.bit_field_0' }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 4, width: 2; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_3'; bit_assignment lsb: 6, width: 2; type :rwe; initial_value 0; reference 'register_3.bit_field_0' }
          bit_field { name 'bit_field_4'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_5'; bit_assignment lsb: 20, width: 4, sequence_size: 2, step: 8; type :rwe; initial_value 0; reference 'register_3.bit_field_0' }
        end

        register do
          name 'register_1'
          size [4]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 1, width: 1; type :rwe; initial_value 0; reference 'register_3.bit_field_0' }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 4, width: 2; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_3'; bit_assignment lsb: 6, width: 2; type :rwe; initial_value 0; reference 'register_3.bit_field_0' }
          bit_field { name 'bit_field_4'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_5'; bit_assignment lsb: 20, width: 4, sequence_size: 2, step: 8; type :rwe; initial_value 0; reference 'register_3.bit_field_0' }
        end

        register do
          name 'register_2'
          size [2, 2]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 1, width: 1; type :rwe; initial_value 0; reference 'register_3.bit_field_0' }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 4, width: 2; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_3'; bit_assignment lsb: 6, width: 2; type :rwe; initial_value 0; reference 'register_3.bit_field_0' }
          bit_field { name 'bit_field_4'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_5'; bit_assignment lsb: 20, width: 4, sequence_size: 2, step: 8; type :rwe; initial_value 0; reference 'register_3.bit_field_0' }
        end

        register do
          name 'register_3'
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
      end
    end

    let(:array_port_format) do
      [:packed, :unpacked, :serialized].sample
    end

    it '出力ポート#value_outを持つ' do
      expect(bit_fields[0]).to have_port(
        :register_block, :value_out,
        name: 'o_register_0_bit_field_0', direction: :output, data_type: :logic, width: 1
      )
      expect(bit_fields[2]).to have_port(
        :register_block, :value_out,
        name: 'o_register_0_bit_field_2', direction: :output, data_type: :logic, width: 2
      )
      expect(bit_fields[4]).to have_port(
        :register_block, :value_out,
        name: 'o_register_0_bit_field_4', direction: :output, data_type: :logic, width: 4,
        array_size: [2], array_format: array_port_format
      )

      expect(bit_fields[6]).to have_port(
        :register_block, :value_out,
        name: 'o_register_1_bit_field_0', direction: :output, data_type: :logic, width: 1,
        array_size: [4], array_format: array_port_format
      )
      expect(bit_fields[8]).to have_port(
        :register_block, :value_out,
        name: 'o_register_1_bit_field_2', direction: :output, data_type: :logic, width: 2,
        array_size: [4], array_format: array_port_format
      )
      expect(bit_fields[10]).to have_port(
        :register_block, :value_out,
        name: 'o_register_1_bit_field_4', direction: :output, data_type: :logic, width: 4,
        array_size: [4, 2], array_format: array_port_format
      )

      expect(bit_fields[12]).to have_port(
        :register_block, :value_out,
        name: 'o_register_2_bit_field_0', direction: :output, data_type: :logic, width: 1,
        array_size: [2, 2], array_format: array_port_format
      )
      expect(bit_fields[14]).to have_port(
        :register_block, :value_out,
        name: 'o_register_2_bit_field_2', direction: :output, data_type: :logic, width: 2,
        array_size: [2, 2], array_format: array_port_format
      )
      expect(bit_fields[16]).to have_port(
        :register_block, :value_out,
        name: 'o_register_2_bit_field_4', direction: :output, data_type: :logic, width: 4,
        array_size: [2, 2, 2], array_format: array_port_format
      )
    end

    context '参照ビットフィールドを持たない場合' do
      it '入力ポート#enableを持つ' do
        expect(bit_fields[0]).to have_port(
          :register_block, :enable,
          name: 'i_register_0_bit_field_0_enable', direction: :input, data_type: :logic, width: 1
        )
        expect(bit_fields[2]).to have_port(
          :register_block, :enable,
          name: 'i_register_0_bit_field_2_enable', direction: :input, data_type: :logic, width: 1
        )
        expect(bit_fields[4]).to have_port(
          :register_block, :enable,
          name: 'i_register_0_bit_field_4_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [2], array_format: array_port_format
        )

        expect(bit_fields[6]).to have_port(
          :register_block, :enable,
          name: 'i_register_1_bit_field_0_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [4], array_format: array_port_format
        )
        expect(bit_fields[8]).to have_port(
          :register_block, :enable,
          name: 'i_register_1_bit_field_2_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [4], array_format: array_port_format
        )
        expect(bit_fields[10]).to have_port(
          :register_block, :enable,
          name: 'i_register_1_bit_field_4_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [4, 2], array_format: array_port_format
        )

        expect(bit_fields[12]).to have_port(
          :register_block, :enable,
          name: 'i_register_2_bit_field_0_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [2, 2], array_format: array_port_format
        )
        expect(bit_fields[14]).to have_port(
          :register_block, :enable,
          name: 'i_register_2_bit_field_2_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [2, 2], array_format: array_port_format
        )
        expect(bit_fields[16]).to have_port(
          :register_block, :enable,
          name: 'i_register_2_bit_field_4_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [2, 2, 2], array_format: array_port_format
        )
      end
    end

    context '参照ビットフィールドを持つ場合' do
      it '入力ポート#enableを持たない' do
        expect(bit_fields[1]).to not_have_port(
          :register_block, :enable,
          name: 'i_register_0_bit_field_1_enable', direction: :input, data_type: :logic, width: 1
        )
        expect(bit_fields[3]).to not_have_port(
          :register_block, :enable,
          name: 'i_register_0_bit_field_3_enable', direction: :input, data_type: :logic, width: 1
        )
        expect(bit_fields[5]).to not_have_port(
          :register_block, :enable,
          name: 'i_register_0_bit_field_5_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [2], array_format: array_port_format
        )

        expect(bit_fields[7]).to not_have_port(
          :register_block, :enable,
          name: 'i_register_1_bit_field_1_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [4], array_format: array_port_format
        )
        expect(bit_fields[9]).to not_have_port(
          :register_block, :enable,
          name: 'i_register_1_bit_field_3_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [4], array_format: array_port_format
        )
        expect(bit_fields[11]).to not_have_port(
          :register_block, :enable,
          name: 'i_register_1_bit_field_5_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [4, 2], array_format: array_port_format
        )

        expect(bit_fields[13]).to not_have_port(
          :register_block, :enable,
          name: 'i_register_2_bit_field_1_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [2, 2], array_format: array_port_format
        )
        expect(bit_fields[15]).to not_have_port(
          :register_block, :enable,
          name: 'i_register_2_bit_field_3_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [2, 2], array_format: array_port_format
        )
        expect(bit_fields[17]).to not_have_port(
          :register_block, :enable,
          name: 'i_register_2_bit_field_5_enable', direction: :input, data_type: :logic, width: 1,
          array_size: [2, 2, 2], array_format: array_port_format
        )
      end
    end

    describe '#generate_code' do
      let(:array_port_format) { :packed }

      it 'rggen_bit_field_rweをインスタンスするコードを出力する' do
        expect(bit_fields[0]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (1),
            .INITIAL_VALUE  (1'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (i_register_0_bit_field_0_enable),
            .o_value      (o_register_0_bit_field_0)
          );
        CODE

        expect(bit_fields[1]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (1),
            .INITIAL_VALUE  (1'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (register_if[9].value[0+:1]),
            .o_value      (o_register_0_bit_field_1)
          );
        CODE

        expect(bit_fields[2]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (2),
            .INITIAL_VALUE  (2'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (i_register_0_bit_field_2_enable),
            .o_value      (o_register_0_bit_field_2)
          );
        CODE

        expect(bit_fields[3]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (2),
            .INITIAL_VALUE  (2'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (register_if[9].value[0+:1]),
            .o_value      (o_register_0_bit_field_3)
          );
        CODE

        expect(bit_fields[4]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (i_register_0_bit_field_4_enable[i]),
            .o_value      (o_register_0_bit_field_4[i])
          );
        CODE

        expect(bit_fields[5]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (register_if[9].value[0+:1]),
            .o_value      (o_register_0_bit_field_5[i])
          );
        CODE

        expect(bit_fields[10]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (i_register_1_bit_field_4_enable[i][j]),
            .o_value      (o_register_1_bit_field_4[i][j])
          );
        CODE

        expect(bit_fields[11]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (register_if[9].value[0+:1]),
            .o_value      (o_register_1_bit_field_5[i][j])
          );
        CODE

        expect(bit_fields[16]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (i_register_2_bit_field_4_enable[i][j][k]),
            .o_value      (o_register_2_bit_field_4[i][j][k])
          );
        CODE

        expect(bit_fields[17]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_rwe #(
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .i_enable     (register_if[9].value[0+:1]),
            .o_value      (o_register_2_bit_field_5[i][j][k])
          );
        CODE
      end
    end
  end

  describe 'sv ral' do
    include_context 'sv ral common'

    before(:all) do
      delete_register_map_factory
    end

    specify 'モデル名はrggen_ral_rwe_field' do
      sv_ral = create_sv_ral do
        register do
          name 'register_0'
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rwe; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 1; type :rwe; initial_value 0; reference 'register_1.bit_field_0' }
        end

        register do
          name 'register_1'
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
      end

      expect(sv_ral.bit_fields[0].model_name).to eq 'rggen_ral_rwe_field #("", "")'
      expect(sv_ral.bit_fields[1].model_name).to eq 'rggen_ral_rwe_field #("register_1", "bit_field_0")'
    end
  end
end
