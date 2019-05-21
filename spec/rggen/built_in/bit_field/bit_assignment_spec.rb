# frozen_string_literal: true

RSpec.describe 'bit_field/bit_assignment' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:bit_field, :bit_assignment)
  end

  def create_bit_field(input_values)
    register_map = create_register_map do
      register_block do
        register do
          if input_values.is_a?(Array)
            input_values.each do |input_value|
              bit_field { bit_assignment input_value }
            end
          else
            bit_field { bit_assignment input_values }
          end
        end
      end
    end
    register_map.bit_fields.first
  end

  def random_value(min, max)
    rand(min..max)
  end

  describe '#lsb' do
    context '無引数の場合' do
      it '入力された LSB を返す' do
        lsb = random_value(0, 31)
        bit_field = create_bit_field(lsb: lsb)
        expect(bit_field).to have_property(:lsb, lsb)
      end
    end

    context '連番になっていて、かつ、インデックスが引数で指定された場合' do
      it '指定された位置の LSB を返す' do
        lsb = random_value(0, 31)
        sequence_size = random_value(1, 8)
        step = random_value(1, 8)
        bit_field = create_bit_field(lsb: lsb, sequence_size: sequence_size, step: step)

        index = random_value(0, sequence_size - 1)
        expect(bit_field.lsb(index)).to eq(step * index + lsb)

        index = 'i'
        expect(bit_field.lsb(index)).to eq "#{step}*i+#{lsb}"
      end
    end

    context '連番ではなく、かつ、インデックスが指定された場合' do
      it 'インデックスに関係なく、入力された LSB を返す' do
        lsb = random_value(0, 31)
        bit_field = create_bit_field(lsb: lsb)

        index = random_value(0, 7)
        expect(bit_field.lsb(index)).to eq lsb

        index = 'i'
        expect(bit_field.lsb(index)).to eq lsb
      end
    end
  end

  describe '#msb' do
    let(:lsb) { random_value(0, 31) }

    let(:width) { random_value(2, 8) }

    let(:sequence_size) { random_value(1, 8) }

    let(:step) { random_value(width, 8) }

    context '無引数の場合' do
      it '一番目のフィールドの MSB を返す' do
        bit_field = create_bit_field(lsb: lsb)
        expect(bit_field).to have_property(:msb, lsb)

        bit_field = create_bit_field(lsb: lsb, width: width)
        expect(bit_field).to have_property(:msb, lsb + width - 1)

        bit_field = create_bit_field(lsb: lsb, width: width, sequence_size: sequence_size)
        expect(bit_field).to have_property(:msb, lsb + width - 1)

        bit_field = create_bit_field(lsb: lsb, width: width, sequence_size: sequence_size, step: step)
        expect(bit_field).to have_property(:msb, lsb + width - 1)
      end
    end

    context '連番になっていて、かつ、インデックスが指定された場合' do
      it '指定された位置の MSB を返す' do
        bit_field = create_bit_field(lsb: lsb, width: width, sequence_size: sequence_size)

        index = random_value(0, sequence_size - 1)
        expect(bit_field.msb(index)).to eq(index * width + lsb + width - 1)

        index = 'i'
        expect(bit_field.msb(index)).to eq "#{width}*i+#{lsb + width - 1}"

        bit_field = create_bit_field(lsb: lsb, width: width, sequence_size: sequence_size, step: step)

        index = random_value(0, sequence_size - 1)
        expect(bit_field.msb(index)).to eq(index * step + lsb + width - 1)

        index = 'i'
        expect(bit_field.msb(index)).to eq "#{step}*i+#{lsb + width - 1}"
      end
    end

    context '連番ではなく、かつ、インデックスが指定された場合' do
      it 'インデックにかかわらず、一番目のフィールドの MSB を返す' do
        bit_field = create_bit_field(lsb: lsb, width: width)

        index = random_value(0, 7)
        expect(bit_field.msb(index)).to eq(lsb + width - 1)

        index = 'i'
        expect(bit_field.msb(index)).to eq(lsb + width - 1)
      end
    end
  end

  describe '#width' do
    it '入力されたビットフィールド幅を返す' do
      lsb = random_value(0, 31)
      width = random_value(1, 32)
      bit_field = create_bit_field(lsb: lsb, width: width)
      expect(bit_field).to have_property(:width, width)
    end

    context 'ビットフィールド幅が未指定の場合' do
      it '既定値 1 を返す' do
        lsb = random_value(0, 31)
        bit_field = create_bit_field(lsb: lsb)
        expect(bit_field).to have_property(:width, 1)
      end
    end
  end

  describe '#sequence_size' do
    it '入力された繰り返し数を返す' do
      lsb = random_value(0, 31)
      sequence_size = random_value(1, 8)
      bit_field = create_bit_field(lsb: lsb, sequence_size: sequence_size)
      expect(bit_field).to have_property(:sequence_size, sequence_size)
    end

    context '未入力の場合' do
      it 'nilを返す' do
        lsb = random_value(0, 31)
        bit_field = create_bit_field(lsb: lsb)
        expect(bit_field.sequence_size).to be_nil
      end
    end
  end

  describe '#step' do
    it '入力された繰り返し幅を返す' do
      lsb = random_value(0, 31)
      sequence_size = random_value(1, 8)
      step = random_value(1, 8)
      bit_field = create_bit_field(lsb: lsb, sequence_size: sequence_size, step: step)
      expect(bit_field).to have_property(:step, step)

      lsb = random_value(0, 31)
      width = random_value(1, 8)
      sequence_size = random_value(1, 8)
      step = random_value(width, 9)
      bit_field = create_bit_field(lsb: lsb, width: width, sequence_size: sequence_size, step: step)
      expect(bit_field).to have_property(:step, step)
    end

    context '未指定の場合' do
      it 'ビットフィールド幅を返す' do
        lsb = random_value(0, 31)
        sequence_size = random_value(1, 8)
        bit_field = create_bit_field(lsb: lsb, sequence_size: sequence_size)
        expect(bit_field).to have_property(:step, 1)

        lsb = random_value(0, 31)
        width = random_value(1, 8)
        sequence_size = random_value(1, 8)
        bit_field = create_bit_field(lsb: lsb, width: width, sequence_size: sequence_size)
        expect(bit_field).to have_property(:step, width)
      end
    end
  end

  describe '#sequential?' do
    it '連番になっている(sequence_sizeが指定されている)かどうかを示す' do
      lsb = random_value(0, 31)
      sequence_size = random_value(1, 8)
      bit_field = create_bit_field(lsb: lsb, sequence_size: sequence_size)
      expect(bit_field).to have_property(:sequential?, true)

      lsb = random_value(0, 31)
      bit_field = create_bit_field(lsb: lsb)
      expect(bit_field).to have_property(:sequential?, false)
    end
  end

  describe '#bit_map' do
    let(:lsb) { random_value(0, 31) }

    let(:width) { random_value(1, 8) }

    let(:sequence_size) { random_value(1, 8) }

    let(:step) { random_value(width, 8) }

    it 'ビットが割り当てられている箇所を返す' do
      bit_field = create_bit_field(lsb: lsb)
      expect(bit_field).to have_property(:bit_map, 1 << lsb)

      bit_field = create_bit_field(lsb: lsb, width: width)
      expect(bit_field).to have_property(:bit_map, (2**width - 1) << lsb)

      bit_field = create_bit_field(lsb: lsb, width: width, sequence_size: sequence_size)
      expect(bit_field).to have_property(:bit_map, (2**(width * sequence_size) - 1) << lsb)

      bit_map =
        Array.new(sequence_size) { |i| (2**width - 1) << (step * i + lsb) }.inject(:|)
      bit_field = create_bit_field(lsb: lsb, width: width, sequence_size: sequence_size, step: step)
      expect(bit_field).to have_property(:bit_map, bit_map)
    end
  end

  context '入力が文字列の場合' do
    let(:lsb) { random_value(0, 31) }

    let(:width) { random_value(1, 8) }

    let(:sequence_size) { random_value(1, 8) }

    let(:step) { random_value(width, 8) }

    specify ':区切りで、LSB/ビットフィールド幅/繰り返し数/繰り返す幅を入力できる' do
      bit_field = create_bit_field("#{lsb}")
      expect(bit_field).to have_properties([[:lsb, lsb], [:width, 1]])
      expect(bit_field).not_to be_sequential

      bit_field = create_bit_field("#{lsb}:#{width}")
      expect(bit_field).to have_properties([[:lsb, lsb], [:width, width]])
      expect(bit_field).not_to be_sequential

      bit_field = create_bit_field("#{lsb}:#{width}:#{sequence_size}")
      expect(bit_field).to have_properties([[:lsb, lsb], [:width, width], [:sequence_size, sequence_size], [:step, width]])

      bit_field = create_bit_field("#{lsb}:#{width}:#{sequence_size}:#{step}")
      expect(bit_field).to have_properties([[:lsb, lsb], [:width, width], [:sequence_size, sequence_size], [:step, step]])
    end
  end

  describe 'エラーチェック' do
    context '入力がHashではない場合' do
      it 'RegisterMapErrorを起こす' do
        [nil, true, false, :foo, Object.new].each do |value|
          expect {
            create_bit_field(value)
          }.to raise_register_map_error "illegal input value for bit assignment: #{value.inspect}"
        end
      end
    end

    context '入力文字列がパターンに一致しなかった場合' do
      it 'RegisterMapErrorを起こす' do
        ['', 'foo', '1:foo', '1:1:foo', '1:1:1:foo', '1:1:1:1:1', '1:1::1:1'].each do |value|
          expect {
            create_bit_field(value)
          }.to raise_register_map_error "illegal input value for bit assignment: #{value.inspect}"
        end
      end
    end

    context 'LSBが入力されなかった場合' do
      it 'RegisterMapErrorを起こす' do
        expect {
          create_bit_field(width: 1, sequence_size: 1, step: 1)
        }.to raise_register_map_error 'no lsb is given'
      end
    end

    context '入力LSBが整数に変換できない場合' do
      it 'RegisterMapErrorを起こす' do
        [nil, true, false, 'foo', '0xef,_gh', Object.new].each do |invalid_value|
          expect {
            create_bit_field(lsb: invalid_value)
          }.to raise_register_map_error "cannot convert #{invalid_value.inspect} into bit assignment(lsb)"
        end
      end
    end

    context '入力LSBが 0 未満の場合' do
      it 'RegisterMapErrorを起こす' do
        [random_value(-8, -3), -2, -1].each do |invalid_value|
          expect {
            create_bit_field(lsb: invalid_value)
          }.to raise_register_map_error "lsb is less than 0: #{invalid_value}"
        end
      end
    end

    context '入力ビットフィールド幅が整数に変換できない場合' do
      it 'RegisterMapErrorを起こす' do
        [nil, true, false, 'foo', '0xef,_gh', Object.new].each do |invalid_value|
          expect {
            create_bit_field(lsb: 0, width: invalid_value)
          }.to raise_register_map_error "cannot convert #{invalid_value.inspect} into bit assignment(width)"
        end
      end
    end

    context '入力ビットフィールド幅が 1 未満の場合' do
      it 'RegisterMapErrorを起こす' do
        [random_value(-8, -2), -1, 0].each do |invalid_value|
          expect {
            create_bit_field(lsb: 0, width: invalid_value)
          }.to raise_register_map_error "width is less than 1: #{invalid_value}"
        end
      end
    end

    context '入力繰り返し数が整数に変換できない場合' do
      it 'RegisterMapErrorを起こす' do
        [nil, true, false, 'foo', '0xef,_gh', Object.new].each do |invalid_value|
          expect {
            create_bit_field(lsb: 0, sequence_size: invalid_value)
          }.to raise_register_map_error "cannot convert #{invalid_value.inspect} into bit assignment(sequence size)"
        end
      end
    end

    context '入力繰り返し数が 1 未満の場合' do
      it 'RegisterMapErrorを起こす' do
        [random_value(-8, -2), -1, 0].each do |invalid_value|
          expect {
            create_bit_field(lsb: 0, sequence_size: invalid_value)
          }.to raise_register_map_error "sequence size is less than 1: #{invalid_value}"
        end
      end
    end

    context '入力繰り返し幅が整数に変換できない場合' do
      it 'RegisterMapErrorを起こす' do
        [nil, true, false, 'foo', '0xef,_gh', Object.new].each do |invalid_value|
          expect {
            create_bit_field(lsb: 0, sequence_size: 1, step: invalid_value)
          }.to raise_register_map_error "cannot convert #{invalid_value.inspect} into bit assignment(step)"
        end
      end
    end

    context '入力繰り返し幅が 1 未満の場合' do
      it 'RegisterMapErrorを起こす' do
        [random_value(-8, -2), -1, 0].each do |invalid_value|
          expect {
            create_bit_field(lsb: 0, sequence_size: 1, step: invalid_value)
          }.to raise_register_map_error "step is less than 1: #{invalid_value}"
        end
      end
    end

    context '割り当てたビットが既出の場合' do
      let(:existing_bit_assignment) do
        { lsb: 4, width: 4, sequence_size: 2, step: 8 }
      end

      it 'RegisterMapErrorを起こす' do
        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: random_value(4, 7) }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: random_value(12, 15) }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: 3, width: 2 }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: 7, width: 2 }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: 11, width: 2 }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: 15, width: 2 }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: 0, width: 1, sequence_size: 2, step: 4 }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: 0, width: 1, sequence_size: 2, step: 12 }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: 0, width: 2, sequence_size: 2, step: 11 }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: 0, width: 2, sequence_size: 2, step: 15 }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'

        expect {
          create_bit_field([
            existing_bit_assignment,
            { lsb: 0, width: 16 }
          ])
        }.to raise_register_map_error 'overlap with existing bit field(s)'
      end
    end
  end
end
