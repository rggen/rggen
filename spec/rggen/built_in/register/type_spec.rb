# frozen_string_literal: true

RSpec.describe 'register/type' do
  include_context 'clean-up builder'
  include_context 'register map common'

  describe 'register map' do
    before(:all) do
      RgGen.define_list_item_feature(:bit_field, :type, :foo) do
        register_map { read_write }
      end
      RgGen.define_list_item_feature(:bit_field, :type, :bar) do
        register_map { read_only }
      end
      RgGen.define_list_item_feature(:bit_field, :type, :baz) do
        register_map { write_only }
      end
      RgGen.define_list_item_feature(:bit_field, :type, :qux) do
        register_map { reserved }
      end

      RgGen.enable(:global, [:bus_width, :address_width])
      RgGen.enable(:register, [:type, :size])
      RgGen.enable(:register, :type, [:foo, :bar, :baz])
      RgGen.enable(:bit_field, [:bit_assignment, :initial_value, :reference, :type])
      RgGen.enable(:bit_field, :type, [:foo, :bar, :baz, :qux])
    end

    after(:all) do
      RgGen.delete(:bit_field, :type, [:foo, :bar, :baz, :qux])
    end

    def create_registers(&block)
      configuration = create_configuration(bus_width: 32, address_width: 16)
      register_map = create_register_map(configuration) do
        register_block(&block)
      end
      register_map.registers
    end

    describe 'レジスタ型' do
      before(:all) do
        RgGen.define_list_item_feature(:register, :type, [:foo, :bar, :qux]) do
          register_map {}
        end
      end

      after(:all) do
        delete_register_map_factory
        RgGen.delete(:register, :type, [:foo, :bar, :qux])
      end

      describe '#type' do
        it '指定したレジスタ型を返す' do
          [
            [:foo, :bar],
            [:FOO, :BAR],
            ['foo', 'bar'],
            ['FOO', 'BAR'],
            [random_string(/foo/i), random_string(/bar/i)]
          ].each do |foo_type, bar_type|
            registers = create_registers do
              register do
                type foo_type
                bit_field { bit_assignment lsb: 0;type :foo }
              end
              register do
                type bar_type
                bit_field { bit_assignment lsb: 0;type :foo }
              end
            end
            expect(registers[0]).to have_property(:type, :foo)
            expect(registers[1]).to have_property(:type, :bar)
          end
        end

        context 'レジスタ型が未指定の場合' do
          it ':defaultを返す' do
            registers = create_registers do
              register do
                bit_field { bit_assignment lsb: 0;type :foo }
              end
              register do
                type nil
                bit_field { bit_assignment lsb: 0;type :foo }
              end
              register do
                type ''
                bit_field { bit_assignment lsb: 0;type :foo }
              end
            end
            expect(registers[0]).to have_property(:type, :default)
            expect(registers[1]).to have_property(:type, :default)
            expect(registers[2]).to have_property(:type, :default)
          end
        end
      end

      context '有効になっていないレジスタ型が指定された場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register { type :qux }
            end
          }.to raise_register_map_error 'unknown register type: :qux'
        end
      end

      context '定義されていないレジスタ型が指定された場合' do
        it 'RegisterMapErrorを起こす' do
          expect {
            create_registers do
              register { type :baz }
            end
          }.to raise_register_map_error 'unknown register type: :baz'
        end
      end
    end

    describe 'ビットフィールド' do
      before(:all) do
        RgGen.define_list_item_feature(:register, :type, :foo) do
          register_map {}
        end
        RgGen.define_list_item_feature(:register, :type, :bar) do
          register_map { no_bit_fields }
        end
      end

      after(:all) do
        delete_register_map_factory
        RgGen.delete(:register, :type, [:foo, :bar])
      end

      context '.no_bit_fieldの指定がない場合' do
        specify 'ビットフィールドが必要' do
          expect {
            create_registers do
              register { type :foo }
            end
          }.to raise_register_map_error 'no bit fields are given'
        end
      end

      context '.no_bit_fieldsの指定がある場合' do
        specify 'ビットフィールドを持たない' do
          registers = create_registers do
            register do
              type :bar
            end
            register do
              type :bar
              bit_field { bit_assignment lsb: 0;type :foo }
            end
          end
          expect(registers[0].bit_fields).to be_empty
          expect(registers[1].bit_fields).to be_empty
        end
      end

      specify '規定型はビットフィールドを必要とする' do
        expect {
          create_registers do
            register {}
          end
        }.to raise_register_map_error 'no bit fields are given'
      end
    end

    describe 'アクセス属性' do
      before(:all) do
        RgGen.define_list_item_feature(:register, :type, :foo) do
          register_map {}
        end
        RgGen.define_list_item_feature(:register, :type, :bar) do
          register_map do
            writable? { true }
            readable? { true }
          end
        end
      end

      after(:all) do
        delete_register_map_factory
        RgGen.delete(:register, :type, [:foo, :bar])
      end

      context '.writable?/.readable?の指定がない場合' do
        let(:registers) do
          create_registers do
            register do
              type :foo
              bit_field { type :foo; bit_assignment lsb: 0 }
            end

            register do
              type :foo
              bit_field { type :bar; bit_assignment lsb: 0 }
            end

            register do
              type :foo
              bit_field { type :baz; bit_assignment lsb: 0 }
            end

            register do
              type :foo
              bit_field { type :qux; bit_assignment lsb: 0 }
            end
          end
        end

        specify '書き込み可能なビットフィールドがあれば、書き込み可能レジスタ' do
          expect(registers[0]).to have_property(:writable?, true)
          expect(registers[1]).to have_property(:writable?, false)
          expect(registers[2]).to have_property(:writable?, true)
          expect(registers[3]).to have_property(:writable?, false)
        end

        specify '読み込み可能、または、予約済みビットフィードがあれば、読み込み可能レジスタ' do
          expect(registers[0]).to have_property(:readable?, true)
          expect(registers[1]).to have_property(:readable?, true)
          expect(registers[2]).to have_property(:readable?, false)
          expect(registers[3]).to have_property(:readable?, true)
        end
      end

      context '.writable?/.readable?の指定がある場合' do
        specify '.writable?/.readable?に与えられたブロックの評価結果がアクセス属性になる' do
          registers = create_registers do
            register do
              type :bar
              bit_field { bit_assignment lsb: 0; type :bar }
            end
            register do
              type :bar
              bit_field { bit_assignment lsb: 0; type :baz }
            end
            register do
              type :bar
              bit_field { bit_assignment lsb: 0; type :qux }
            end
          end
          expect(registers[0]).to have_properties [[:writable?, true], [:readable?, true]]
          expect(registers[1]).to have_properties [[:writable?, true], [:readable?, true]]
          expect(registers[2]).to have_properties [[:writable?, true], [:readable?, true]]
        end
      end
    end

    describe '配列レジスタ' do
      after(:all) do
        delete_register_map_factory
      end

      specify '規定型は配列レジスタに対応する' do
        registers = create_registers do
          register do
            size [2]
            bit_field { bit_assignment lsb: 0, width: 1; type :foo }
          end
        end
        expect(registers[0]).to have_property(:array?, true)
      end
    end

    describe 'オプションの指定' do
      before(:all) do
        RgGen.define_list_item_feature(:register, :type, :foo) do
          register_map do
            property :input_options, body: -> { options }
          end
        end
      end

      after(:all) do
        delete_register_map_factory
        RgGen.delete(:register, :type, :foo)
      end

      specify 'レジスタ型に対するオプションを指定することができる' do
        registers = create_registers do
          register do
            type [:foo, :option_1]
            bit_field { bit_assignment lsb: 0;type :foo }
          end

          register do
            type [:foo, :option_1, :option_2]
            bit_field { bit_assignment lsb: 0;type :foo }
          end

          register do
            type ' foo : option_1:fizz'
            bit_field { bit_assignment lsb: 0;type :foo }
          end

          register do
            type ' foo : option_1:fizz, option_2:buzz'
            bit_field { bit_assignment lsb: 0;type :foo }
          end

          register do
            type <<~'TYPE'
              foo:
              option_1:fizz, option_2:buzz
              option_3:fizzbuzz
            TYPE
            bit_field { bit_assignment lsb: 0;type :foo }
          end
        end

        expect(registers[0].type).to eq :foo
        expect(registers[0].input_options).to match([:option_1])

        expect(registers[1].type).to eq :foo
        expect(registers[1].input_options).to match([:option_1, :option_2])

        expect(registers[2].type).to eq :foo
        expect(registers[2].input_options).to match(['option_1:fizz'])

        expect(registers[3].type).to eq :foo
        expect(registers[3].input_options).to match(['option_1:fizz', 'option_2:buzz'])

        expect(registers[4].type).to eq :foo
        expect(registers[4].input_options).to match(['option_1:fizz', 'option_2:buzz', 'option_3:fizzbuzz'])
      end

      context 'オプションが未指定の場合' do
        specify '空の配列が渡される' do
          registers = create_registers do
            register do
              type :foo
              bit_field { bit_assignment lsb: 0;type :foo }
            end

            register do
              type [:foo]
              bit_field { bit_assignment lsb: 0;type :foo }
            end

            register do
              type 'foo'
              bit_field { bit_assignment lsb: 0;type :foo }
            end

            register do
              type 'foo:'
              bit_field { bit_assignment lsb: 0;type :foo }
            end
          end

          expect(registers[0].input_options).to be_empty
          expect(registers[1].input_options).to be_empty
          expect(registers[2].input_options).to be_empty
          expect(registers[3].input_options).to be_empty
        end
      end
    end
  end
end
