# frozen_string_literal: true

register_block {
  name 'block_0'
  byte_size 256

  register {
    name 'register_0'
    offset_address 0x00
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0 , width: 4; type :rw; initial_value 0 }
    bit_field { name 'bit_field_1'; bit_assignment lsb: 4 , width: 4; type :rw; initial_value 0 }
    bit_field { name 'bit_field_2'; bit_assignment lsb: 8 , width: 1; type :rw; initial_value 0 }
  }

  register {
    name 'register_1'
    offset_address 0x04
    bit_field { bit_assignment lsb: 0, width: 1; type :rw; initial_value 0 }
  }

  register {
    name 'register_2'
    offset_address 0x08
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0 , width: 4; type :ro }
    bit_field { name 'bit_field_1'; bit_assignment lsb: 8 , width: 4; type :ro }
    bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 8; type :rof; initial_value 0xab }
    bit_field { name 'bit_field_3'; bit_assignment lsb: 24, width: 8; type :reserved }
  }

  register {
    name 'register_3'
    offset_address 0x08
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0 , width: 4; type :wo; initial_value 0 }
    bit_field { name 'bit_field_1'; bit_assignment lsb: 8 , width: 4; type :w0trg }
    bit_field { name 'bit_field_2'; bit_assignment lsb: 16, width: 4; type :w1trg }
  }

  register {
    name 'register_4'
    offset_address 0x0C
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0 , width: 4; type :rc; initial_value 0 }
    bit_field { name 'bit_field_1'; bit_assignment lsb: 8 , width: 4; type :rc; initial_value 0; reference 'register_0.bit_field_0' }
    bit_field { name 'bit_field_2'; bit_assignment lsb: 12, width: 4; type :ro;                  reference 'register_4.bit_field_1' }
    bit_field { name 'bit_field_3'; bit_assignment lsb: 16, width: 4; type :rs; initial_value 0 }
  }

  register {
    name 'register_5'
    offset_address 0x10
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0 , width: 4; type :rwc; initial_value 0 }
    bit_field { name 'bit_field_1'; bit_assignment lsb: 4 , width: 4; type :rwc; initial_value 0; reference 'register_3.bit_field_1' }
    bit_field { name 'bit_field_2'; bit_assignment lsb: 8 , width: 2; type :rwe; initial_value 0 }
    bit_field { name 'bit_field_3'; bit_assignment lsb: 10, width: 2; type :rwe; initial_value 0; reference 'register_0.bit_field_2' }
    bit_field { name 'bit_field_4'; bit_assignment lsb: 12, width: 2; type :rwe; initial_value 0; reference 'register_1' }
    bit_field { name 'bit_field_5'; bit_assignment lsb: 16, width: 2; type :rwl; initial_value 0 }
    bit_field { name 'bit_field_6'; bit_assignment lsb: 18, width: 2; type :rwl; initial_value 0; reference 'register_0.bit_field_2' }
    bit_field { name 'bit_field_7'; bit_assignment lsb: 20, width: 2; type :rwl; initial_value 0; reference 'register_1' }
  }

  register {
    name 'register_6'
    offset_address 0x14
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0 , width: 4; type :w0c; initial_value 0 }
    bit_field { name 'bit_field_1'; bit_assignment lsb: 4 , width: 4; type :w0c; initial_value 0; reference 'register_0.bit_field_0' }
    bit_field { name 'bit_field_2'; bit_assignment lsb: 8 , width: 4; type :ro ;                  reference 'register_6.bit_field_1' }
    bit_field { name 'bit_field_3'; bit_assignment lsb: 12, width: 4; type :w1c; initial_value 0 }
    bit_field { name 'bit_field_4'; bit_assignment lsb: 16, width: 4; type :w1c; initial_value 0; reference 'register_0.bit_field_0' }
    bit_field { name 'bit_field_5'; bit_assignment lsb: 20, width: 4; type :ro ;                  reference 'register_6.bit_field_4' }
    bit_field { name 'bit_field_6'; bit_assignment lsb: 24, width: 4; type :w0s; initial_value 0 }
    bit_field { name 'bit_field_7'; bit_assignment lsb: 28, width: 4; type :w1s; initial_value 0 }
  }

  register {
    name 'register_7'
    offset_address 0x20
    size 4
    # bit assignments: [7:0] [23:16] [39:32] [55:48]
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 8, sequence_size: 4, step: 16; type :rw; initial_value 0 }
    # bit assignments: [15:8] [31:24] [47:40] [63:56]
    bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8, sequence_size: 4, step: 16; type :rw; initial_value 0 }
  }

  register {
    name 'register_8'
    offset_address 0x40
    size [2, 4]
    type [:indirect, 'register_0.bit_field_0', 'register_0.bit_field_1', ['register_0.bit_field_2', 0], ['register_1', 1]]
    bit_field { name 'bit_field_0'; bit_assignment lsb: 0, width: 8, sequence_size: 4, step: 16; type :rw; initial_value 0 }
    bit_field { name 'bit_field_1'; bit_assignment lsb: 8, width: 8, sequence_size: 4, step: 16; type :rw; initial_value 0 }
  }

  register {
    name 'register_9'
    offset_address 0x80
    size 32
    type :external
  }
}
