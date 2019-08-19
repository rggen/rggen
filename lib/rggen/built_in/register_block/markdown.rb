# frozen_string_literal: true

RgGen.define_simple_feature(:register_block, :markdown) do
  markdown do
    export def anchor_id
      register_block.name
    end

    write_file '<%= register_block.name %>.md' do |file|
      file.body do |code|
        register_block.generate_code(:markdown, :top_down, code)
      end
    end

    main_code :markdown, from_template: true

    private

    def register_table
      table([:name, :offset_address], table_rows)
    end

    def table_rows
      register_block.registers
        .zip(register_block.registers.map(&:printables))
        .map { |register, printables| table_row(register, printables) }
    end

    def table_row(register, printables)
      [
        anchor_link(printables[:name], register.anchor_id),
        printables[:offset_address]
      ]
    end
  end
end
