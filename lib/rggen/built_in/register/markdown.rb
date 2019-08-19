# frozen_string_literal: true

RgGen.define_simple_feature(:register, :markdown) do
  markdown do
    export def anchor_id
      [register_block.anchor_id, register.name].join('-')
    end

    main_code :markdown, from_template: true

    private

    def bit_field_table
      column_names = bit_field_printables.first.keys
      rows =
        bit_field_printables
          .map(&:values)
          .map { |row| row.map { |cell| Array(cell).join("\n") } }
      table(column_names, rows)
    end

    def bit_field_printables
      @bit_field_printables ||= register.bit_fields.map(&:printables)
    end
  end
end
