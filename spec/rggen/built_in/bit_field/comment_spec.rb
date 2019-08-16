# frozen_string_literal: true

RSpec.describe 'bit_field/comment' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:bit_field, :comment)
  end

  def create_bit_field(&block)
    register_map = create_register_map do
      register_block do
        register { bit_field(&block) }
      end
    end
    register_map.bit_fields.first
  end

  describe '#comment' do
    it '入力されたコメントを返す' do
      bit_field = create_bit_field do
        comment :foo
      end
      expect(bit_field).to have_property(:comment, 'foo')

      bit_field = create_bit_field do
        comment 'foo'
      end
      expect(bit_field).to have_property(:comment, 'foo')

      bit_field = create_bit_field do
        comment <<~'COMMENT'
          foo
          bar
          baz
        COMMENT
      end
      expect(bit_field).to have_property(:comment, "foo\nbar\nbaz")

      bit_field = create_bit_field do
        comment ['foo', 'bar', 'baz']
      end
      expect(bit_field).to have_property(:comment, "foo\nbar\nbaz")
    end

    context 'コメントが未入力の場合' do
      it '空文字を返す' do
        bit_field = create_bit_field {}
        expect(bit_field).to have_property(:comment, '')

        bit_field = create_bit_field { comment nil }
        expect(bit_field).to have_property(:comment, '')

        bit_field = create_bit_field { comment '' }
        expect(bit_field).to have_property(:comment, '')
      end
    end
  end

  it '表示可能オブジェクトとして、#commentを返す' do
    bit_field = create_bit_field { comment "foo\nbar\nbaz" }
    expect(bit_field.printables[:comment]).to eq "foo\nbar\nbaz"

    bit_field = create_bit_field {}
    expect(bit_field.printables[:comment]).to eq ''
  end
end
