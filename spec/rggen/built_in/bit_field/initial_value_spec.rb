# frozen_string_literal: true

RSpec.describe 'bit_field/initial_value' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:global, :bus_width)
    RgGen.enable(:bit_field, [:bit_assignment, :initial_value].shuffle)
  end

  def create_bit_field(width, *input_value)
    register_map = create_register_map do
      register_block do
        register do
          bit_field do
            initial_value input_value[0] unless input_value.empty?
            bit_assignment lsb: 0, width: width
          end
        end
      end
    end
    register_map.bit_fields.first
  end

  describe '#initial_value' do
    it '入力された初期値を返す' do
      {
        1 => [0, 1],
        2 => [-2, -1, 0, 1, 3],
        3 => [-4, -1, 0, 1, 3, 7]
      }.each do |width, initial_values|
        initial_values.each do |initial_value|
          bit_field = create_bit_field(width, initial_value)
          expect(bit_field).to have_property(:initial_value, initial_value)

          bit_field = create_bit_field(width, initial_value.to_f)
          expect(bit_field).to have_property(:initial_value, initial_value)

          bit_field = create_bit_field(width, initial_value.to_s)
          expect(bit_field).to have_property(:initial_value, initial_value)

          next if initial_value.negative?

          bit_field = create_bit_field(width, format('0x%x', initial_value))
          expect(bit_field).to have_property(:initial_value, initial_value)
        end
      end
    end

    context '初期値が未入力の場合' do
      it '既定値 0 を返す' do
        bit_field = create_bit_field(1)
        expect(bit_field).to have_property(:initial_value, 0)
      end
    end

    context '入力が空白の場合' do
      it '既定値 0 を返す' do
        bit_field = create_bit_field(1, nil)
        expect(bit_field).to have_property(:initial_value, 0)

        bit_field = create_bit_field(1, '')
        expect(bit_field).to have_property(:initial_value, 0)
      end
    end
  end

  describe 'initial_value?' do
    it '初期値が設定されたかどうかを返す' do
      bit_field = create_bit_field(1)
      expect(bit_field).to have_property(:initial_value?, false)

      bit_field = create_bit_field(1, nil)
      expect(bit_field).to have_property(:initial_value?, false)

      bit_field = create_bit_field(1, '')
      expect(bit_field).to have_property(:initial_value?, false)

      bit_field = create_bit_field(1, 1)
      expect(bit_field).to have_property(:initial_value?, true)
    end
  end

  describe 'エラーチェック' do
    context '入力が整数に変換できない場合' do
      it 'RegisterMapErrorを起こす' do
        [true, false, 'foo', '0xef_gh', Object.new].each do |value|
          expect {
            create_bit_field(1, value)
          }.to raise_register_map_error "cannot convert #{value.inspect} into initial value"
        end
      end
    end

    context '入力が最小値未満の場合' do
      it 'RegisterMapErrorを起こす' do
        {
          1 => [0, [-1, -2, rand(-16..-3)]],
          2 => [-2, [-3, -4, rand(-16..-5)]],
          3 => [-4, [-5, -6, rand(-16..-7)]]
        }.each do |width, (min_value, values)|
          values.each do |value|
            expect {
              create_bit_field(width, value)
            }.to raise_register_map_error 'input initial value is less than minimum initial value: ' \
                                          "initial value #{value} minimum initial value #{min_value}"
          end
        end
      end
    end

    context '入力が最大値を超える場合' do
      it 'RegisterMapErrorを起こす' do
        {
          1 => [1, [2, 3, rand(4..16)]],
          2 => [3, [4, 5, rand(6..16)]],
          3 => [7, [8, 9, rand(10..16)]]
        }.each do |width, (max_value, values)|
          values.each do |value|
            expect {
              create_bit_field(width, value)
            }.to raise_register_map_error 'input initial value is greater than maximum initial value: ' \
                                          "initial value #{value} maximum initial value #{max_value}"
          end
        end
      end
    end
  end
end
