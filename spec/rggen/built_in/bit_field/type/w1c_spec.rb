# frozen_string_literal: true

RSpec.describe 'bit_field/type/w1c' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, [:name, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:w1c, :rw])
  end

  describe 'register_map' do
    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    def create_bit_fields(&block)
      create_register_map { register_block(&block) }.bit_fields
    end

    specify 'ビットフィールド型は:w1c' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 0; type :w1c; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to have_property(:type, :w1c)
    end

    specify 'アクセス属性は読み書き可' do
      bit_fields = create_bit_fields do
        register do
          name :foo
          bit_field { name :foo; bit_assignment lsb: 0; type :w1c; initial_value 0 }
        end
      end
      expect(bit_fields[0]).to match_access(:read_write)
    end

    specify '初期値の指定が必要' do
      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo_0; bit_assignment lsb: 0, width: 1; type :w1c; initial_value 0 }
            bit_field { name :foo_1; bit_assignment lsb: 1, width: 2; type :w1c; initial_value 1 }
          end
        end
      }.not_to raise_error

      expect {
        create_bit_fields do
          register do
            name :foo
            bit_field { name :foo_0; bit_assignment lsb: 0, width: 1; type :w1c }
          end
        end
      }.to raise_register_map_error
    end

    context '参照ビットフィールドの指定がある場合' do
      specify '同一幅のビットフィールドの指定が必要' do
        expect {
          create_bit_fields do
            register do
              name :foo
              bit_field { name :foo_0; bit_assignment lsb: 0, width: 1; type :w1c; reference 'bar.bar_0'; initial_value 0 }
              bit_field { name :foo_1; bit_assignment lsb: 1, width: 2; type :w1c; reference 'bar.bar_1'; initial_value 0 }
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
              bit_field { name :foo_0; bit_assignment lsb: 0, width: 1; type :w1c; reference 'bar.bar_0'; initial_value 0 }
              bit_field { name :foo_1; bit_assignment lsb: 1, width: 2; type :w1c; reference 'bar.bar_1'; initial_value 0 }
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

  describe 'sv rtl' do
    include_context 'sv rtl common'

    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:global, [:data_width, :address_width, :array_port_format])
      RgGen.enable(:register_block, [:name, :byte_size])
      RgGen.enable(:register_block, :sv_rtl_top)
      RgGen.enable(:register, :sv_rtl_top)
      RgGen.enable(:bit_field, :sv_rtl_top)
    end

    after(:all) do
      RgGen.disable(:global, [:data_width, :address_width, :array_port_format])
      RgGen.disable(:register_block, [:name, :byte_size])
    end

    def create_bit_fields(&body)
      configuration = create_configuration(array_port_format: array_port_format)
      create_sv_rtl(configuration, &body).bit_fields
    end

    let(:array_port_format) do
      [:packed, :unpacked, :vectorized].sample
    end

    it '入力ポート#set/出力ポート#value_outを持つ' do
      bit_fields = create_bit_fields do
        name 'block_0'
        byte_size 256

        register do
          name 'register_0'
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1c; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1c; initial_value 0 }
        end

        register do
          name 'register_1'
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 64; type :w1c; initial_value 0 }
        end

        register do
          name 'register_2'
          size [4]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1c; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1c; initial_value 0 }
        end

        register do
          name 'register_3'
          size [2, 2]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1c; initial_value 0 }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1c; initial_value 0 }
        end
      end

      expect(bit_fields[0])
        .to have_port :register_block, :set, {
          name: 'i_register_0_bit_field_0_set',
          direction: :input,
          data_type: :logic,
          width: 1
        }
      expect(bit_fields[0])
        .to have_port :register_block, :value_out, {
          name: 'o_register_0_bit_field_0',
          direction: :output,
          data_type: :logic,
          width: 1
        }

      expect(bit_fields[1])
        .to have_port :register_block, :set, {
          name: 'i_register_0_bit_field_1_set',
          direction: :input,
          data_type: :logic,
          width: 2
        }
      expect(bit_fields[1])
        .to have_port :register_block, :value_out, {
          name: 'o_register_0_bit_field_1',
          direction: :output,
          data_type: :logic,
          width: 2
        }

      expect(bit_fields[2])
        .to have_port :register_block, :set, {
          name: 'i_register_0_bit_field_2_set',
          direction: :input,
          data_type: :logic,
          width: 4,
          array_size: [2],
          array_format: array_port_format
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

      expect(bit_fields[3])
        .to have_port :register_block, :set, {
          name: 'i_register_1_bit_field_0_set',
          direction: :input,
          data_type: :logic,
          width: 64
        }
      expect(bit_fields[3])
        .to have_port :register_block, :value_out, {
          name: 'o_register_1_bit_field_0',
          direction: :output,
          data_type: :logic,
          width: 64
        }

      expect(bit_fields[4])
        .to have_port :register_block, :set, {
          name: 'i_register_2_bit_field_0_set',
          direction: :input,
          data_type: :logic,
          width: 1,
          array_size: [4],
          array_format: array_port_format
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

      expect(bit_fields[5])
        .to have_port :register_block, :set, {
          name: 'i_register_2_bit_field_1_set',
          direction: :input,
          data_type: :logic,
          width: 2,
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

      expect(bit_fields[6])
        .to have_port :register_block, :set, {
          name: 'i_register_2_bit_field_2_set',
          direction: :input,
          data_type: :logic,
          width: 4,
          array_size: [4, 2],
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

      expect(bit_fields[7])
        .to have_port :register_block, :set, {
          name: 'i_register_3_bit_field_0_set',
          direction: :input,
          data_type: :logic,
          width: 1,
          array_size: [2, 2],
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

      expect(bit_fields[8])
        .to have_port :register_block, :set, {
          name: 'i_register_3_bit_field_1_set',
          direction: :input,
          data_type: :logic,
          width: 2,
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

      expect(bit_fields[9])
        .to have_port :register_block, :set, {
          name: 'i_register_3_bit_field_2_set',
          direction: :input,
          data_type: :logic,
          width: 4,
          array_size: [2, 2, 2],
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
    end

    context '参照信号を持つ場合' do
      it '出力ポート#value_unmaskedを持つ' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0; reference 'register_3.bit_field_0' }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1c; initial_value 0; reference 'register_3.bit_field_1' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1c; initial_value 0; reference 'register_3.bit_field_2' }
          end

          register do
            name 'register_1'
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0; reference 'register_3.bit_field_0' }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1c; initial_value 0; reference 'register_3.bit_field_1' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1c; initial_value 0; reference 'register_3.bit_field_2' }
          end

          register do
            name 'register_2'
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0; reference 'register_3.bit_field_0' }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1c; initial_value 0; reference 'register_3.bit_field_1' }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1c; initial_value 0; reference 'register_3.bit_field_2' }
          end

          register do
            name 'register_3'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :rw; initial_value 0 }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4; type :rw; initial_value 0 }
          end
        end

        expect(bit_fields[0])
          .to have_port :register_block, :value_unmasked, {
            name: 'o_register_0_bit_field_0_unmasked',
            direction: :output,
            data_type: :logic,
            width: 1
          }

        expect(bit_fields[1])
          .to have_port :register_block, :value_unmasked, {
            name: 'o_register_0_bit_field_1_unmasked',
            direction: :output,
            data_type: :logic,
            width: 2
          }

        expect(bit_fields[2])
          .to have_port :register_block, :value_unmasked, {
            name: 'o_register_0_bit_field_2_unmasked',
            direction: :output,
            data_type: :logic,
            width: 4,
            array_size: [2],
            array_format: array_port_format
          }

        expect(bit_fields[3])
          .to have_port :register_block, :value_unmasked, {
            name: 'o_register_1_bit_field_0_unmasked',
            direction: :output,
            data_type: :logic,
            width: 1,
            array_size: [4],
            array_format: array_port_format
          }

        expect(bit_fields[4])
          .to have_port :register_block, :value_unmasked, {
            name: 'o_register_1_bit_field_1_unmasked',
            direction: :output,
            data_type: :logic,
            width: 2,
            array_size: [4],
            array_format: array_port_format
          }

        expect(bit_fields[5])
          .to have_port :register_block, :value_unmasked, {
            name: 'o_register_1_bit_field_2_unmasked',
            direction: :output,
            data_type: :logic,
            width: 4,
            array_size: [4, 2],
            array_format: array_port_format
          }

        expect(bit_fields[6])
          .to have_port :register_block, :value_unmasked, {
            name: 'o_register_2_bit_field_0_unmasked',
            direction: :output,
            data_type: :logic,
            width: 1,
            array_size: [2, 2],
            array_format: array_port_format
          }

        expect(bit_fields[7])
          .to have_port :register_block, :value_unmasked, {
            name: 'o_register_2_bit_field_1_unmasked',
            direction: :output,
            data_type: :logic,
            width: 2,
            array_size: [2, 2],
            array_format: array_port_format
          }

        expect(bit_fields[8])
          .to have_port :register_block, :value_unmasked, {
            name: 'o_register_2_bit_field_2_unmasked',
            direction: :output,
            data_type: :logic,
            width: 4,
            array_size: [2, 2, 2],
            array_format: array_port_format
          }
      end
    end

    context '参照信号を持たない場合' do
      it '出力ポート#value_unmaskedを持たない' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1c; initial_value 0 }
          end

          register do
            name 'register_1'
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1c; initial_value 0 }
          end

          register do
            name 'register_2'
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4, sequence_size: 2, step: 8; type :w1c; initial_value 0 }
          end
        end

        expect(bit_fields[0])
          .to not_have_port :register_block, :value_unmasked, {
            name: 'o_register_0_bit_field_0_unmasked',
            direction: :output,
            data_type: :logic,
            width: 1
          }

        expect(bit_fields[1])
          .to not_have_port :register_block, :value_unmasked, {
            name: 'o_register_0_bit_field_1_unmasked',
            direction: :output,
            data_type: :logic,
            width: 2
          }

        expect(bit_fields[2])
          .to not_have_port :register_block, :value_unmasked, {
            name: 'o_register_0_bit_field_2_unmasked',
            direction: :output,
            data_type: :logic,
            width: 4,
            array_size: [2],
            array_format: array_port_format
          }

        expect(bit_fields[3])
          .to not_have_port :register_block, :value_unmasked, {
            name: 'o_register_1_bit_field_0_unmasked',
            direction: :output,
            data_type: :logic,
            width: 1,
            array_size: [4],
            array_format: array_port_format
          }

        expect(bit_fields[4])
          .to not_have_port :register_block, :value_unmasked, {
            name: 'o_register_1_bit_field_1_unmasked',
            direction: :output,
            data_type: :logic,
            width: 2,
            array_size: [4],
            array_format: array_port_format
          }

        expect(bit_fields[5])
          .to not_have_port :register_block, :value_unmasked, {
            name: 'o_register_1_bit_field_2_unmasked',
            direction: :output,
            data_type: :logic,
            width: 4,
            array_size: [4, 2],
            array_format: array_port_format
          }

        expect(bit_fields[6])
          .to not_have_port :register_block, :value_unmasked, {
            name: 'o_register_2_bit_field_0_unmasked',
            direction: :output,
            data_type: :logic,
            width: 1,
            array_size: [2, 2],
            array_format: array_port_format
          }

        expect(bit_fields[7])
          .to not_have_port :register_block, :value_unmasked, {
            name: 'o_register_2_bit_field_1_unmasked',
            direction: :output,
            data_type: :logic,
            width: 2,
            array_size: [2, 2],
            array_format: array_port_format
          }

        expect(bit_fields[8])
          .to not_have_port :register_block, :value_unmasked, {
            name: 'o_register_2_bit_field_2_unmasked',
            direction: :output,
            data_type: :logic,
            width: 4,
            array_size: [2, 2, 2],
            array_format: array_port_format
          }
      end
    end

    describe '#generate_code' do
      let(:array_port_format) { :packed }

      it 'rggen_bit_field_w01cをインスタンスするコードを生成する' do
        bit_fields = create_bit_fields do
          name 'block_0'
          byte_size 256

          register do
            name 'register_0'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 1; type :w1c; reference 'register_5.bit_field_0'; initial_value 1 }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 8, width: 8; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_3'; bit_assignment lsb: 16, width: 8; type :w1c; reference 'register_5.bit_field_2'; initial_value 0xab }
          end

          register do
            name 'register_1'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 64; type :w1c; initial_value 0 }
          end

          register do
            name 'register_2'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 4, width: 4, sequence_size: 4, step: 8; type :w1c; reference 'register_5.bit_field_1'; initial_value 0 }
          end

          register do
            name 'register_3'
            size [4]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 4, width: 4, sequence_size: 4, step: 8; type :w1c; reference 'register_5.bit_field_1'; initial_value 0 }
          end

          register do
            name 'register_4'
            size [2, 2]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8; type :w1c; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 4, width: 4, sequence_size: 4, step: 8; type :w1c; reference 'register_5.bit_field_1'; initial_value 0 }
          end

          register do
            name 'register_5'
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
            bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
            bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 8; type :rw; initial_value 0 }
          end
        end

        expect(bit_fields[0]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (1),
            .INITIAL_VALUE  (1'h0)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_0_bit_field_0_set),
            .i_mask           (1'h1),
            .o_value          (o_register_0_bit_field_0),
            .o_value_unmasked ()
          );
        CODE

        expect(bit_fields[1]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (1),
            .INITIAL_VALUE  (1'h1)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_0_bit_field_1_set),
            .i_mask           (register_if[11].value[0+:1]),
            .o_value          (o_register_0_bit_field_1),
            .o_value_unmasked (o_register_0_bit_field_1_unmasked)
          );
        CODE

        expect(bit_fields[2]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (8),
            .INITIAL_VALUE  (8'h00)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_0_bit_field_2_set),
            .i_mask           (8'hff),
            .o_value          (o_register_0_bit_field_2),
            .o_value_unmasked ()
          );
        CODE

        expect(bit_fields[3]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (8),
            .INITIAL_VALUE  (8'hab)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_0_bit_field_3_set),
            .i_mask           (register_if[11].value[16+:8]),
            .o_value          (o_register_0_bit_field_3),
            .o_value_unmasked (o_register_0_bit_field_3_unmasked)
          );
        CODE

        expect(bit_fields[4]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (64),
            .INITIAL_VALUE  (64'h0000000000000000)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_1_bit_field_0_set),
            .i_mask           (64'hffffffffffffffff),
            .o_value          (o_register_1_bit_field_0),
            .o_value_unmasked ()
          );
        CODE

        expect(bit_fields[5]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_2_bit_field_0_set[i]),
            .i_mask           (4'hf),
            .o_value          (o_register_2_bit_field_0[i]),
            .o_value_unmasked ()
          );
        CODE

        expect(bit_fields[6]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_2_bit_field_1_set[i]),
            .i_mask           (register_if[11].value[8+:4]),
            .o_value          (o_register_2_bit_field_1[i]),
            .o_value_unmasked (o_register_2_bit_field_1_unmasked[i])
          );
        CODE

        expect(bit_fields[7]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_3_bit_field_0_set[i][j]),
            .i_mask           (4'hf),
            .o_value          (o_register_3_bit_field_0[i][j]),
            .o_value_unmasked ()
          );
        CODE

        expect(bit_fields[8]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_3_bit_field_1_set[i][j]),
            .i_mask           (register_if[11].value[8+:4]),
            .o_value          (o_register_3_bit_field_1[i][j]),
            .o_value_unmasked (o_register_3_bit_field_1_unmasked[i][j])
          );
        CODE

        expect(bit_fields[9]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_4_bit_field_0_set[i][j][k]),
            .i_mask           (4'hf),
            .o_value          (o_register_4_bit_field_0[i][j][k]),
            .o_value_unmasked ()
          );
        CODE

        expect(bit_fields[10]).to generate_code(:bit_field, :top_down, <<~'CODE')
          rggen_bit_field_w01c #(
            .CLEAR_VALUE    (1'b1),
            .WIDTH          (4),
            .INITIAL_VALUE  (4'h0)
          ) u_bit_field (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .bit_field_if     (bit_field_sub_if),
            .i_set            (i_register_4_bit_field_1_set[i][j][k]),
            .i_mask           (register_if[11].value[8+:4]),
            .o_value          (o_register_4_bit_field_1[i][j][k]),
            .o_value_unmasked (o_register_4_bit_field_1_unmasked[i][j][k])
          );
        CODE
      end
    end
  end
end
