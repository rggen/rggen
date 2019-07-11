# frozen_string_literal: true

RSpec.describe 'register/type/default' do
  describe 'sv rtl' do
    include_context 'clean-up builder'
    include_context 'sv rtl common'

    before(:all) do
      RgGen.enable(:global, [:data_width, :address_width, :array_port_format])
      RgGen.enable(:register_block, [:name, :byte_size])
      RgGen.enable(:register, [:name, :offset_address, :size, :type])
      RgGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
      RgGen.enable(:bit_field, :type, :rw)
      RgGen.enable(:register_block, :sv_rtl_top)
      RgGen.enable(:register, :sv_rtl_top)
      RgGen.enable(:bit_field, :sv_rtl_top)
    end

    def create_registers(&body)
      create_sv_rtl(&body).registers
    end

    describe '#generate_code' do
      it 'rggen_default_registerをインスタンスするコードを出力する' do
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
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 32; type :rw; initial_value 0 }
          end

          register do
            name 'register_4'
            offset_address 0x40
            bit_field { name 'bit_field_0'; bit_assignment lsb: 4, width: 4, sequence_size: 4, step: 8; type :rw; initial_value 0 }
          end

          register do
            name 'register_5'
            offset_address 0x50
            bit_field { name 'bit_field_0'; bit_assignment lsb: 32; type :rw; initial_value 0 }
          end

          register do
            name 'register_6'
            offset_address 0x60
            bit_field { name 'bit_field_0'; bit_assignment lsb: 4, width: 4, sequence_size: 8, step: 8; type :rw; initial_value 0 }
          end
        end

        expect(registers[0]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h00),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (32),
            .VALID_BITS     (32'h00000001),
            .REGISTER_INDEX (0)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[0]),
            .bit_field_if (bit_field_if)
          );
        CODE

        expect(registers[1]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h10),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (32),
            .VALID_BITS     (32'h00000001),
            .REGISTER_INDEX (i)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[1+i]),
            .bit_field_if (bit_field_if)
          );
        CODE

        expect(registers[2]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h20),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (32),
            .VALID_BITS     (32'h00000001),
            .REGISTER_INDEX (2*i+j)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[5+2*i+j]),
            .bit_field_if (bit_field_if)
          );
        CODE

        expect(registers[3]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h30),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (32),
            .VALID_BITS     (32'hffffffff),
            .REGISTER_INDEX (0)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[9]),
            .bit_field_if (bit_field_if)
          );
        CODE

        expect(registers[4]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h40),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (32),
            .VALID_BITS     (32'hf0f0f0f0),
            .REGISTER_INDEX (0)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[10]),
            .bit_field_if (bit_field_if)
          );
        CODE

        expect(registers[5]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h50),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (64),
            .VALID_BITS     (64'h0000000100000000),
            .REGISTER_INDEX (0)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[11]),
            .bit_field_if (bit_field_if)
          );
        CODE

        expect(registers[6]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h60),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (64),
            .VALID_BITS     (64'hf0f0f0f0f0f0f0f0),
            .REGISTER_INDEX (0)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[12]),
            .bit_field_if (bit_field_if)
          );
        CODE
      end
    end
  end
end
