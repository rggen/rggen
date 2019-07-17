# frozen_string_literal: true

RSpec.describe 'register_block/protocol/apb' do
  include_context 'configuration common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width, :fold_sv_interface_port])
    RgGen.enable(:register_block, :protocol)
    RgGen.enable(:register_block, :protocol, [:apb])
  end

  describe 'configuration' do
    specify 'プロトコル名は:apb' do
      configuration = create_configuration(protocol: :apb)
      expect(configuration).to have_property(:protocol, :apb)
    end

    it '32ビットを超えるバス幅に対応しない' do
      [8, 16, 32].each do |bus_width|
        expect {
          create_configuration(bus_width: bus_width, protocol: :apb)
        }.not_to raise_error
      end

      [64, 128, 256].each do |bus_width|
        expect {
          create_configuration(bus_width: bus_width, protocol: :apb)
        }.to raise_configuration_error "bus width over 32 bit is not supported: #{bus_width}"
      end
    end

    it '32ビットを超えるアドレス幅に対応しない' do
      [2, 32, rand(3..31)].each do |address_width|
        expect {
          create_configuration(address_width: address_width, protocol: :apb)
        }.not_to raise_error
      end

      [33, 34, rand(35..64)].each do |address_width|
        expect {
          create_configuration(address_width: address_width, protocol: :apb)
        }.to raise_configuration_error "address width over 32 bit is not supported: #{address_width}"
      end
    end
  end

  describe 'sv rtl' do
    include_context 'sv rtl common'

    before(:all) do
      RgGen.enable(:register_block, [:name, :byte_size])
      RgGen.enable(:register, [:name, :offset_address, :size, :type])
      RgGen.enable(:register, :type, :external)
      RgGen.enable(:register_block, :sv_rtl_top)
    end

    let(:address_width) { 16 }

    let(:bus_width) { 32 }

    def create_register_block(fold_sv_interface_port, &body)
      configuration = create_configuration(
        address_width: address_width,
        bus_width: bus_width,
        fold_sv_interface_port: fold_sv_interface_port,
        protocol: :apb
      )
      create_sv_rtl(configuration, &body).register_blocks.first
    end

    context 'fold_sv_interface_portが有効になっている場合' do
      let(:register_block) do
        create_register_block(true) do
          name 'block_0'
          byte_size 256
          register { name 'register_0'; offset_address 0x00; size [1]; type :external }
        end
      end

      it 'インターフェースポート#apb_ifを持つ' do
        expect(register_block)
          .to have_interface_port :register_block, :apb_if, {
            name: 'apb_if',
            interface_type: 'rggen_apb_if',
            modport: 'slave'
          }
      end

      specify '#apb_ifは個別ポートに展開されない' do
        expect(register_block)
          .to not_have_port :register_block, :psel, {
            name: 'i_psel',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :penable, {
            name: 'i_penable',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :paddr, {
            name: 'i_paddr',
            direction: :input,
            data_type: :logic,
            width: address_width
          }
        expect(register_block)
          .to not_have_port :register_block, :pprot, {
            name: 'i_pprot',
            direction: :input,
            data_type: :logic,
            width: 3
          }
        expect(register_block)
          .to not_have_port :register_block, :pwrite, {
            name: 'i_pwrite',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :pstrb, {
            name: 'i_pstrb',
            direction: :input,
            data_type: :logic,
            width: bus_width / 8
          }
        expect(register_block)
          .to not_have_port :register_block, :pwdata, {
            name: 'i_pwdata',
            direction: :input,
            data_type: :logic,
            width: bus_width
          }
        expect(register_block)
          .to not_have_port :register_block, :pready, {
            name: 'o_pready',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :prdata, {
            name: 'o_prdata',
            direction: :output,
            data_type: :logic,
            width: bus_width
          }
        expect(register_block)
          .to not_have_port :register_block, :pslverr, {
            name: 'o_pslverr',
            direction: :output,
            data_type: :logic,
            width: 1
          }
      end
    end

    context 'fold_sv_interface_portが無効になっている場合' do
      let(:register_block) do
        create_register_block(false) do
          name 'block_0'
          byte_size 256
          register { name 'register_0'; offset_address 0x00; size [1]; type :external }
        end
      end

      it '個別ポートに展開された#apb_ifを持つ' do
        expect(register_block)
          .to have_port :register_block, :psel, {
            name: 'i_psel',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :penable, {
            name: 'i_penable',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :paddr, {
            name: 'i_paddr',
            direction: :input,
            data_type: :logic,
            width: address_width
          }
        expect(register_block)
          .to have_port :register_block, :pprot, {
            name: 'i_pprot',
            direction: :input,
            data_type: :logic,
            width: 3
          }
        expect(register_block)
          .to have_port :register_block, :pwrite, {
            name: 'i_pwrite',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :pstrb, {
            name: 'i_pstrb',
            direction: :input,
            data_type: :logic,
            width: bus_width / 8
          }
        expect(register_block)
          .to have_port :register_block, :pwdata, {
            name: 'i_pwdata',
            direction: :input,
            data_type: :logic,
            width: bus_width
          }
        expect(register_block)
          .to have_port :register_block, :pready, {
            name: 'o_pready',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :prdata, {
            name: 'o_prdata',
            direction: :output,
            data_type: :logic,
            width: bus_width
          }
        expect(register_block)
          .to have_port :register_block, :pslverr, {
            name: 'o_pslverr',
            direction: :output,
            data_type: :logic,
            width: 1
          }
      end

      it 'rggen_apb_ifのインスタンス#apb_ifを持つ' do
        expect(register_block)
          .to have_interface :register_block, :apb_if, {
            name: 'apb_if',
            interface_type: 'rggen_apb_if',
            parameter_values: [address_width, bus_width]
          }
      end
    end

    describe '#generate_code' do
      it 'rggen_apb_adapterをインスタンスするコードを生成する' do
        register_block = create_register_block(true) do
          name 'block_0'
          byte_size 256
          register { name 'register_0'; offset_address 0x00; size [1]; type :external }
          register { name 'register_1'; offset_address 0x10; size [1]; type :external }
          register { name 'register_2'; offset_address 0x20; size [1]; type :external }
        end

        expect(register_block).to generate_code(:register_block, :top_down, <<~'CODE')
          rggen_apb_adapter #(
            .ADDRESS_WIDTH  (8),
            .BUS_WIDTH      (32),
            .REGISTERS      (3)
          ) u_adapter (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .apb_if       (apb_if),
            .register_if  (register_if)
          );
        CODE

        register_block = create_register_block(false) do
          name 'block_0'
          byte_size 256
          register { name 'register_0'; offset_address 0x00; size [1]; type :external }
          register { name 'register_1'; offset_address 0x10; size [1]; type :external }
          register { name 'register_2'; offset_address 0x20; size [1]; type :external }
        end

        expect(register_block).to generate_code(:register_block, :top_down, <<~'CODE')
          rggen_apb_adapter #(
            .ADDRESS_WIDTH  (8),
            .BUS_WIDTH      (32),
            .REGISTERS      (3)
          ) u_adapter (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .apb_if       (apb_if),
            .register_if  (register_if)
          );
          assign apb_if.psel = i_psel;
          assign apb_if.penable = i_penable;
          assign apb_if.paddr = i_paddr;
          assign apb_if.pprot = i_pprot;
          assign apb_if.pwrite = i_pwrite;
          assign apb_if.pstrb = i_pstrb;
          assign apb_if.pwdata = i_pwdata;
          assign o_pready = apb_if.pready;
          assign o_prdata = apb_if.prdata;
          assign o_pslverr = apb_if.pslverr;
        CODE
      end
    end
  end
end
