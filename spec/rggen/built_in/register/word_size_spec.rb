# frozen_string_literal: true

RSpec.describe 'register/word_size' do
  include_context 'clean-up builder'
  include_context 'register map common'

  before(:all) do
    RgGen.enable(:global, :data_width)
    RgGen.enable(:register, :word_size)
    RgGen.enable(:bit_field, :bit_assignment)
  end

  let(:data_width) { 32 }

  let(:configuration) { create_configuration(data_width: data_width) }

  def create_register(&block)
    register_map = create_register_map(configuration) do
      register_block { register(&block) }
    end
    register_map.registers.first
  end

  describe '#word_size' do
    it 'レジスタのワード長を返す' do
      register = create_register do
        bit_field { bit_assignment lsb: 0 }
      end
      expect(register).to have_property(:word_size, 1)

      register = create_register do
        bit_field { bit_assignment lsb: data_width - 1 }
      end
      expect(register).to have_property(:word_size, 1)

      register = create_register do
        bit_field { bit_assignment lsb: data_width }
      end
      expect(register).to have_property(:word_size, 2)

      register = create_register do
        bit_field { bit_assignment lsb: 2 * data_width - 1 }
      end
      expect(register).to have_property(:word_size, 2)

      register = create_register do
        bit_field { bit_assignment lsb: data_width - 1 }
        bit_field { bit_assignment lsb: 0 }
      end
      expect(register).to have_property(:word_size, 1)

      register = create_register do
        bit_field { bit_assignment lsb: data_width - 1 }
        bit_field { bit_assignment lsb: data_width }
      end
      expect(register).to have_property(:word_size, 2)

      register = create_register do
        bit_field { bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8 }
      end
      expect(register).to have_property(:word_size, 1)

      register = create_register do
        bit_field { bit_assignment lsb: 0, width: 4, sequence_size: 5, step: 8 }
      end
      expect(register).to have_property(:word_size, 2)

      register = create_register do
        bit_field { bit_assignment lsb: 0, width: 4, sequence_size: 4, step: 8 }
        bit_field { bit_assignment lsb: data_width, width: 4, sequence_size: 4, step: 8 }
      end
      expect(register).to have_property(:word_size, 2)
    end
  end

  describe '#single_word?/multi_words?' do
    it 'レジスタが単一ワード/複数ワードかどうかを示す' do
      regsiter = create_register do
        bit_field { bit_assignment lsb: 0 }
      end
      expect(regsiter).to have_property(:single_word?, true)
      expect(regsiter).to have_property(:multie_words?, false)

      regsiter = create_register do
        bit_field { bit_assignment lsb: data_width }
      end
      expect(regsiter).to have_property(:single_word?, false)
      expect(regsiter).to have_property(:multie_words?, true)
    end
  end
end
