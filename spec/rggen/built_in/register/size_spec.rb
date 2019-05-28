# frozen_string_literal: true

RSpec.describe 'register/size' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:register, :size)
  end

  def create_register(&block)
    create_register_map { register_block(&block) }.registers.first
  end

  describe '#size' do
    it '入力された大きさを返す' do
      register = create_register { register { size 1 } }
      expect(register).to have_property(:size, match([1]))

      register = create_register { register { size [1] } }
      expect(register).to have_property(:size, match([1]))

      register = create_register { register { size [1, 2, 3] } }
      expect(register).to have_property(:size, match([1, 2, 3]))
    end

    context '未入力の場合' do
      it 'nilを返す' do
        register = create_register { register {} }
        expect(register.size).to be_nil

        register = create_register { register { size nil } }
        expect(register.size).to be_nil

        register = create_register { register { size [] } }
        expect(register.size).to be_nil

        register = create_register { register { size '' } }
        expect(register.size).to be_nil
      end
    end
  end

  specify '文字列も入力できる' do
    register = create_register { register { size '1' } }
    expect(register).to have_property(:size, match([1]))

    register = create_register { register { size '[1]' } }
    expect(register).to have_property(:size, match([1]))

    register = create_register { register { size '1, 2' } }
    expect(register).to have_property(:size, match([1, 2]))

    register = create_register { register { size '[1, 2]' } }
    expect(register).to have_property(:size, match([1, 2]))

    register = create_register { register { size '1, 2, 3' } }
    expect(register).to have_property(:size, match([1, 2, 3]))

    register = create_register { register { size '[1, 2, 3]' } }
    expect(register).to have_property(:size, match([1, 2, 3]))
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
            create_register { register { size value } }
          }.to raise_register_map_error "illegal input value for register size: #{value.inspect}"
        end
      end
    end

    context '大きさの各要素が整数に変換できなかった場合' do
      it 'RegisterMapErrorを起こす' do
        [nil, true, false, 'foo', '0xef_gh', Object.new].each_with_index do |value, i|
          if [1, 2, 5].include?(i)
            expect {
              create_register { register { size value } }
            }.to raise_register_map_error "cannot convert #{value.inspect} into register size"
          end

          expect {
            create_register { register { size [value] } }
          }.to raise_register_map_error "cannot convert #{value.inspect} into register size"

          expect {
            create_register { register { size [1, value] } }
          }.to raise_register_map_error "cannot convert #{value.inspect} into register size"

          expect {
            create_register { register { size [1, 2, value] } }
          }.to raise_register_map_error "cannot convert #{value.inspect} into register size"
        end
      end
    end

    context '大きさに 1 未満の要素が含まれる場合' do
      it 'RegisterMapErrorを起こす' do
        [0, -1, -2, -7].each do |value|
          expect {
            create_register { register { size value } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [#{value}]"

          expect {
            create_register { register { size [value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [#{value}]"

          expect {
            create_register { register { size [1, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [1, #{value}]"

          expect {
            create_register { register { size [value, 1] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [#{value}, 1]"

          expect {
            create_register { register { size [value, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [#{value}, #{value}]"

          expect {
            create_register { register { size [1, value, 2] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [1, #{value}, 2]"

          expect {
            create_register { register { size [1, 2, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [1, 2, #{value}]"

          expect {
            create_register { register { size [1, value, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [1, #{value}, #{value}]"

          expect {
            create_register { register { size [value, 1, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [#{value}, 1, #{value}]"

          expect {
            create_register { register { size [value, value, 1] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [#{value}, #{value}, 1]"

          expect {
            create_register { register { size [value, value, value] } }
          }.to raise_register_map_error "non positive value(s) are not allowed for register size: [#{value}, #{value}, #{value}]"
        end
      end
    end
  end
end
