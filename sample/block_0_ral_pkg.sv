package block_0_ral_pkg;
  import uvm_pkg::*;
  import rggen_ral_pkg::*;
  `include "uvm_macros.svh"
  `include "rggen_ral_macros.svh"
  class register_0_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0;
    rand rggen_ral_field bit_field_1;
    rand rggen_ral_field bit_field_2;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field_model(bit_field_0, 0, 4, RW, 0, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_1, 4, 4, RW, 0, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_2, 8, 1, RW, 0, 1'h0, 1)
    endfunction
  endclass
  class register_1_reg_model extends rggen_ral_reg;
    rand rggen_ral_field register_1;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field_model(register_1, 0, 1, RW, 0, 1'h0, 1)
    endfunction
  endclass
  class register_2_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0;
    rand rggen_ral_field bit_field_1;
    rand rggen_ral_field bit_field_2;
    rand rggen_ral_field bit_field_3;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field_model(bit_field_0, 0, 4, RO, 1, 4'h0, 0)
      `rggen_ral_create_field_model(bit_field_1, 8, 4, RO, 1, 4'h0, 0)
      `rggen_ral_create_field_model(bit_field_2, 16, 8, RO, 0, 8'hab, 1)
      `rggen_ral_create_field_model(bit_field_3, 24, 8, RO, 0, 8'h00, 0)
    endfunction
  endclass
  class register_3_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0;
    rand rggen_ral_w0trg_field bit_field_1;
    rand rggen_ral_w1trg_field bit_field_2;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field_model(bit_field_0, 0, 4, WO, 0, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_1, 8, 4, W0TRG, 0, 4'h0, 0)
      `rggen_ral_create_field_model(bit_field_2, 16, 4, W1TRG, 0, 4'h0, 0)
    endfunction
  endclass
  class register_4_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0;
    rand rggen_ral_field bit_field_1;
    rand rggen_ral_field bit_field_2;
    rand rggen_ral_field bit_field_3;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field_model(bit_field_0, 0, 4, RC, 1, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_1, 8, 4, RC, 1, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_2, 12, 4, RO, 1, 4'h0, 0)
      `rggen_ral_create_field_model(bit_field_3, 16, 4, RS, 1, 4'h0, 1)
    endfunction
  endclass
  class register_5_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0;
    rand rggen_ral_field bit_field_1;
    rand rggen_ral_rwe_field #("", "") bit_field_2;
    rand rggen_ral_rwe_field #("register_0", "bit_field_2") bit_field_3;
    rand rggen_ral_rwe_field #("register_1", "register_1") bit_field_4;
    rand rggen_ral_rwl_field #("", "") bit_field_5;
    rand rggen_ral_rwl_field #("register_0", "bit_field_2") bit_field_6;
    rand rggen_ral_rwl_field #("register_1", "register_1") bit_field_7;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field_model(bit_field_0, 0, 4, RW, 1, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_1, 4, 4, RW, 1, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_2, 8, 2, RWE, 1, 2'h0, 1)
      `rggen_ral_create_field_model(bit_field_3, 10, 2, RWE, 0, 2'h0, 1)
      `rggen_ral_create_field_model(bit_field_4, 12, 2, RWE, 0, 2'h0, 1)
      `rggen_ral_create_field_model(bit_field_5, 16, 2, RWL, 1, 2'h0, 1)
      `rggen_ral_create_field_model(bit_field_6, 18, 2, RWL, 0, 2'h0, 1)
      `rggen_ral_create_field_model(bit_field_7, 20, 2, RWL, 0, 2'h0, 1)
    endfunction
  endclass
  class register_6_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0;
    rand rggen_ral_field bit_field_1;
    rand rggen_ral_field bit_field_2;
    rand rggen_ral_field bit_field_3;
    rand rggen_ral_field bit_field_4;
    rand rggen_ral_field bit_field_5;
    rand rggen_ral_field bit_field_6;
    rand rggen_ral_field bit_field_7;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field_model(bit_field_0, 0, 4, W0C, 1, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_1, 4, 4, W0C, 1, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_2, 8, 4, RO, 1, 4'h0, 0)
      `rggen_ral_create_field_model(bit_field_3, 12, 4, W1C, 1, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_4, 16, 4, W1C, 1, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_5, 20, 4, RO, 1, 4'h0, 0)
      `rggen_ral_create_field_model(bit_field_6, 24, 4, W0S, 1, 4'h0, 1)
      `rggen_ral_create_field_model(bit_field_7, 28, 4, W1S, 1, 4'h0, 1)
    endfunction
  endclass
  class register_7_reg_model extends rggen_ral_reg;
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
      `rggen_ral_create_field_model(bit_field_1[0], 8, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[1], 24, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[2], 40, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[3], 56, 8, RW, 0, 8'h00, 1)
    endfunction
  endclass
  class register_8_reg_model extends rggen_ral_indirect_reg;
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
      `rggen_ral_create_field_model(bit_field_1[0], 8, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[1], 24, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[2], 40, 8, RW, 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_1[3], 56, 8, RW, 0, 8'h00, 1)
    endfunction
    function void setup_index_fields();
      setup_index_field("register_0", "bit_field_0", array_index[0]);
      setup_index_field("register_0", "bit_field_1", array_index[1]);
      setup_index_field("register_0", "bit_field_2", 1'h0);
      setup_index_field("register_1", "register_1", 1'h1);
    endfunction
  endclass
  class block_0_block_model #(
    type REGISTER_9 = rggen_ral_block,
    bit INTEGRATE_REGISTER_9 = 1
  ) extends rggen_ral_block;
    rand register_0_reg_model register_0;
    rand register_1_reg_model register_1;
    rand register_2_reg_model register_2;
    rand register_3_reg_model register_3;
    rand register_4_reg_model register_4;
    rand register_5_reg_model register_5;
    rand register_6_reg_model register_6;
    rand register_7_reg_model register_7[4];
    rand register_8_reg_model register_8[2][4];
    rand REGISTER_9 register_9;
    function new(string name);
      super.new(name);
    endfunction
    function void build();
      `rggen_ral_create_reg_model(register_0, '{}, 8'h00, RW, 0, g_register_0.u_register)
      `rggen_ral_create_reg_model(register_1, '{}, 8'h04, RW, 0, g_register_1.u_register)
      `rggen_ral_create_reg_model(register_2, '{}, 8'h08, RO, 0, g_register_2.u_register)
      `rggen_ral_create_reg_model(register_3, '{}, 8'h08, WO, 0, g_register_3.u_register)
      `rggen_ral_create_reg_model(register_4, '{}, 8'h0c, RO, 0, g_register_4.u_register)
      `rggen_ral_create_reg_model(register_5, '{}, 8'h10, RW, 0, g_register_5.u_register)
      `rggen_ral_create_reg_model(register_6, '{}, 8'h14, RW, 0, g_register_6.u_register)
      `rggen_ral_create_reg_model(register_7[0], '{0}, 8'h20, RW, 0, g_register_7.g[0].u_register)
      `rggen_ral_create_reg_model(register_7[1], '{1}, 8'h28, RW, 0, g_register_7.g[1].u_register)
      `rggen_ral_create_reg_model(register_7[2], '{2}, 8'h30, RW, 0, g_register_7.g[2].u_register)
      `rggen_ral_create_reg_model(register_7[3], '{3}, 8'h38, RW, 0, g_register_7.g[3].u_register)
      `rggen_ral_create_reg_model(register_8[0][0], '{0, 0}, 8'h40, RW, 1, g_register_8.g[0].g[0].u_register)
      `rggen_ral_create_reg_model(register_8[0][1], '{0, 1}, 8'h40, RW, 1, g_register_8.g[0].g[1].u_register)
      `rggen_ral_create_reg_model(register_8[0][2], '{0, 2}, 8'h40, RW, 1, g_register_8.g[0].g[2].u_register)
      `rggen_ral_create_reg_model(register_8[0][3], '{0, 3}, 8'h40, RW, 1, g_register_8.g[0].g[3].u_register)
      `rggen_ral_create_reg_model(register_8[1][0], '{1, 0}, 8'h40, RW, 1, g_register_8.g[1].g[0].u_register)
      `rggen_ral_create_reg_model(register_8[1][1], '{1, 1}, 8'h40, RW, 1, g_register_8.g[1].g[1].u_register)
      `rggen_ral_create_reg_model(register_8[1][2], '{1, 2}, 8'h40, RW, 1, g_register_8.g[1].g[2].u_register)
      `rggen_ral_create_reg_model(register_8[1][3], '{1, 3}, 8'h40, RW, 1, g_register_8.g[1].g[3].u_register)
      `rggen_ral_create_block_model(register_9, 8'h80, this, INTEGRATE_REGISTER_9)
    endfunction
    function uvm_reg_map create_default_map();
      return create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
    endfunction
  endclass
endpackage
