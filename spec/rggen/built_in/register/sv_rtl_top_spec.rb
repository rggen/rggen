# frozen_string_literal: true

RSpec.describe 'register/sv_rtl_top' do
  include_context 'sv rtl common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width, :array_port_format, :fold_sv_interface_port])
    RgGen.enable(:register_block, [:name, :byte_size])
    RgGen.enable(:register, [:name, :offset_address, :size, :type])
    RgGen.enable(:register, :type, [:external, :indirect])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
    RgGen.enable(:bit_field, :type, :rw)
    RgGen.enable(:register_block, :sv_rtl_top)
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
    let(:registers) do
      create_registers do
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
    end

    context '無引数の場合' do
      it 'レジスタブロック内でのインデックスを返す' do
        expect(registers[0].index).to eq 0
        expect(registers[1].index).to eq '1+i'
        expect(registers[2].index).to eq '5+2*i+j'
        expect(registers[3].index).to eq 9
        expect(registers[4].index).to eq 10
      end
    end

    context '引数がnilの場合' do
      it 'レジスタブロック内でのインデックスを返す' do
        expect(registers[0].index(nil)).to eq 0
        expect(registers[1].index(nil)).to eq '1+i'
        expect(registers[2].index(nil)).to eq '5+2*i+j'
        expect(registers[3].index(nil)).to eq 9
        expect(registers[4].index(nil)).to eq 10
      end
    end

    context 'オフセットが引数で指定された場合' do
      it '指定されたオフセットでのインデックスを返す' do
        expect(registers[0].index(1)).to eq 0
        expect(registers[0].index('i')).to eq 0

        expect(registers[1].index(1)).to eq 2
        expect(registers[1].index('i')).to eq '1+i'

        expect(registers[2].index(1)).to eq 6
        expect(registers[2].index('i')).to eq '5+i'

        expect(registers[3].index(1)).to eq 9
        expect(registers[3].index('i')).to eq 9

        expect(registers[4].index(1)).to eq 10
        expect(registers[4].index('i')).to eq 10
      end
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

  describe '#generate_code' do
    it 'レジスタ階層のコードを出力する' do
      registers = create_registers do
        name 'block_0'
        byte_size 256

        register do
          name 'register_0'
          offset_address 0x00
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :rw; initial_value 0 }
        end

        register do
          name 'register_1'
          offset_address 0x10
          type :external
          size [4]
        end

        register do
          name 'register_2'
          offset_address 0x20
          size [4]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :rw; initial_value 0 }
        end

        register do
          name 'register_3'
          offset_address 0x30
          type [:indirect, 'register_0.bit_field_0', 'register_0.bit_field_1']
          size [2, 2]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :rw; initial_value 0 }
        end

        register do
          name 'register_4'
          offset_address 0x40
          bit_field { bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
        end
      end

      expect(registers[0]).to generate_code(:register_block, :top_down, <<~'CODE')
        generate if (1) begin : g_register_0
          rggen_bit_field_if #(32) bit_field_if();
          rggen_default_register #(
            .READABLE       (1),
            .WRITABLE       (1),
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h00),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (32),
            .VALID_BITS     (32'h00000303),
            .REGISTER_INDEX (0)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[0]),
            .bit_field_if (bit_field_if)
          );
          if (1) begin : g_bit_field_0
            rggen_bit_field_if #(2) bit_field_sub_if();
            `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 2)
            rggen_bit_field_rw #(
              .WIDTH          (2),
              .INITIAL_VALUE  (2'h0)
            ) u_bit_field (
              .i_clk        (i_clk),
              .i_rst_n      (i_rst_n),
              .bit_field_if (bit_field_sub_if),
              .o_value      (o_register_0_bit_field_0)
            );
          end
          if (1) begin : g_bit_field_1
            rggen_bit_field_if #(2) bit_field_sub_if();
            `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 2)
            rggen_bit_field_rw #(
              .WIDTH          (2),
              .INITIAL_VALUE  (2'h0)
            ) u_bit_field (
              .i_clk        (i_clk),
              .i_rst_n      (i_rst_n),
              .bit_field_if (bit_field_sub_if),
              .o_value      (o_register_0_bit_field_1)
            );
          end
        end endgenerate
      CODE

      expect(registers[1]).to generate_code(:register_block, :top_down, <<~'CODE')
        generate if (1) begin : g_register_1
          rggen_external_register #(
            .ADDRESS_WIDTH  (8),
            .BUS_WIDTH      (32),
            .START_ADDRESS  (8'h10),
            .END_ADDRESS    (8'h1f)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[1]),
            .bus_if       (register_1_bus_if)
          );
        end endgenerate
      CODE

      expect(registers[2]).to generate_code(:register_block, :top_down, <<~'CODE')
        generate if (1) begin : g_register_2
          genvar i;
          for (i = 0;i < 4;++i) begin : g
            rggen_bit_field_if #(32) bit_field_if();
            rggen_default_register #(
              .READABLE       (1),
              .WRITABLE       (1),
              .ADDRESS_WIDTH  (8),
              .OFFSET_ADDRESS (8'h20),
              .BUS_WIDTH      (32),
              .DATA_WIDTH     (32),
              .VALID_BITS     (32'h00000303),
              .REGISTER_INDEX (i)
            ) u_register (
              .i_clk        (i_clk),
              .i_rst_n      (i_rst_n),
              .register_if  (register_if[2+i]),
              .bit_field_if (bit_field_if)
            );
            if (1) begin : g_bit_field_0
              rggen_bit_field_if #(2) bit_field_sub_if();
              `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 2)
              rggen_bit_field_rw #(
                .WIDTH          (2),
                .INITIAL_VALUE  (2'h0)
              ) u_bit_field (
                .i_clk        (i_clk),
                .i_rst_n      (i_rst_n),
                .bit_field_if (bit_field_sub_if),
                .o_value      (o_register_2_bit_field_0[i])
              );
            end
            if (1) begin : g_bit_field_1
              rggen_bit_field_if #(2) bit_field_sub_if();
              `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 2)
              rggen_bit_field_rw #(
                .WIDTH          (2),
                .INITIAL_VALUE  (2'h0)
              ) u_bit_field (
                .i_clk        (i_clk),
                .i_rst_n      (i_rst_n),
                .bit_field_if (bit_field_sub_if),
                .o_value      (o_register_2_bit_field_1[i])
              );
            end
          end
        end endgenerate
      CODE

      expect(registers[3]).to generate_code(:register_block, :top_down, <<~'CODE')
        generate if (1) begin : g_register_3
          genvar i;
          genvar j;
          for (i = 0;i < 2;++i) begin : g
            for (j = 0;j < 2;++j) begin : g
              logic [3:0] indirect_index;
              rggen_bit_field_if #(32) bit_field_if();
              assign indirect_index = {register_if[0].value[0+:2], register_if[0].value[8+:2]};
              rggen_indirect_register #(
                .READABLE             (1),
                .WRITABLE             (1),
                .ADDRESS_WIDTH        (8),
                .OFFSET_ADDRESS       (8'h30),
                .BUS_WIDTH            (32),
                .DATA_WIDTH           (32),
                .VALID_BITS           (32'h00000303),
                .INDIRECT_INDEX_WIDTH (4),
                .INDIRECT_INDEX_VALUE ({i[0+:2], j[0+:2]})
              ) u_register (
                .i_clk            (i_clk),
                .i_rst_n          (i_rst_n),
                .register_if      (register_if[6+2*i+j]),
                .i_indirect_index (indirect_index),
                .bit_field_if     (bit_field_if)
              );
              if (1) begin : g_bit_field_0
                rggen_bit_field_if #(2) bit_field_sub_if();
                `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 2)
                rggen_bit_field_rw #(
                  .WIDTH          (2),
                  .INITIAL_VALUE  (2'h0)
                ) u_bit_field (
                  .i_clk        (i_clk),
                  .i_rst_n      (i_rst_n),
                  .bit_field_if (bit_field_sub_if),
                  .o_value      (o_register_3_bit_field_0[i][j])
                );
              end
              if (1) begin : g_bit_field_1
                rggen_bit_field_if #(2) bit_field_sub_if();
                `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 2)
                rggen_bit_field_rw #(
                  .WIDTH          (2),
                  .INITIAL_VALUE  (2'h0)
                ) u_bit_field (
                  .i_clk        (i_clk),
                  .i_rst_n      (i_rst_n),
                  .bit_field_if (bit_field_sub_if),
                  .o_value      (o_register_3_bit_field_1[i][j])
                );
              end
            end
          end
        end endgenerate
      CODE

      expect(registers[4]).to generate_code(:register_block, :top_down, <<~'CODE')
        generate if (1) begin : g_register_4
          rggen_bit_field_if #(32) bit_field_if();
          rggen_default_register #(
            .READABLE       (1),
            .WRITABLE       (1),
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h40),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (32),
            .VALID_BITS     (32'h00000003),
            .REGISTER_INDEX (0)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[10]),
            .bit_field_if (bit_field_if)
          );
          if (1) begin : g_register_4
            rggen_bit_field_if #(2) bit_field_sub_if();
            `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 2)
            rggen_bit_field_rw #(
              .WIDTH          (2),
              .INITIAL_VALUE  (2'h0)
            ) u_bit_field (
              .i_clk        (i_clk),
              .i_rst_n      (i_rst_n),
              .bit_field_if (bit_field_sub_if),
              .o_value      (o_register_4)
            );
          end
        end endgenerate
      CODE
    end
  end
end
