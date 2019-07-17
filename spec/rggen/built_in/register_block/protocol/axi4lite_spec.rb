# frozen_string_literal: true

RSpec.describe 'register_block/protocol/apb' do
  include_context 'configuration common'
  include_context 'clean-up builder'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width, :fold_sv_interface_port])
    RgGen.enable(:register_block, :protocol)
    RgGen.enable(:register_block, :protocol, [:axi4lite])
  end

  describe 'configuration' do
    specify 'プロトコル名は:axi4lite' do
      configuration = create_configuration(protocol: :axi4lite)
      expect(configuration).to have_property(:protocol, :axi4lite)
    end

    specify '32/64ビット以外のバス幅は未対応' do
      [32, 64].each do |bus_width|
        expect {
          create_configuration(bus_width: bus_width, protocol: :axi4lite)
        }.not_to raise_error
      end

      [8, 16, 128, 256].each do |bus_width|
        expect {
          create_configuration(bus_width: bus_width, protocol: :axi4lite)
        }.to raise_configuration_error "bus width eigher 32 bit or 64 bit is only supported: #{bus_width}"
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
        protocol: :axi4lite
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

      it 'インターフェースポート#axi4lite_ifを持つ' do
        expect(register_block)
          .to have_interface_port :register_block, :axi4lite_if, {
            name: 'axi4lite_if',
            interface_type: 'rggen_axi4lite_if',
            modport: 'slave'
          }
      end

      specify '#axi4lite_ifは個別ポートに展開されない' do
        expect(register_block)
          .to not_have_port :register_block, :awvalid, {
            name: 'i_awvalid',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :awready, {
            name: 'o_awready',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :awaddr, {
            name: 'i_awaddr',
            direction: :input,
            data_type: :logic,
            width: address_width
          }
        expect(register_block)
          .to not_have_port :register_block, :awprot, {
            name: 'i_awprot',
            direction: :input,
            data_type: :logic,
            width: 3
          }
        expect(register_block)
          .to not_have_port :register_block, :wvalid, {
            name: 'i_wvalid',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :wready, {
            name: 'o_wready',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :wdata, {
            name: 'i_wdata',
            direction: :input,
            data_type: :logic,
            width: bus_width
          }
        expect(register_block)
          .to not_have_port :register_block, :wstrb, {
            name: 'i_wstrb',
            direction: :input,
            data_type: :logic,
            width: bus_width / 8
          }
        expect(register_block)
          .to not_have_port :register_block, :bvalid, {
            name: 'o_bvalid',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :bready, {
            name: 'i_bready',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :bresp, {
            name: 'o_bresp',
            direction: :output,
            data_type: :logic,
            width: 2
          }
        expect(register_block)
          .to not_have_port :register_block, :arvalid, {
            name: 'i_arvalid',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :arready, {
            name: 'o_arready',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :araddr, {
            name: 'i_araddr',
            direction: :input,
            data_type: :logic,
            width: address_width
          }
        expect(register_block)
          .to not_have_port :register_block, :arprot, {
            name: 'i_arprot',
            direction: :input,
            data_type: :logic,
            width: 3
          }
        expect(register_block)
          .to not_have_port :register_block, :rvalid, {
            name: 'o_rvalid',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :rready, {
            name: 'i_rready',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to not_have_port :register_block, :rdata, {
            name: 'o_rdata',
            direction: :output,
            data_type: :logic,
            width: bus_width
          }
        expect(register_block)
          .to not_have_port :register_block, :rresp, {
            name: 'o_rresp',
            direction: :output,
            data_type: :input,
            width: 2
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

      it '個別ポートに展開された#axi4lite_ifを持つ' do
        expect(register_block)
          .to have_port :register_block, :awvalid, {
            name: 'i_awvalid',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :awready, {
            name: 'o_awready',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :awaddr, {
            name: 'i_awaddr',
            direction: :input,
            data_type: :logic,
            width: address_width
          }
        expect(register_block)
          .to have_port :register_block, :awprot, {
            name: 'i_awprot',
            direction: :input,
            data_type: :logic,
            width: 3
          }
        expect(register_block)
          .to have_port :register_block, :wvalid, {
            name: 'i_wvalid',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :wready, {
            name: 'o_wready',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :wdata, {
            name: 'i_wdata',
            direction: :input,
            data_type: :logic,
            width: bus_width
          }
        expect(register_block)
          .to have_port :register_block, :wstrb, {
            name: 'i_wstrb',
            direction: :input,
            data_type: :logic,
            width: bus_width / 8
          }
        expect(register_block)
          .to have_port :register_block, :bvalid, {
            name: 'o_bvalid',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :bready, {
            name: 'i_bready',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :bresp, {
            name: 'o_bresp',
            direction: :output,
            data_type: :logic,
            width: 2
          }
        expect(register_block)
          .to have_port :register_block, :arvalid, {
            name: 'i_arvalid',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :arready, {
            name: 'o_arready',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :araddr, {
            name: 'i_araddr',
            direction: :input,
            data_type: :logic,
            width: address_width
          }
        expect(register_block)
          .to have_port :register_block, :arprot, {
            name: 'i_arprot',
            direction: :input,
            data_type: :logic,
            width: 3
          }
        expect(register_block)
          .to have_port :register_block, :rvalid, {
            name: 'o_rvalid',
            direction: :output,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :rready, {
            name: 'i_rready',
            direction: :input,
            data_type: :logic,
            width: 1
          }
        expect(register_block)
          .to have_port :register_block, :rdata, {
            name: 'o_rdata',
            direction: :output,
            data_type: :logic,
            width: bus_width
          }
        expect(register_block)
          .to have_port :register_block, :rresp, {
            name: 'o_rresp',
            direction: :output,
            data_type: :logic,
            width: 2
          }
      end

      it 'rggen_ax4lite_ifのインスタンス#apb_ifを持つ' do
        expect(register_block)
          .to have_interface :register_block, :axi4lite_if, {
            name: 'axi4lite_if',
            interface_type: 'rggen_axi4lite_if',
            parameter_values: [address_width, bus_width]
          }
      end
    end

    it 'パラメータ#write_firstを持つ' do
      register_block = create_register_block([true, false].sample) do
        name 'block_0'
        byte_size 256
        register { name 'register_0'; offset_address 0x00; size [1]; type :external }
      end

      expect(register_block)
        .to have_parameter :register_block, :write_first, {
          name: 'WRITE_FIRST',
          parameter_type: :parameter,
          data_type: :bit,
          default: 1
        }
    end

    describe '#generate_code' do
      it 'rggen_axi4lite_adapterをインスタンスするコードを生成する' do
        register_block = create_register_block(true) do
          name 'block_0'
          byte_size 256
          register { name 'register_0'; offset_address 0x00; size [1]; type :external }
          register { name 'register_1'; offset_address 0x10; size [1]; type :external }
          register { name 'register_2'; offset_address 0x20; size [1]; type :external }
        end

        expect(register_block).to generate_code(:register_block, :top_down, <<~'CODE')
          rggen_axi4lite_adapter #(
            .ADDRESS_WIDTH  (8),
            .BUS_WIDTH      (32),
            .REGISTERS      (3),
            .WRITE_FIRST    (WRITE_FIRST)
          ) u_adapter (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .axi4lite_if  (axi4lite_if),
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
          rggen_axi4lite_adapter #(
            .ADDRESS_WIDTH  (8),
            .BUS_WIDTH      (32),
            .REGISTERS      (3),
            .WRITE_FIRST    (WRITE_FIRST)
          ) u_adapter (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .axi4lite_if  (axi4lite_if),
            .register_if  (register_if)
          );
          assign axi4lite_if.awvalid = i_awvalid;
          assign o_awready = axi4lite_if.awready;
          assign axi4lite_if.awaddr = i_awaddr;
          assign axi4lite_if.awprot = i_awprot;
          assign axi4lite_if.wvalid = i_wvalid;
          assign o_wready = axi4lite_if.wready;
          assign axi4lite_if.wdata = i_wdata;
          assign axi4lite_if.wstrb = i_wstrb;
          assign o_bvalid = axi4lite_if.bvalid;
          assign axi4lite_if.bready = i_bready;
          assign o_bresp = axi4lite_if.bresp;
          assign axi4lite_if.arvalid = i_arvalid;
          assign o_arready = axi4lite_if.arready;
          assign axi4lite_if.araddr = i_araddr;
          assign axi4lite_if.arprot = i_arprot;
          assign o_rvalid = axi4lite_if.rvalid;
          assign axi4lite_if.rready = i_rready;
          assign o_rdata = axi4lite_if.rdata;
          assign o_rresp = axi4lite_if.rresp;
        CODE
      end
    end
  end
end
