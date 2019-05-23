# frozen_string_literal: true

RSpec.describe 'register/array_size' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, :array_size)
  end

  def create_register(&block)
    create_register_map { register_block(&block) }.registers.first
  end

  describe '#array_size' do
    it '入力された配列の大きさを返す' do
      size = 1
      register = create_register { register { array_size size } }
      expect(register).to have_property(:array_size, match([size]))

      size = [1]
      register = create_register { register { array_size size } }
      expect(register).to have_property(:array_size, match(size))

      size = [1, 2, 3]
      register = create_register { register { array_size size } }
      expect(register).to have_property(:array_size, match(size))
    end

    context '未入力の場合' do
      it '空の配列を返す' do
        register = create_register { register {} }
        expect(register.array_size).to be_empty

        register = create_register { register { array_size nil } }
        expect(register.array_size).to be_empty

        register = create_register { register { array_size [] } }
        expect(register.array_size).to be_empty

        register = create_register { register { array_size '' } }
        expect(register.array_size).to be_empty
      end
    end
  end

  describe '#array?' do
    it 'レジスタが配列かどうかを示す' do
      register = create_register { register {} }
      expect(register).to have_property(:array?, false)

      register = create_register { register { array_size 1 } }
      expect(register).to have_property(:array?, true)
    end
  end

  specify '文字列も入力できる' do
    register = create_register { register { array_size '1' } }
    expect(register).to have_property(:array_size, match([1]))

    register = create_register { register { array_size '[1]' } }
    expect(register).to have_property(:array_size, match([1]))

    register = create_register { register { array_size '1, 2' } }
    expect(register).to have_property(:array_size, match([1, 2]))

    register = create_register { register { array_size '[1, 2]' } }
    expect(register).to have_property(:array_size, match([1, 2]))

    register = create_register { register { array_size '1, 2, 3' } }
    expect(register).to have_property(:array_size, match([1, 2, 3]))

    register = create_register { register { array_size '[1, 2, 3]' } }
    expect(register).to have_property(:array_size, match([1, 2, 3]))
  end

  describe 'エラーチェック' do
    context '入力文字列がパターンに一致しなかった場合' do
      it 'RegisterMapErrorを起こす' do
        [
          'foo',
          '0xef_gh',
          '[1',
          '1]',
          '[1,2',
          '1, 2]',
          '[foo, 2]',
          '[1, foo]',
          '[1:2]'
        ].each do |value|
          expect {
            create_register { register { array_size value } }
          }.to raise_register_map_error "illegal input value for array size: #{value.inspect}"
        end
      end
    end

    context '配列の大きさの各要素が整数に変換できなかった場合' do
      it 'RegisterMapErrorを起こす' do
        [nil, true, false, 'foo', '0xef_gh', Object.new].each_with_index do |value, i|
          if [1, 2, 5].include?(i)
            expect {
              create_register { register { array_size value } }
            }.to raise_register_map_error "cannot convert #{value.inspect} into array size"
          end

          expect {
            create_register { register { array_size [value] } }
          }.to raise_register_map_error "cannot convert #{value.inspect} into array size"

          expect {
            create_register { register { array_size [1, value] } }
          }.to raise_register_map_error "cannot convert #{value.inspect} into array size"

          expect {
            create_register { register { array_size [1, 2, value] } }
          }.to raise_register_map_error "cannot convert #{value.inspect} into array size"
        end
      end
    end

    context '配列の大きさに 1 未満の値が含まれる場合' do
      it 'RegisterMapErrorを起こす' do
        [0, -1, -2, -7].each do |value|
          expect {
            create_register { register { array_size value } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [#{value}]"

          expect {
            create_register { register { array_size [value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [#{value}]"

          expect {
            create_register { register { array_size [1, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [1, #{value}]"

          expect {
            create_register { register { array_size [value, 1] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [#{value}, 1]"

          expect {
            create_register { register { array_size [value, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [#{value}, #{value}]"

          expect {
            create_register { register { array_size [1, value, 2] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [1, #{value}, 2]"

          expect {
            create_register { register { array_size [1, 2, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [1, 2, #{value}]"

          expect {
            create_register { register { array_size [1, value, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [1, #{value}, #{value}]"

          expect {
            create_register { register { array_size [value, 1, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [#{value}, 1, #{value}]"

          expect {
            create_register { register { array_size [value, value, 1] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [#{value}, #{value}, 1]"

          expect {
            create_register { register { array_size [value, value, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for array size: [#{value}, #{value}, #{value}]"
        end
      end
    end
  end
end
