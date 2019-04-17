# frozen_string_literal: true

RSpec.describe 'register_block/name' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register_block, :name)
  end

  describe '#name' do
    let(:names) do
      random_strings(/[_a-z][_a-z0-9]*/i, 4)
    end

    let(:register_map) do
      create_register_map do
        register_block { name names[0] }
        register_block { name names[1] }
        register_block { name names[2] }
        register_block { name names[3] }
      end
    end

    it '入力されたレジスタブロック名を返す' do
      expect(register_map.register_blocks[0]).to have_property(:name, names[0])
      expect(register_map.register_blocks[1]).to have_property(:name, names[1])
      expect(register_map.register_blocks[2]).to have_property(:name, names[2])
      expect(register_map.register_blocks[3]).to have_property(:name, names[3])
    end
  end

  describe 'エラーチェック' do
    context 'レジスタブロック名に不適格な入力の場合' do
      it 'RegisterMapErrorを起こす' do
        [
          '',
          random_string(/[0-9][a-z_]/i),
          random_string(/[a-z_][[:punct:]&&[^_]][0-9a-z_]/i),
          random_string(/[a-z_]\s+[a-z_]/i)
        ].each do |illegal_name|
          expect {
            create_register_map do
              register_block { name illegal_name }
            end
          }.to raise_register_map_error("illegal input value for register block name: #{illegal_name.inspect}")
        end
      end
    end

    context 'レジスタブロック名の重複がある場合' do
      it 'RegisterMapErrorを起こす' do
        expect {
          create_register_map do
            register_block { name :foo }
            register_block { name :foo }
          end
        }.to raise_register_map_error('duplicated register block name: foo')
      end
    end
  end
end
