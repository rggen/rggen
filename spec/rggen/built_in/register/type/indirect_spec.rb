# frozen_string_literal: true

RSpec.describe 'register/type/indirect' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width, :array_port_format])
    RgGen.enable(:register_block, [:byte_size])
    RgGen.enable(:register, [:name, :offset_address, :size, :type])
    RgGen.enable(:register, :type, [:indirect])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :reference, :type])
    RgGen.enable(:bit_field, :type, [:ro, :rw, :wo, :reserved])
  end

  describe 'register map' do
    before(:all) do
      delete_configuration_factory
      delete_register_map_factory
    end

    def create_registers(&block)
      register_map = create_register_map do
        register_block do
          byte_size 256
          instance_eval(&block)
        end
      end
      register_map.registers
    end

    specify 'レジスタ型は:indirect' do
      registers = create_registers do
        register do
          name :foo
          offset_address 0x0
          type [:indirect, ['bar.bar_0', 0]]
          bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
        register do
          name :bar
          offset_address 0x04
          bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
      end
      expect(registers.first).to have_property(:type, :indirect)
    end

    specify '#sizeに依らず、#byte_sizeは#byte_widthを示す' do
      registers = create_registers do
        register do
          name :foo
          offset_address 0x0
          type [:indirect, ['baz.baz_0', 0]]
          bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
        register do
          name :bar
          offset_address 0x0
          type [:indirect, ['baz.baz_0', 1]]
          bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
        end
        register do
          name :baz
          offset_address 0x8
          bit_field { name :baz_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
      end
      expect(registers[0]).to have_property(:byte_size, 4)
      expect(registers[1]).to have_property(:byte_size, 8)

      registers = create_registers do
        register do
          name :foo
          offset_address 0x0
          size 2
          type [:indirect, 'baz.baz_0', ['baz.baz_1', 0]]
          bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
        register do
          name :bar
          offset_address 0x0
          size 3
          type [:indirect, 'baz.baz_0', ['baz.baz_1', 1]]
          bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
        end
        register do
          name :baz
          offset_address 0x8
          bit_field { name :baz_0; bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
          bit_field { name :baz_1; bit_assignment lsb: 2, width: 1; type :rw; initial_value 0 }
        end
      end
      expect(registers[0]).to have_property(:byte_size, 4)
      expect(registers[1]).to have_property(:byte_size, 8)

      registers = create_registers do
        register do
          name :foo
          offset_address 0x0
          size [2, 3]
          type [:indirect, 'baz.baz_0', 'baz.baz_1', ['baz.baz_2', 0]]
          bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
        end
        register do
          name :bar
          offset_address 0x0
          size [3, 4]
          type [:indirect, 'baz.baz_0', 'baz.baz_1', ['baz.baz_2', 1]]
          bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
        end
        register do
          name :baz
          offset_address 0x8
          bit_field { name :baz_0; bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
          bit_field { name :baz_1; bit_assignment lsb: 2, width: 3; type :rw; initial_value 0 }
          bit_field { name :baz_2; bit_assignment lsb: 5, width: 1; type :rw; initial_value 0 }
        end
      end
      expect(registers[0]).to have_property(:byte_size, 4)
      expect(registers[1]).to have_property(:byte_size, 8)
    end

    describe '#index_entries' do
      it 'オプショで指定されたインデックス一覧を返す' do
        registers = create_registers do
          register do
            name :foo
            offset_address 0x0
            type [:indirect, ['fizz.fizz_2', 0]]
            bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
          register do
            name :bar
            offset_address 0x00
            size [2]
            type [:indirect, 'fizz.fizz_1', ['fizz.fizz_2', 1]]
            bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
          register do
            name :baz
            offset_address 0x00
            size [2, 3]
            type [:indirect, 'fizz.fizz_0', 'fizz.fizz_1', ['fizz.fizz_2', 2]]
            bit_field { name :baz_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
          register do
            name :qux
            offset_address 0x04
            size [2]
            type [:indirect, 'buzz', ['fizz_buzz', 0]]
            bit_field { name :qux_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
          register do
            name :fizz
            offset_address 0x08
            bit_field { name :fizz_0; bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
            bit_field { name :fizz_1; bit_assignment lsb: 2, width: 2; type :rw; initial_value 0 }
            bit_field { name :fizz_2; bit_assignment lsb: 4, width: 2; type :rw; initial_value 0 }
          end
          register do
            name :buzz
            offset_address 0x0C
            bit_field { bit_assignment lsb: 0, with: 2; type :rw; initial_value 0 }
          end
          register do
            name :fizz_buzz
            offset_address 0x10
            bit_field { bit_assignment lsb: 0, with: 2; type :rw; initial_value 0 }
          end
        end

        expect(registers[0].index_entries.map(&:to_h)).to match([
          { name: 'fizz.fizz_2', value: 0 }
        ])
        expect(registers[1].index_entries.map(&:to_h)).to match([
          { name: 'fizz.fizz_1', value: nil },
          { name: 'fizz.fizz_2', value: 1 }
        ])
        expect(registers[2].index_entries.map(&:to_h)).to match([
          { name: 'fizz.fizz_0', value: nil },
          { name: 'fizz.fizz_1', value: nil },
          { name: 'fizz.fizz_2', value: 2 }
        ])
        expect(registers[3].index_entries.map(&:to_h)).to match([
          { name: 'buzz', value: nil },
          { name: 'fizz_buzz', value: 0 }
        ])
      end

      specify '文字列でインデックスを指定することができる' do
        registers = create_registers do
          register do
            name :foo
            offset_address 0x0
            type 'indirect: qux.qux_2:0'
            bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
          register do
            name :bar
            offset_address 0x0
            size [2]
            type 'indirect: qux.qux_1, qux.qux_2:1'
            bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
          register do
            name :baz
            offset_address 0x0
            size [2, 3]
            type 'indirect: qux.qux_0, qux.qux_1, qux.qux_2: 2'
            bit_field { name :baz_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
          register do
            name :qux
            offset_address 0x4
            bit_field { name :qux_0; bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
            bit_field { name :qux_1; bit_assignment lsb: 2, width: 2; type :rw; initial_value 0 }
            bit_field { name :qux_2; bit_assignment lsb: 4, width: 2; type :rw; initial_value 0 }
          end
        end

        expect(registers[0].index_entries.map(&:to_h)).to match([
          { name: 'qux.qux_2', value: 0 }
        ])
        expect(registers[1].index_entries.map(&:to_h)).to match([
          { name: 'qux.qux_1', value: nil },
          { name: 'qux.qux_2', value: 1 }
        ])
        expect(registers[2].index_entries.map(&:to_h)).to match([
          { name: 'qux.qux_0', value: nil },
          { name: 'qux.qux_1', value: nil },
          { name: 'qux.qux_2', value: 2 }
        ])
      end
    end

    describe 'エラーチェック' do
      context 'インデックスの指定がない場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type :indirect
              end
            end
          }.to raise_register_map_error 'no indirect indices are given'
        end
      end

      context 'インデックス名が文字列、または、シンボルではない場合' do
        it 'RegisterMapErrorを起こす' do
          [nil, true, false, Object.new, []].each do |value|
            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x0
                  type [:indirect, value]
                end
              end
            }.to raise_register_map_error "illegal input value for indirect index: #{value.inspect}"
          end
        end
      end

      context 'フィールド名が入力パターンに一致しない場合' do
        it 'RegisterMapErrorを起こす' do
          ['0foo.foo', 'foo.0foo', 'foo.foo.0', 'foo.foo:0xef_gh', '0foo', 'foo:0xef_gh'].each do |value|
            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x0
                  type [:indirect, value]
                end
              end
            }.to raise_register_map_error "illegal input value for indirect index: #{value.inspect}"
          end
        end
      end

      context 'インデックス値が整数に変換できない場合' do
        it 'RegisterMapErrorを起こす' do
          [nil, true, false, '', '0xef_gh', Object.new].each do |value|
            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x0
                  type [:indirect, ['bar.bar_0', value]]
                end
              end
            }.to raise_register_map_error "cannot convert #{value.inspect} into indirect index value"
          end
        end
      end

      context 'インデックス指定の引数が多すぎる場合' do
        it 'RegisterMapErrorを起こす' do
          value = ['bar.bar_0', 1, nil]
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, value]
              end
            end
          }.to raise_register_map_error "too many arguments for indirect index are given: #{value}"

          value = ['bar.bar_0:0', 1]
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, value]
              end
            end
          }.to raise_register_map_error "too many arguments for indirect index are given: #{value}"

          value = ['bar.bar_0:0', nil]
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, value]
              end
            end
          }.to raise_register_map_error "too many arguments for indirect index are given: #{value}"
        end
      end

      context '同じビットフィールドが複数回使用された場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, ['bar.bar_0', 0], ['bar.bar_0', 1]]
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x04
                bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'same bit field is used as indirect index more than once: bar.bar_0'
        end
      end

      context 'インデックス用のビットフィールドが存在しない場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, ['bar.bar_1', 0]]
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x04
                bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'no such bit field for indirect index is found: bar.bar_1'

          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, ['baz.bar_0', 0]]
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x04
                bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'no such bit field for indirect index is found: baz.bar_0'
        end
      end

      context 'インデックスビットフィールドが自身のビットフィールドの場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, ['foo.foo_1', 0]]
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                bit_field { name :foo_1; bit_assignment lsb: 1; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'own bit field is not allowed for indirect index: foo.foo_1'
        end
      end

      context 'インデックスビットフィールドが配列レジスタに属している場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, ['bar.bar_0', 0]]
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x4
                size [2]
                bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'bit field of array register is not allowed for indirect index: bar.bar_0'
        end
      end

      context 'インデックスビットフィールドが連番ビットフィールドの場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, ['bar.bar_0', 0]]
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x4
                bit_field { name :bar_0; bit_assignment lsb: 0, sequence_size: 1; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'sequential bit field is not allowed for indirect index: bar.bar_0'
        end
      end

      context 'インデックスビットフィールドの属性が予約済みの場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, ['bar.bar_0', 0]]
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x4
                bit_field { name :bar_0; bit_assignment lsb: 0; type :reserved }
              end
            end
          }.to raise_register_map_error 'reserved bit field is not allowed for indirect index: bar.bar_0'
        end
      end

      context 'インデックス値がインデックスビットフィールドの幅より大きい場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                type [:indirect, ['bar.bar_0', 2]]
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x4
                bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'bit width of indirect index is not enough for index value 2: bar.bar_0'
        end
      end

      context '配列インデックスに過不足がある場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                size [1]
                type [:indirect, 'bar.bar_0', 'bar.bar_1']
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x4
                bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                bit_field { name :bar_1; bit_assignment lsb: 1; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'too many array indices are given'

          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                size [1, 2, 3]
                type [:indirect, 'bar.bar_0', 'bar.bar_1']
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x4
                bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                bit_field { name :bar_1; bit_assignment lsb: 1; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'less array indices are given'
        end
      end

      context '配列の大きさがインデックスビットフィールドの幅より大きい場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                size 3
                type [:indirect, 'bar.bar_0']
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x4
                bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'bit width of indirect index is not enough for array size 3: bar.bar_0'

          expect {
            create_registers do
              register do
                name :foo
                offset_address 0x0
                size [2, 3]
                type [:indirect, 'bar.bar_0', 'bar.bar_1']
                bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
              end
              register do
                name :bar
                offset_address 0x4
                bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                bit_field { name :bar_1; bit_assignment lsb: 1; type :rw; initial_value 0 }
              end
            end
          }.to raise_register_map_error 'bit width of indirect index is not enough for array size 3: bar.bar_1'
        end
      end

      describe 'インデックスの区別' do
        context 'インデックスが他のレジスタと区別できる場合' do
          it 'エラーを起こさない' do
            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  type [:indirect, ['baz.baz_0', 0]]
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  type [:indirect, ['baz.baz_0', 1]]
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.not_to raise_error

            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x0
                  type [:indirect, ['baz.baz_0', 0]]
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :ro }
                end
                register do
                  name :bar
                  offset_address 0x0
                  type [:indirect, ['baz.baz_0', 0]]
                  bit_field { name :bar_0; bit_assignment lsb: 0; type :wo; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x4
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.not_to raise_error

            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  size [2]
                  type [:indirect, 'baz.baz_0', ['baz.baz_2', 0]]
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  size [2]
                  type [:indirect, 'baz.baz_0', ['baz.baz_2', 1]]
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.not_to raise_error

            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  size [2]
                  type [:indirect, 'baz.baz_0', ['baz.baz_2', 0]]
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  size [2, 2]
                  type [:indirect, 'baz.baz_0', 'baz.baz_1', ['baz.baz_2', 1]]
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.not_to raise_error

            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  size [2, 2]
                  type [:indirect, 'baz.baz_0', 'baz.baz_1', ['baz.baz_2', 0]]
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  size [2, 2]
                  type [:indirect, 'baz.baz_0', 'baz.baz_1', ['baz.baz_2', 1]]
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.not_to raise_error
          end
        end

        context 'インデックスが他のレジスタと区別できない場合' do
          it 'エラーを起こさない' do
            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  type [:indirect, ['baz.baz_0', 0]]
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  type [:indirect, ['baz.baz_0', 0]]
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.to raise_register_map_error 'cannot be distinguished from other registers'

            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  type [:indirect, ['baz.baz_0', 0]]
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  type [:indirect, ['baz.baz_1', 0]]
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.to raise_register_map_error 'cannot be distinguished from other registers'

            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  size 2
                  type [:indirect, 'baz.baz_0']
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  size 2
                  type [:indirect, 'baz.baz_1']
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.to raise_register_map_error 'cannot be distinguished from other registers'

            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  size [2, 2]
                  type [:indirect, 'baz.baz_0', 'baz.baz_1']
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  size [2, 2]
                  type [:indirect, 'baz.baz_0', 'baz.baz_2']
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.to raise_register_map_error 'cannot be distinguished from other registers'

            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  size [2, 2]
                  type [:indirect, 'baz.baz_0', 'baz.baz_1', ['baz.baz_2', 0]]
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  size [2, 2]
                  type [:indirect, 'baz.baz_0', 'baz.baz_2', ['baz.baz_2', 0]]
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.to raise_register_map_error 'cannot be distinguished from other registers'

            expect {
              create_registers do
                register do
                  name :foo
                  offset_address 0x4
                  size [2, 2]
                  type [:indirect, 'baz.baz_0', 'baz.baz_1', ['baz.baz_2', 0]]
                  bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
                end
                register do
                  name :bar
                  offset_address 0x0
                  size [2, 2]
                  type [:indirect, 'baz.baz_0', 'baz.baz_2', ['baz.baz_0', 1]]
                  bit_field { name :bar_0; bit_assignment lsb: 32; type :rw; initial_value 0 }
                end
                register do
                  name :baz
                  offset_address 0x8
                  bit_field { name :baz_0; bit_assignment lsb: 0, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_1; bit_assignment lsb: 4, width: 4; type :rw; initial_value 0 }
                  bit_field { name :baz_2; bit_assignment lsb: 8, width: 4; type :rw; initial_value 0 }
                end
              end
            }.to raise_register_map_error 'cannot be distinguished from other registers'
          end
        end
      end
    end
  end

  let(:register_map_body) do
    proc do
      byte_size 256

      register do
        name 'register_0'
        offset_address 0x00
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
        bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 2; type :rw; initial_value 0 }
        bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4; type :rw; initial_value 0 }
      end

      register do
        name 'register_1'
        offset_address 0x04
        bit_field { bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
      end

      register do
        name 'register_2'
        offset_address 0x08
        bit_field { bit_assignment lsb: 0, width: 2; type :rw; initial_value 0 }
      end

      register do
        name 'register_3'
        offset_address 0x10
        type [:indirect, ['register_0.bit_field_0', 1]]
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
      end

      register do
        name 'register_4'
        offset_address 0x14
        size [2]
        type [:indirect, 'register_0.bit_field_1']
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
      end

      register do
        name 'register_5'
        offset_address 0x18
        size [2, 4]
        type [:indirect, 'register_0.bit_field_1', 'register_0.bit_field_2']
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
      end

      register do
        name 'register_6'
        offset_address 0x1c
        size [2, 4]
        type [:indirect, ['register_0.bit_field_0', 0], 'register_0.bit_field_1', 'register_0.bit_field_2']
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
      end

      register do
        name 'register_7'
        offset_address 0x20
        type [:indirect, ['register_0.bit_field_0', 0]]
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :ro }
      end

      register do
        name 'register_8'
        offset_address 0x24
        type [:indirect, ['register_0.bit_field_0', 0]]
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :wo; initial_value 0 }
      end

      register do
        name 'register_9'
        offset_address 0x28
        size [2]
        type [:indirect, 'register_1', ['register_2', 0]]
        bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
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

    let(:registers) do
      create_sv_rtl(&register_map_body).registers
    end

    it 'logic変数#indirect_indexを持つ' do
      expect(registers[3]).to have_variable(
        :register, :indirect_index,
        name: 'indirect_index', data_type: :logic, width: 1
      )

      expect(registers[4]).to have_variable(
        :register, :indirect_index,
        name: 'indirect_index', data_type: :logic, width: 2
      )

      expect(registers[5]).to have_variable(
        :register, :indirect_index,
        name: 'indirect_index', data_type: :logic, width: 6
      )

      expect(registers[6]).to have_variable(
        :register, :indirect_index,
        name: 'indirect_index', data_type: :logic, width: 7
      )
    end

    describe '#generate_code' do
      it 'rggen_indirect_registerをインスタンスするコードを出力する' do
        expect(registers[3]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[0+:1]};
          rggen_indirect_register #(
            .READABLE             (1),
            .WRITABLE             (1),
            .ADDRESS_WIDTH        (8),
            .OFFSET_ADDRESS       (8'h10),
            .BUS_WIDTH            (32),
            .DATA_WIDTH           (32),
            .VALID_BITS           (32'h00000001),
            .INDIRECT_INDEX_WIDTH (1),
            .INDIRECT_INDEX_VALUE ({1'h1})
          ) u_register (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .register_if      (register_if[3]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE

        expect(registers[4]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[8+:2]};
          rggen_indirect_register #(
            .READABLE             (1),
            .WRITABLE             (1),
            .ADDRESS_WIDTH        (8),
            .OFFSET_ADDRESS       (8'h14),
            .BUS_WIDTH            (32),
            .DATA_WIDTH           (32),
            .VALID_BITS           (32'h00000001),
            .INDIRECT_INDEX_WIDTH (2),
            .INDIRECT_INDEX_VALUE ({i[0+:2]})
          ) u_register (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .register_if      (register_if[4+i]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE

        expect(registers[5]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[8+:2], register_if[0].value[16+:4]};
          rggen_indirect_register #(
            .READABLE             (1),
            .WRITABLE             (1),
            .ADDRESS_WIDTH        (8),
            .OFFSET_ADDRESS       (8'h18),
            .BUS_WIDTH            (32),
            .DATA_WIDTH           (32),
            .VALID_BITS           (32'h00000001),
            .INDIRECT_INDEX_WIDTH (6),
            .INDIRECT_INDEX_VALUE ({i[0+:2], j[0+:4]})
          ) u_register (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .register_if      (register_if[6+4*i+j]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE

        expect(registers[6]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[0+:1], register_if[0].value[8+:2], register_if[0].value[16+:4]};
          rggen_indirect_register #(
            .READABLE             (1),
            .WRITABLE             (1),
            .ADDRESS_WIDTH        (8),
            .OFFSET_ADDRESS       (8'h1c),
            .BUS_WIDTH            (32),
            .DATA_WIDTH           (32),
            .VALID_BITS           (32'h00000001),
            .INDIRECT_INDEX_WIDTH (7),
            .INDIRECT_INDEX_VALUE ({1'h0, i[0+:2], j[0+:4]})
          ) u_register (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .register_if      (register_if[14+4*i+j]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE

        expect(registers[7]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[0+:1]};
          rggen_indirect_register #(
            .READABLE             (1),
            .WRITABLE             (0),
            .ADDRESS_WIDTH        (8),
            .OFFSET_ADDRESS       (8'h20),
            .BUS_WIDTH            (32),
            .DATA_WIDTH           (32),
            .VALID_BITS           (32'h00000001),
            .INDIRECT_INDEX_WIDTH (1),
            .INDIRECT_INDEX_VALUE ({1'h0})
          ) u_register (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .register_if      (register_if[22]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE

        expect(registers[8]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[0+:1]};
          rggen_indirect_register #(
            .READABLE             (0),
            .WRITABLE             (1),
            .ADDRESS_WIDTH        (8),
            .OFFSET_ADDRESS       (8'h24),
            .BUS_WIDTH            (32),
            .DATA_WIDTH           (32),
            .VALID_BITS           (32'h00000001),
            .INDIRECT_INDEX_WIDTH (1),
            .INDIRECT_INDEX_VALUE ({1'h0})
          ) u_register (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .register_if      (register_if[23]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE

        expect(registers[9]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[1].value[0+:2], register_if[2].value[0+:2]};
          rggen_indirect_register #(
            .READABLE             (1),
            .WRITABLE             (1),
            .ADDRESS_WIDTH        (8),
            .OFFSET_ADDRESS       (8'h28),
            .BUS_WIDTH            (32),
            .DATA_WIDTH           (32),
            .VALID_BITS           (32'h00000001),
            .INDIRECT_INDEX_WIDTH (4),
            .INDIRECT_INDEX_VALUE ({i[0+:2], 2'h0})
          ) u_register (
            .i_clk            (i_clk),
            .i_rst_n          (i_rst_n),
            .register_if      (register_if[24+i]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE
      end
    end
  end

  describe 'sv ral' do
    include_context 'sv ral common'

    let(:registers) do
      create_sv_ral(&register_map_body).registers
    end

    it 'レジスタモデル変数#ral_modelを持つ' do
      expect(registers[3]).to have_variable(
        :register_block, :ral_model,
        name: 'register_3', data_type: 'register_3_reg_model', random: true
      )
      expect(registers[4]).to have_variable(
        :register_block, :ral_model,
        name: 'register_4', data_type: 'register_4_reg_model',
        array_size: [2], array_format: :unpacked, random: true
      )
      expect(registers[5]).to have_variable(
        :register_block, :ral_model,
        name: 'register_5', data_type: 'register_5_reg_model',
        array_size: [2, 4], array_format: :unpacked, random: true
      )
      expect(registers[6]).to have_variable(
        :register_block, :ral_model,
        name: 'register_6', data_type: 'register_6_reg_model',
        array_size: [2, 4], array_format: :unpacked, random: true
      )
      expect(registers[7]).to have_variable(
        :register_block, :ral_model,
        name: 'register_7', data_type: 'register_7_reg_model', random: true
      )
      expect(registers[8]).to have_variable(
        :register_block, :ral_model,
        name: 'register_8', data_type: 'register_8_reg_model', random: true
      )
      expect(registers[9]).to have_variable(
        :register_block, :ral_model,
        name: 'register_9', data_type: 'register_9_reg_model',
        array_size: [2], array_format: :unpacked, random: true
      )
    end

    describe '#constructors' do
      it 'レジスタモデルの生成と構成を行うコードを出力する' do
        code_block = RgGen::Core::Utility::CodeUtility::CodeBlock.new
        registers[3..-1].flat_map(&:constructors).each do |constructor|
          code_block << [constructor, "\n"]
        end

        expect(code_block).to match_string(<<~'CODE')
          `rggen_ral_create_reg_model(register_3, '{}, 8'h10, RW, 1, g_register_3.u_register)
          `rggen_ral_create_reg_model(register_4[0], '{0}, 8'h14, RW, 1, g_register_4.g[0].u_register)
          `rggen_ral_create_reg_model(register_4[1], '{1}, 8'h14, RW, 1, g_register_4.g[1].u_register)
          `rggen_ral_create_reg_model(register_5[0][0], '{0, 0}, 8'h18, RW, 1, g_register_5.g[0].g[0].u_register)
          `rggen_ral_create_reg_model(register_5[0][1], '{0, 1}, 8'h18, RW, 1, g_register_5.g[0].g[1].u_register)
          `rggen_ral_create_reg_model(register_5[0][2], '{0, 2}, 8'h18, RW, 1, g_register_5.g[0].g[2].u_register)
          `rggen_ral_create_reg_model(register_5[0][3], '{0, 3}, 8'h18, RW, 1, g_register_5.g[0].g[3].u_register)
          `rggen_ral_create_reg_model(register_5[1][0], '{1, 0}, 8'h18, RW, 1, g_register_5.g[1].g[0].u_register)
          `rggen_ral_create_reg_model(register_5[1][1], '{1, 1}, 8'h18, RW, 1, g_register_5.g[1].g[1].u_register)
          `rggen_ral_create_reg_model(register_5[1][2], '{1, 2}, 8'h18, RW, 1, g_register_5.g[1].g[2].u_register)
          `rggen_ral_create_reg_model(register_5[1][3], '{1, 3}, 8'h18, RW, 1, g_register_5.g[1].g[3].u_register)
          `rggen_ral_create_reg_model(register_6[0][0], '{0, 0}, 8'h1c, RW, 1, g_register_6.g[0].g[0].u_register)
          `rggen_ral_create_reg_model(register_6[0][1], '{0, 1}, 8'h1c, RW, 1, g_register_6.g[0].g[1].u_register)
          `rggen_ral_create_reg_model(register_6[0][2], '{0, 2}, 8'h1c, RW, 1, g_register_6.g[0].g[2].u_register)
          `rggen_ral_create_reg_model(register_6[0][3], '{0, 3}, 8'h1c, RW, 1, g_register_6.g[0].g[3].u_register)
          `rggen_ral_create_reg_model(register_6[1][0], '{1, 0}, 8'h1c, RW, 1, g_register_6.g[1].g[0].u_register)
          `rggen_ral_create_reg_model(register_6[1][1], '{1, 1}, 8'h1c, RW, 1, g_register_6.g[1].g[1].u_register)
          `rggen_ral_create_reg_model(register_6[1][2], '{1, 2}, 8'h1c, RW, 1, g_register_6.g[1].g[2].u_register)
          `rggen_ral_create_reg_model(register_6[1][3], '{1, 3}, 8'h1c, RW, 1, g_register_6.g[1].g[3].u_register)
          `rggen_ral_create_reg_model(register_7, '{}, 8'h20, RO, 1, g_register_7.u_register)
          `rggen_ral_create_reg_model(register_8, '{}, 8'h24, WO, 1, g_register_8.u_register)
          `rggen_ral_create_reg_model(register_9[0], '{0}, 8'h28, RW, 1, g_register_9.g[0].u_register)
          `rggen_ral_create_reg_model(register_9[1], '{1}, 8'h28, RW, 1, g_register_9.g[1].u_register)
        CODE
      end
    end

    describe '#generate_code' do
      it 'レジスタレベルのRALモデルの定義を出力する' do
        expect(registers[3]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_3_reg_model extends rggen_ral_indirect_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, RW, 0, 1'h0, 1)
            endfunction
            function void setup_index_fields();
              setup_index_field("register_0", "bit_field_0", 1'h1);
            endfunction
          endclass
        CODE

        expect(registers[4]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_4_reg_model extends rggen_ral_indirect_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, RW, 0, 1'h0, 1)
            endfunction
            function void setup_index_fields();
              setup_index_field("register_0", "bit_field_1", array_index[0]);
            endfunction
          endclass
        CODE

        expect(registers[5]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_5_reg_model extends rggen_ral_indirect_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, RW, 0, 1'h0, 1)
            endfunction
            function void setup_index_fields();
              setup_index_field("register_0", "bit_field_1", array_index[0]);
              setup_index_field("register_0", "bit_field_2", array_index[1]);
            endfunction
          endclass
        CODE

        expect(registers[6]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_6_reg_model extends rggen_ral_indirect_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, RW, 0, 1'h0, 1)
            endfunction
            function void setup_index_fields();
              setup_index_field("register_0", "bit_field_0", 1'h0);
              setup_index_field("register_0", "bit_field_1", array_index[0]);
              setup_index_field("register_0", "bit_field_2", array_index[1]);
            endfunction
          endclass
        CODE

        expect(registers[7]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_7_reg_model extends rggen_ral_indirect_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, RO, 1, 1'h0, 0)
            endfunction
            function void setup_index_fields();
              setup_index_field("register_0", "bit_field_0", 1'h0);
            endfunction
          endclass
        CODE

        expect(registers[8]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_8_reg_model extends rggen_ral_indirect_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, WO, 0, 1'h0, 1)
            endfunction
            function void setup_index_fields();
              setup_index_field("register_0", "bit_field_0", 1'h0);
            endfunction
          endclass
        CODE

        expect(registers[9]).to generate_code(:ral_package, :bottom_up, <<~'CODE')
          class register_9_reg_model extends rggen_ral_indirect_reg;
            rand rggen_ral_field bit_field_0;
            function new(string name);
              super.new(name, 32, 0);
            endfunction
            function void build();
              `rggen_ral_create_field_model(bit_field_0, 0, 1, RW, 0, 1'h0, 1)
            endfunction
            function void setup_index_fields();
              setup_index_field("register_1", "register_1", array_index[0]);
              setup_index_field("register_2", "register_2", 2'h0);
            endfunction
          endclass
        CODE
      end
    end
  end
end
