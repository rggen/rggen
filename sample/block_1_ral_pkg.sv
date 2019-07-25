package block_1_ral_pkg;
  import uvm_pkg::*;
  import rggen_ral_pkg::*;
  `include "uvm_macros.svh"
  `include "rggen_ral_macros.svh"
  class register_0_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0[4];
    rand rggen_ral_field bit_field_1[4];
    function new(string name);
      super.new(name, 64, 0);
    endfunction
    function void build();
      `rggen_ral_create_field_model(bit_field_0[0], 0, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_0[1], 16, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_0[2], 32, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_0[3], 48, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[0], 8, 8, RO, 1, 8'h00, 0)
      `rggen_ral_create_field_model(bit_field_1[1], 24, 8, RO, 1, 8'h00, 0)
      `rggen_ral_create_field_model(bit_field_1[2], 40, 8, RO, 1, 8'h00, 0)
      `rggen_ral_create_field_model(bit_field_1[3], 56, 8, RO, 1, 8'h00, 0)
    endfunction
  endclass
  class register_1_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0[4];
    rand rggen_ral_field bit_field_1[4];
    function new(string name);
      super.new(name, 64, 0);
    endfunction
    function void build();
      `rggen_ral_create_field_model(bit_field_0[0], 0, 8, RO, 1, 8'h00, 0)
      `rggen_ral_create_field_model(bit_field_0[1], 16, 8, RO, 1, 8'h00, 0)
      `rggen_ral_create_field_model(bit_field_0[2], 32, 8, RO, 1, 8'h00, 0)
      `rggen_ral_create_field_model(bit_field_0[3], 48, 8, RO, 1, 8'h00, 0)
      `rggen_ral_create_field_model(bit_field_1[0], 8, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[1], 24, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[2], 40, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[3], 56, 8, RW, 0, 8'h00, 1)
    endfunction
  endclass
  class block_1_block_model extends rggen_ral_block;
    rand register_0_reg_model register_0[2][4];
    rand register_1_reg_model register_1[2][4];
    function new(string name);
      super.new(name);
    endfunction
    function void build();
      `rggen_ral_create_reg_model(register_0[0][0], '{0, 0}, 7'h00, RW, 0, g_register_0.g[0].g[0].u_register)
      `rggen_ral_create_reg_model(register_0[0][1], '{0, 1}, 7'h08, RW, 0, g_register_0.g[0].g[1].u_register)
      `rggen_ral_create_reg_model(register_0[0][2], '{0, 2}, 7'h10, RW, 0, g_register_0.g[0].g[2].u_register)
      `rggen_ral_create_reg_model(register_0[0][3], '{0, 3}, 7'h18, RW, 0, g_register_0.g[0].g[3].u_register)
      `rggen_ral_create_reg_model(register_0[1][0], '{1, 0}, 7'h20, RW, 0, g_register_0.g[1].g[0].u_register)
      `rggen_ral_create_reg_model(register_0[1][1], '{1, 1}, 7'h28, RW, 0, g_register_0.g[1].g[1].u_register)
      `rggen_ral_create_reg_model(register_0[1][2], '{1, 2}, 7'h30, RW, 0, g_register_0.g[1].g[2].u_register)
      `rggen_ral_create_reg_model(register_0[1][3], '{1, 3}, 7'h38, RW, 0, g_register_0.g[1].g[3].u_register)
      `rggen_ral_create_reg_model(register_1[0][0], '{0, 0}, 7'h40, RW, 0, g_register_1.g[0].g[0].u_register)
      `rggen_ral_create_reg_model(register_1[0][1], '{0, 1}, 7'h48, RW, 0, g_register_1.g[0].g[1].u_register)
      `rggen_ral_create_reg_model(register_1[0][2], '{0, 2}, 7'h50, RW, 0, g_register_1.g[0].g[2].u_register)
      `rggen_ral_create_reg_model(register_1[0][3], '{0, 3}, 7'h58, RW, 0, g_register_1.g[0].g[3].u_register)
      `rggen_ral_create_reg_model(register_1[1][0], '{1, 0}, 7'h60, RW, 0, g_register_1.g[1].g[0].u_register)
      `rggen_ral_create_reg_model(register_1[1][1], '{1, 1}, 7'h68, RW, 0, g_register_1.g[1].g[1].u_register)
      `rggen_ral_create_reg_model(register_1[1][2], '{1, 2}, 7'h70, RW, 0, g_register_1.g[1].g[2].u_register)
      `rggen_ral_create_reg_model(register_1[1][3], '{1, 3}, 7'h78, RW, 0, g_register_1.g[1].g[3].u_register)
    endfunction
    function uvm_reg_map create_default_map();
      return create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
    endfunction
  endclass
endpackage
