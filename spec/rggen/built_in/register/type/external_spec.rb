# frozen_string_literal: true

RSpec.describe 'register/type/external' do
  include_context 'clean-up builder'
  include_context 'register map common'

  describe 'register map' do
    before(:all) do
      RgGen.enable(:global, [:bus_width, :address_width])
      RgGen.enable(:register, [:type, :size])
      RgGen.enable(:register, :type, :external)
      RgGen.enable(:bit_field, :name)
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
end
