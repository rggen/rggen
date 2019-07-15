# frozen_string_literal: true

RSpec.describe 'register/type/indirect' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:global, [:bus_width, :address_width])
    RgGen.enable(:register_block, [:byte_size])
    RgGen.enable(:register, [:name, :offset_address, :size, :type])
    RgGen.enable(:register, :type, [:indirect])
    RgGen.enable(:bit_field, [:name, :bit_assignment, :initial_value, :type])
    RgGen.enable(:bit_field, :type, [:rw, :reserved])
  end

  describe 'register map' do
    before(:all) do
      delete_configuration_facotry
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
            type [:indirect, ['qux.qux_2', 0]]
            bit_field { name :foo_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
          register do
            name :bar
            offset_address 0x0
            size [2]
            type [:indirect, 'qux.qux_1', ['qux.qux_2', 1]]
            bit_field { name :bar_0; bit_assignment lsb: 0; type :rw; initial_value 0 }
          end
          register do
            name :baz
            offset_address 0x0
            size [2, 3]
            type [:indirect, 'qux.qux_0', 'qux.qux_1', ['qux.qux_2', 2]]
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
          ['0foo.foo', 'foo.0foo', 'foo.foo.0', 'foo.foo:0xef_gh'].each do |value|
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

  describe 'sv rtl' do
    include_context 'sv rtl common'

    before(:all) do
      delete_configuration_facotry
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:global, :array_port_format)
      RgGen.enable(:register_block, :name)
      RgGen.enable(:register_block, :sv_rtl_top)
      RgGen.enable(:register, :sv_rtl_top)
      RgGen.enable(:bit_field, :sv_rtl_top)
    end

    after(:all) do
      RgGen.disable(:global, :array_port_format)
      RgGen.disable(:register_block, :name)
      RgGen.disable(:register_block, :sv_rtl_top)
      RgGen.disable(:register, :sv_rtl_top)
      RgGen.disable(:bit_field, :sv_rtl_top)
    end

    def create_registers(&body)
      create_sv_rtl(&body).registers
    end

    it 'logic変数#indirect_indexを持つ' do
      registers = create_registers do
        name 'block_0'
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
          offset_address 0x10
          type [:indirect, ['register_0.bit_field_0', 1]]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
        end

        register do
          name 'register_2'
          offset_address 0x14
          size [2]
          type [:indirect, 'register_0.bit_field_1']
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
        end

        register do
          name 'register_3'
          offset_address 0x18
          size [2, 4]
          type [:indirect, 'register_0.bit_field_1', 'register_0.bit_field_2']
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
        end

        register do
          name 'register_4'
          offset_address 0x1c
          size [2, 4]
          type [:indirect, ['register_0.bit_field_0', 1], 'register_0.bit_field_1', 'register_0.bit_field_2']
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
        end
      end

      expect(registers[1])
        .to have_variable :register, :indirect_index, {
          name: 'indirect_index',
          data_type: :logic,
          width: 1
        }

      expect(registers[2])
        .to have_variable :register, :indirect_index, {
          name: 'indirect_index',
          data_type: :logic,
          width: 2
        }

      expect(registers[3])
        .to have_variable :register, :indirect_index, {
          name: 'indirect_index',
          data_type: :logic,
          width: 6
        }

      expect(registers[4])
        .to have_variable :register, :indirect_index, {
          name: 'indirect_index',
          data_type: :logic,
          width: 7
        }
    end

    describe '#generate_code' do
      it 'rggen_indirect_registerをインスタンスするコードを出力する' do
        registers = create_registers do
          name 'block_0'
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
            offset_address 0x10
            type [:indirect, ['register_0.bit_field_0', 1]]
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
          end

          register do
            name 'register_2'
            offset_address 0x14
            size [2]
            type [:indirect, 'register_0.bit_field_1']
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
          end

          register do
            name 'register_3'
            offset_address 0x18
            size [2, 4]
            type [:indirect, 'register_0.bit_field_1', 'register_0.bit_field_2']
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
          end

          register do
            name 'register_4'
            offset_address 0x1c
            size [2, 4]
            type [:indirect, ['register_0.bit_field_0', 0], 'register_0.bit_field_1', 'register_0.bit_field_2']
            bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
          end
        end

        expect(registers[1]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[0+:1]};
          rggen_indirect_register #(
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
            .register_if      (register_if[1]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE

        expect(registers[2]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[8+:2]};
          rggen_indirect_register #(
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
            .register_if      (register_if[2+i]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE

        expect(registers[3]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[8+:2], register_if[0].value[16+:4]};
          rggen_indirect_register #(
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
            .register_if      (register_if[4+4*i+j]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE

        expect(registers[4]).to generate_code(:register, :top_down, <<~'CODE')
          assign indirect_index = {register_if[0].value[0+:1], register_if[0].value[8+:2], register_if[0].value[16+:4]};
          rggen_indirect_register #(
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
            .register_if      (register_if[12+4*i+j]),
            .i_indirect_index (indirect_index),
            .bit_field_if     (bit_field_if)
          );
        CODE
      end
    end
  end
end
