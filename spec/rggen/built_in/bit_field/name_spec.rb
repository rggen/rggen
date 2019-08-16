# frozen_string_literal: true

RSpec.describe 'bit_field/name' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, :name)
    RgGen.enable(:bit_field, :name)
  end

  describe '#name' do
    let(:names) do
      random_strings(/[_a-z][_a-z0-9]*/i, 4)
    end

    let(:register_map) do
      create_register_map do
        register_block do
          register do
            name :register_0
            bit_field { name names[0] }
            bit_field { name names[1] }
            bit_field { name names[2] }
            bit_field { name names[3] }
          end
        end
      end
    end

    it '入力されたビットフィールド名を返す' do
      expect(register_map.bit_fields[0]).to have_property(:name, names[0])
      expect(register_map.bit_fields[1]).to have_property(:name, names[1])
      expect(register_map.bit_fields[2]).to have_property(:name, names[2])
      expect(register_map.bit_fields[3]).to have_property(:name, names[3])
    end
  end

  describe '#full_name' do
    let(:register_map) do
      create_register_map do
        register_block do
          register do
            name :register_0
            bit_field { name :bit_field_0 }
            bit_field { name :bit_field_1 }
          end
          register do
            name :register_1
            bit_field { name :bit_field_0 }
            bit_field { name :bit_field_1 }
          end
        end
      end
    end

    it 'レジスタ名を含めた階層名を返す' do
      expect(register_map.bit_fields[0]).to have_property(:full_name, 'register_0.bit_field_0')
      expect(register_map.bit_fields[1]).to have_property(:full_name, 'register_0.bit_field_1')
      expect(register_map.bit_fields[2]).to have_property(:full_name, 'register_1.bit_field_0')
      expect(register_map.bit_fields[3]).to have_property(:full_name, 'register_1.bit_field_1')
    end

    it '区切り文字を変更できる' do
      expect(register_map.bit_fields[0].full_name('/')).to eq 'register_0/bit_field_0'
      expect(register_map.bit_fields[0].full_name('_')).to eq 'register_0_bit_field_0'
    end
  end

  it '表示可能オブジェクトとして入力されたビットフィールド名を返す' do
    register_map = create_register_map do
      register_block do
        register do
          name :register_0
          bit_field { name :bit_field_0 }
          bit_field { name 'bit_field_1' }
        end
      end
    end

    expect(register_map.bit_fields[0].printables[:name]).to eq 'bit_field_0'
    expect(register_map.bit_fields[1].printables[:name]).to eq 'bit_field_1'
  end

  describe 'エラーチェック' do
    context 'ビットフィールド名が未入力の場合' do
      it 'RegisterMapErrorを起こす' do
        expect {
          create_register_map do
            register_block do
              register do
                name :register_0
                bit_field {}
              end
            end
          end
        }.to raise_register_map_error 'no bit field name is given'

        expect {
          create_register_map do
            register_block do
              register do
                name :register_0
                bit_field { name nil }
              end
            end
          end
        }.to raise_register_map_error 'no bit field name is given'

        expect {
          create_register_map do
            register_block do
              register do
                name :register_0
                bit_field { name '' }
              end
            end
          end
        }.to raise_register_map_error 'no bit field name is given'

      end
    end

    context 'ビットフィールド名が入力パターンに合致しない場合' do
      it 'RegisterMapErrorを起こす' do
        [
          random_string(/[0-9][_a-z0-9]*/i),
          random_string(/[_a-z][[:punct:]&&[^_]][_a-z0-9]/i),
          random_string(/[_a-z]\s+[_a-z]/i)
        ].each do |illegal_name|
          expect {
            create_register_map do
              register_block do
                register do
                  name :register_0
                  bit_field { name illegal_name }
                end
              end
            end
          }.to raise_register_map_error("illegal input value for bit field name: #{illegal_name.inspect}")
        end
      end
    end

    context '同一レジスタ内でビットフィールド名の重複がある場合' do
      it 'RegisterMapErrorを起こす' do
        expect {
          create_register_map do
            register_block do
              register do
                name :register_0
                bit_field { name :bit_field_0 }
                bit_field { name :bit_field_0 }
              end
            end
          end
        }.to raise_register_map_error('duplicated bit field name: bit_field_0')
      end
    end

    context '異なるレジスタ間でビットフィールド名の重複がある場合' do
      it 'RegisterMapErrorを起こす' do
        expect {
          create_register_map do
            register_block do
              register do
                name :register_0
                bit_field { name :bit_field_0 }
              end
              register do
                name :register_1
                bit_field { name :bit_field_0 }
              end
            end
          end
        }.not_to raise_error
      end
    end
  end
end
