# frozen_string_literal: true

RgGen.define_simple_feature(:register, :word_size) do
  register_map do
    property :word_size, body: -> { @word_size ||= calc_word_size }
    property :single_word?, body: -> { word_size == 1 }
    property :multie_words?, body: -> { word_size >= 2 }

    private

    def calc_word_size
      max_msb =
        register
          .bit_fields
          .map(&method(:get_msb))
          .max
      (max_msb + configuration.data_width) / configuration.data_width
    end

    def get_msb(bit_field)
      bit_field.msb((bit_field.sequence_size || 1) - 1)
    end
  end
end
