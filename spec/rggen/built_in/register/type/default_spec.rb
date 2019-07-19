# frozen_string_literal: true

RSpec.describe 'register/type/default' do
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width, :array_port_format])
    RgGen.enable(:register_block, [:name, :byte_size])
    RgGen.enable(:register, [:name, :offset_address, :size, :type])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
    RgGen.enable(:bit_field, :type, [:rw, :ro, :wo])
  end

  let(:register_map_body) do
    proc do
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

      register do
        name 'register_7'
        offset_address 0x70
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :ro }
      end

      register do
        name 'register_8'
        offset_address 0x80
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :wo; initial_value 0 }
      end
    end
  end

  describe 'sv rtl' do
    include_context 'sv rtl common'

    before(:all) do
      RgGen.enable(:register_block, :sv_rtl_top)
      RgGen.enable(:register, :sv_rtl_top)
      RgGen.enable(:bit_field, :sv_rtl_top)
    end

    describe '#generate_code' do
      let(:registers) { create_sv_rtl(&register_map_body).registers }

      it 'rggen_default_registerをインスタンスするコードを出力する' do
        expect(registers[0]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .READABLE       (1),
            .WRITABLE       (1),
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
            .READABLE       (1),
            .WRITABLE       (1),
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
            .READABLE       (1),
            .WRITABLE       (1),
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
            .READABLE       (1),
            .WRITABLE       (1),
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
            .READABLE       (1),
            .WRITABLE       (1),
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
            .READABLE       (1),
            .WRITABLE       (1),
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
            .READABLE       (1),
            .WRITABLE       (1),
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

        expect(registers[7]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .READABLE       (1),
            .WRITABLE       (0),
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h70),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (32),
            .VALID_BITS     (32'h00000001),
            .REGISTER_INDEX (0)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[13]),
            .bit_field_if (bit_field_if)
          );
        CODE

        expect(registers[8]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_default_register #(
            .READABLE       (0),
            .WRITABLE       (1),
            .ADDRESS_WIDTH  (8),
            .OFFSET_ADDRESS (8'h80),
            .BUS_WIDTH      (32),
            .DATA_WIDTH     (32),
            .VALID_BITS     (32'h00000001),
            .REGISTER_INDEX (0)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[14]),
            .bit_field_if (bit_field_if)
          );
        CODE
      end
    end
  end

  describe 'sv ral' do
    include_context 'sv ral common'

    let(:registers) { create_sv_ral(&register_map_body).registers }

    it 'レジスタモデル変数#reg_modelを持つ' do
      expect(registers[0])
        .to have_variable :register_block, :reg_model, {
          name: 'register_0',
          data_type: 'register_0_reg_model',
          random: true
        }
      expect(registers[1])
        .to have_variable :register_block, :reg_model, {
          name: 'register_1',
          data_type: 'register_1_reg_model',
          array_size: [4],
          array_format: :unpacked,
          random: true
        }
      expect(registers[2])
        .to have_variable :register_block, :reg_model, {
          name: 'register_2',
          data_type: 'register_2_reg_model',
          array_size: [2, 2],
          array_format: :unpacked,
          random: true
        }
    end

    describe '#constructors' do
      it 'レジスタモデルの生成と構成を行うコードを出力する' do
        code_block = RgGen::Core::Utility::CodeUtility::CodeBlock.new
        registers.flat_map(&:constructors).each do |constructor|
          code_block << [constructor, "\n"]
        end

        expect(code_block).to match_string(<<~'CODE')
          `rggen_ral_create_reg_model(register_0, '{}, 8'h00, "RW", 0, "g_register_0.u_register")
          `rggen_ral_create_reg_model(register_1[0], '{0}, 8'h10, "RW", 0, "g_register_1.g[0].u_register")
          `rggen_ral_create_reg_model(register_1[1], '{1}, 8'h14, "RW", 0, "g_register_1.g[1].u_register")
          `rggen_ral_create_reg_model(register_1[2], '{2}, 8'h18, "RW", 0, "g_register_1.g[2].u_register")
          `rggen_ral_create_reg_model(register_1[3], '{3}, 8'h1c, "RW", 0, "g_register_1.g[3].u_register")
          `rggen_ral_create_reg_model(register_2[0][0], '{0, 0}, 8'h20, "RW", 0, "g_register_2.g[0].g[0].u_register")
          `rggen_ral_create_reg_model(register_2[0][1], '{0, 1}, 8'h24, "RW", 0, "g_register_2.g[0].g[1].u_register")
          `rggen_ral_create_reg_model(register_2[1][0], '{1, 0}, 8'h28, "RW", 0, "g_register_2.g[1].g[0].u_register")
          `rggen_ral_create_reg_model(register_2[1][1], '{1, 1}, 8'h2c, "RW", 0, "g_register_2.g[1].g[1].u_register")
          `rggen_ral_create_reg_model(register_3, '{}, 8'h30, "RW", 0, "g_register_3.u_register")
          `rggen_ral_create_reg_model(register_4, '{}, 8'h40, "RW", 0, "g_register_4.u_register")
          `rggen_ral_create_reg_model(register_5, '{}, 8'h50, "RW", 0, "g_register_5.u_register")
          `rggen_ral_create_reg_model(register_6, '{}, 8'h60, "RW", 0, "g_register_6.u_register")
          `rggen_ral_create_reg_model(register_7, '{}, 8'h70, "RO", 0, "g_register_7.u_register")
          `rggen_ral_create_reg_model(register_8, '{}, 8'h80, "WO", 0, "g_register_8.u_register")
        CODE
      end
    end

    describe '#generate_code' do
      it 'レジスタレベルのRALモデルの定義を出力する' do
        expect(registers[0]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_0_reg_model extends rggen_ral_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, "RW", 0, 1'h0, 1)
            endfunction
          endclass
        CODE

        expect(registers[1]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_1_reg_model extends rggen_ral_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, "RW", 0, 1'h0, 1)
            endfunction
          endclass
        CODE

        expect(registers[2]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_2_reg_model extends rggen_ral_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, "RW", 0, 1'h0, 1)
            endfunction
          endclass
        CODE

        expect(registers[3]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_3_reg_model extends rggen_ral_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 32, "RW", 0, 32'h00000000, 1)
            endfunction
          endclass
        CODE

        expect(registers[4]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_4_reg_model extends rggen_ral_reg;
            rand rggen_ral_field bit_field_0[4];
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0[0], 4, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[1], 12, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[2], 20, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[3], 28, 4, "RW", 0, 4'h0, 1)
            endfunction
          endclass
        CODE

        expect(registers[5]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_5_reg_model extends rggen_ral_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 64, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 32, 1, "RW", 0, 1'h0, 1)
            endfunction
          endclass
        CODE

        expect(registers[6]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_6_reg_model extends rggen_ral_reg;
            rand rggen_ral_field bit_field_0[8];
            function new(string name);
              super.new(name, 64, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0[0], 4, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[1], 12, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[2], 20, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[3], 28, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[4], 36, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[5], 44, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[6], 52, 4, "RW", 0, 4'h0, 1)
              `rggen_ral_create_field_model(bit_field_0[7], 60, 4, "RW", 0, 4'h0, 1)
            endfunction
          endclass
        CODE

        expect(registers[7]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_7_reg_model extends rggen_ral_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, "RO", 1, 1'h0, 0)
            endfunction
          endclass
        CODE

        expect(registers[8]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_8_reg_model extends rggen_ral_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, "WO", 0, 1'h0, 1)
            endfunction
          endclass
        CODE
      end
    end
  end
end
