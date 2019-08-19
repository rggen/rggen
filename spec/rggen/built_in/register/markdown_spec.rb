# frozen_string_literal: true

RSpec.describe 'register/markdown' do
  include_context 'clean-up builder'
  include_context 'markdown common'

  before(:all) do
    RgGen.enable(:register_block, :markdown)
    RgGen.enable(:register, :markdown)
  end

  describe '#anchor_id' do
    before(:all) do
      delete_configuration_factory
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:register_block, :name)
      RgGen.enable(:register, :name)
    end

    after(:all) do
      RgGen.disable(:register_block, :name)
      RgGen.disable(:register, :name)
    end

    let(:markdown) do
      md = create_markdown do
        name 'register_block'
        register { name 'register' }
      end
      md.registers.first
    end

    it 'アンカー用IDとして、自身の#nameと上位階層の#anchor_idを連接したものを返す' do
      expect(markdown.anchor_id).to eq 'register_block-register'
    end
  end

  describe '#generate_code' do
    before(:all) do
      delete_configuration_factory
      delete_register_map_factory
    end

    before(:all) do
      RgGen.enable(:global, [:bus_width, :address_width])
      RgGen.enable(:register_block, [:name, :byte_size])
      RgGen.enable(:register, [:name, :offset_address, :size, :type])
      RgGen.enable(:register, :type, [:external, :indirect])
      RgGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
      RgGen.enable(:bit_field, :type, [:rw, :ro, :wo])
    end

    after(:all) do
      RgGen.disable(:global, [:bus_width, :address_width])
      RgGen.disable(:register_block, [:name, :byte_size])
      RgGen.disable(:register, [:name, :offset_address, :size, :type])
      RgGen.disable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
      RgGen.disable(:bit_field, :type, [:rw, :ro, :wo])
    end

    let(:markdown) do
      md = create_markdown do
        name 'block_0'
        byte_size 256

        register do
          name 'register_0'
          offset_address 0x00
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 1; type :ro }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 2; type :wo; initial_value 0 }
          bit_field { name 'bit_field_3'; bit_assignment lsb: 8, width: 8; type :rw; initial_value 0xa }
          bit_field { name 'bit_field_4'; bit_assignment lsb: 16, width: 8; type :ro }
          bit_field { name 'bit_field_5'; bit_assignment lsb: 24, width: 8; type :wo; initial_value 0xb }
        end

        register do
          name 'register_1'
          offset_address 0x04
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 8, sequence_size: 2, step: 32; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8, sequence_size: 2, step: 32; type :ro }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 8, sequence_size: 2, step: 32; type :wo; initial_value 0 }
        end

        register do
          name 'register_2'
          offset_address 0x10
          size [4]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 8; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8; type :ro }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 8; type :wo; initial_value 0 }
        end

        register do
          name 'register_3'
          offset_address 0x20
          size [2, 2]
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 8; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8; type :ro }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 8; type :wo; initial_value 0 }
        end

        register do
          name 'register_4'
          offset_address 0x30
          size [4, 4]
          type [:indirect, 'register_0.bit_field_3', 'register_0.bit_field_4']
          bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 8; type :rw; initial_value 0 }
          bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8; type :ro }
          bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 8; type :wo; initial_value 0 }
        end

        register do
          name 'register_5'
          offset_address 0x40
          size [4]
          type :external
        end
      end
      md.registers
    end

    it 'レジスタ用のMarkdownを出力する' do
      expect(markdown[0]).to generate_code(:markdown, :top_down, <<~MARKDOWN)

        ### <div id="block_0-register_0"></div>register_0

        * name
            * register_0
        * offset_address
            * 0x00 - 0x03
        * array_size
            * NA

        |name|bit_assignments|type|initial_value|
        |:--|:--|:--|:--|
        |bit_field_0|[0]|rw|0x0|
        |bit_field_1|[1]|ro||
        |bit_field_2|[2]|wo|0x0|
        |bit_field_3|[15:8]|rw|0x0a|
        |bit_field_4|[23:16]|ro||
        |bit_field_5|[31:24]|wo|0x0b|
      MARKDOWN

      expect(markdown[1]).to generate_code(:markdown, :top_down, <<~MARKDOWN)

        ### <div id="block_0-register_1"></div>register_1

        * name
            * register_1
        * offset_address
            * 0x04 - 0x0b
        * array_size
            * NA

        |name|bit_assignments|type|initial_value|
        |:--|:--|:--|:--|
        |bit_field_0|[7:0]<br>[39:32]|rw|0x00|
        |bit_field_1|[15:8]<br>[47:40]|ro||
        |bit_field_2|[23:16]<br>[55:48]|wo|0x00|
      MARKDOWN

      expect(markdown[2]).to generate_code(:markdown, :top_down, <<~MARKDOWN)

        ### <div id="block_0-register_2"></div>register_2

        * name
            * register_2
        * offset_address
            * 0x10 - 0x1f
        * array_size
            * [4]

        |name|bit_assignments|type|initial_value|
        |:--|:--|:--|:--|
        |bit_field_0|[7:0]|rw|0x00|
        |bit_field_1|[15:8]|ro||
        |bit_field_2|[23:16]|wo|0x00|
      MARKDOWN

      expect(markdown[3]).to generate_code(:markdown, :top_down, <<~MARKDOWN)

        ### <div id="block_0-register_3"></div>register_3

        * name
            * register_3
        * offset_address
            * 0x20 - 0x2f
        * array_size
            * [2, 2]

        |name|bit_assignments|type|initial_value|
        |:--|:--|:--|:--|
        |bit_field_0|[7:0]|rw|0x00|
        |bit_field_1|[15:8]|ro||
        |bit_field_2|[23:16]|wo|0x00|
      MARKDOWN

      expect(markdown[4]).to generate_code(:markdown, :top_down, <<~MARKDOWN)

        ### <div id="block_0-register_4"></div>register_4

        * name
            * register_4
        * offset_address
            * 0x30 - 0x33
        * array_size
            * [4, 4]

        |name|bit_assignments|type|initial_value|
        |:--|:--|:--|:--|
        |bit_field_0|[7:0]|rw|0x00|
        |bit_field_1|[15:8]|ro||
        |bit_field_2|[23:16]|wo|0x00|
      MARKDOWN

      expect(markdown[5]).to generate_code(:markdown, :top_down, <<~MARKDOWN)

        ### <div id="block_0-register_5"></div>register_5

        * name
            * register_5
        * offset_address
            * 0x40 - 0x4f
        * array_size
            * NA
      MARKDOWN
    end
  end
end
