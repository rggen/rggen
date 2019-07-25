# frozen_string_literal: true

register_block {
  name 'block_1'
  byte_size 128

  register {
    name 'register_0'
    offset_address 0x00
    size [2, 4]
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 8, sequence_size: 4, step: 16; type :rw; initial_value 0 }
    bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8, sequence_size: 4, step: 16; type :ro; reference 'register_1.bit_field_1' }
  }

  register {
    name 'register_1'
    offset_address 0x40
    size [2, 4]
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 8, sequence_size: 4, step: 16; type :ro; reference 'register_0.bit_field_0' }
    bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8, sequence_size: 4, step: 16; type :rw; initial_value 0  }
  }
}
