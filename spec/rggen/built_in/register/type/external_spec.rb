# frozen_string_literal: true

RSpec.describe 'register/type/external' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width])
    RgGen.enable(:register, [:type, :size])
    RgGen.enable(:register, :type, :external)
    RgGen.enable(:bit_field, :name)
  end

  describe 'register map' do
    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    def create_registers(&block)
      configuration = create_configuration(bus_width: 32, address_width: 16)
      register_map = create_register_map(configuration) do
        register_block(&block)
      end
      register_map.registers
    end

    specify 'レジスタ型は:external' do
      registers = create_registers do
        register { type :external }
      end
      expect(registers[0].type).to eq :external
    end

    specify 'アクセス属性は読み書き可能' do
      registers = create_registers do
        register { type :external }
      end
      expect(registers[0]).to be_readable.and be_writable
    end

    it 'ビットフィールドを持たない' do
      registers = create_registers do
        register do
          type :external
          bit_field { name :foo }
          bit_field { name :bar }
        end
      end
      expect(registers[0].bit_fields).to be_empty
    end

    it '配列レジスタではない' do
      registers = create_registers do
        register { type :external }
        register { type :external; size [1] }
        register { type :external; size [16] }
      end
      expect(registers[0]).not_to be_array
      expect(registers[1]).not_to be_array
      expect(registers[2]).not_to be_array
    end

    it '単一サイズ定義のみ対応している' do
      expect {
        create_registers do
          register { type :external; size [1, 1] }
        end
      }.to raise_register_map_error 'external register type supports single size definition only'
    end
  end

  describe 'sv rtl' do
    include_context 'sv rtl common'

    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:global, :fold_sv_interface_port)
      RgGen.enable(:register_block, [:name, :byte_size])
      RgGen.enable(:register, [:name, :offset_address])
      RgGen.enable(:register_block, :sv_rtl_top)
      RgGen.enable(:register, :sv_rtl_top)
    end

    after(:all) do
      RgGen.disable(:global, :fold_sv_interface_port)
      RgGen.disable(:register_block, [:name, :byte_size])
      RgGen.disable(:register, [:name, :offset_address])
      RgGen.disable(:register_block, :sv_rtl_top)
      RgGen.disable(:register, :sv_rtl_top)
    end

    def create_registers(fold_sv_interface_port, &body)
      configuration = create_configuration(fold_sv_interface_port: fold_sv_interface_port)
      create_sv_rtl(configuration, &body).registers
    end

    context 'fold_sv_interface_portが有効になっている場合' do
      let(:register) do
        registers = create_registers(true) do
          name 'block_0'
          byte_size 256
          register { name 'register_0'; offset_address 0x00; type :external; size [1] }
        end
        registers.first
      end

      it 'インターフェースポート#bus_ifを持つ' do
        expect(register)
          .to have_interface_port :register_block, :bus_if, {
            name: 'register_0_bus_if',
            interface_type: 'rggen_bus_if',
            modport: 'master'
          }
      end

      specify '#bus_ifは個別ポートに展開されない' do
        expect(register)
          .to not_have_port :register_block, :valid, {
            name: 'o_register_0_valid',
            data_type: :logic,
            direction: :output,
            width: 1
          }
        expect(register)
          .to not_have_port :register_block, :address, {
            name: 'o_register_0_address',
            data_type: :logic,
            direction: :output,
            width: 8
          }
        expect(register)
          .to not_have_port :register_block, :write, {
            name: 'o_register_0_write',
            data_type: :logic,
            direction: :output,
            width: 1
          }
        expect(register)
          .to not_have_port :register_block, :write_data, {
            name: 'o_register_0_data',
            data_type: :logic,
            direction: :output,
            width: 32
          }
        expect(register)
          .to not_have_port :register_block, :strobe, {
            name: 'o_register_0_strobe',
            data_type: :logic,
            direction: :output,
            width: 4
          }
        expect(register)
          .to not_have_port :register_block, :ready, {
            name: 'i_register_0_ready',
            data_type: :logic,
            direction: :input,
            width: 1
          }
        expect(register)
          .to not_have_port :register_block, :status, {
            name: 'i_register_0_status',
            data_type: :logic,
            direction: :input,
            width: 2
          }
        expect(register)
          .to not_have_port :register_block, :read_data, {
            name: 'i_register_0_data',
            data_type: :logic,
            direction: :input,
            width: 32
          }
      end
    end

    context 'fold_sv_interface_portが無効になっている場合' do
      let(:register) do
        registers = create_registers(false) do
          name 'block_0'
          byte_size 256
          register { name 'register_0'; offset_address 0x00; type :external; size [1] }
        end
        registers.first
      end

      it '個別ポートに展開された#bus_ifを持つ' do
        expect(register)
          .to have_port :register_block, :valid, {
            name: 'o_register_0_valid',
            data_type: :logic,
            direction: :output,
            width: 1
          }
        expect(register)
          .to have_port :register_block, :address, {
            name: 'o_register_0_address',
            data_type: :logic,
            direction: :output,
            width: 8
          }
        expect(register)
          .to have_port :register_block, :write, {
            name: 'o_register_0_write',
            data_type: :logic,
            direction: :output,
            width: 1
          }
        expect(register)
          .to have_port :register_block, :write_data, {
            name: 'o_register_0_data',
            data_type: :logic,
            direction: :output,
            width: 32
          }
        expect(register)
          .to have_port :register_block, :strobe, {
            name: 'o_register_0_strobe',
            data_type: :logic,
            direction: :output,
            width: 4
          }
        expect(register)
          .to have_port :register_block, :ready, {
            name: 'i_register_0_ready',
            data_type: :logic,
            direction: :input,
            width: 1
          }
        expect(register)
          .to have_port :register_block, :status, {
            name: 'i_register_0_status',
            data_type: :logic,
            direction: :input,
            width: 2
          }
        expect(register)
          .to have_port :register_block, :read_data, {
            name: 'i_register_0_data',
            data_type: :logic,
            direction: :input,
            width: 32
          }
      end

      it 'rggen_bus_ifのインスタンスを持つ' do
        expect(register)
          .to have_interface :register, :bus_if, {
            name: 'bus_if',
            interface_type: 'rggen_bus_if',
            parameter_values: [8, 32]
          }
      end
    end

    describe '#generate_code' do
      it 'rggen_exernal_registerをインスタンスするコードを出力する' do
        registers = create_registers(true) do
          name 'block_0'
          byte_size 256
          register { name 'register_0'; offset_address 0x00; type :external; size [1] }
          register { name 'register_1'; offset_address 0x80; type :external; size [32] }
        end

        expect(registers[0]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_external_register #(
            .ADDRESS_WIDTH  (8),
            .BUS_WIDTH      (32),
            .START_ADDRESS  (8'h00),
            .END_ADDRESS    (8'h03)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[0]),
            .bus_if       (register_0_bus_if)
          );
        CODE

        expect(registers[1]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_external_register #(
            .ADDRESS_WIDTH  (8),
            .BUS_WIDTH      (32),
            .START_ADDRESS  (8'h80),
            .END_ADDRESS    (8'hff)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[1]),
            .bus_if       (register_1_bus_if)
          );
        CODE

        registers = create_registers(false) do
          name 'block_0'
          byte_size 256
          register { name 'register_0'; offset_address 0x00; type :external; size [1] }
          register { name 'register_1'; offset_address 0x80; type :external; size [32] }
        end

        expect(registers[0]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_external_register #(
            .ADDRESS_WIDTH  (8),
            .BUS_WIDTH      (32),
            .START_ADDRESS  (8'h00),
            .END_ADDRESS    (8'h03)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[0]),
            .bus_if       (bus_if)
          );
          assign o_register_0_valid = bus_if.valid;
          assign o_register_0_address = bus_if.address;
          assign o_register_0_write = bus_if.write;
          assign o_register_0_data = bus_if.write_data;
          assign o_register_0_strobe = bus_if.strobe;
          assign bus_if.ready = i_register_0_ready;
          assign bus_if.status = rggen_status'(i_register_0_status);
          assign bus_if.read_data = i_register_0_data;
        CODE

        expect(registers[1]).to generate_code(:register, :top_down, <<~'CODE')
          rggen_external_register #(
            .ADDRESS_WIDTH  (8),
            .BUS_WIDTH      (32),
            .START_ADDRESS  (8'h80),
            .END_ADDRESS    (8'hff)
          ) u_register (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .register_if  (register_if[1]),
            .bus_if       (bus_if)
          );
          assign o_register_1_valid = bus_if.valid;
          assign o_register_1_address = bus_if.address;
          assign o_register_1_write = bus_if.write;
          assign o_register_1_data = bus_if.write_data;
          assign o_register_1_strobe = bus_if.strobe;
          assign bus_if.ready = i_register_1_ready;
          assign bus_if.status = rggen_status'(i_register_1_status);
          assign bus_if.read_data = i_register_1_data;
        CODE
      end
    end
  end
end
