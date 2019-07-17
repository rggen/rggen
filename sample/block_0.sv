`ifndef rggen_connect_bit_field_if
  `define rggen_connect_bit_field_if(RIF, FIF, LSB, WIDTH) \
  assign  FIF.valid                 = RIF.valid; \
  assign  FIF.read_mask             = RIF.read_mask[LSB+:WIDTH]; \
  assign  FIF.write_mask            = RIF.write_mask[LSB+:WIDTH]; \
  assign  FIF.write_data            = RIF.write_data[LSB+:WIDTH]; \
  assign  RIF.read_data[LSB+:WIDTH] = FIF.read_data; \
  assign  RIF.value[LSB+:WIDTH]     = FIF.value;
`endif
module block_0
  import rggen_rtl_pkg::*;
(
  input logic i_clk,
  input logic i_rst_n,
  rggen_apb_if.slave apb_if,
  output logic [3:0] o_register_0_bit_field_0,
  output logic [3:0] o_register_0_bit_field_1,
  output logic o_register_0_bit_field_2,
  input logic [3:0] i_register_1_bit_field_0,
  input logic [3:0] i_register_1_bit_field_1,
  output logic [3:0] o_register_2_bit_field_0,
  output logic [3:0] o_register_2_bit_field_1,
  input logic [3:0] i_register_3_bit_field_0_set,
  output logic [3:0] o_register_3_bit_field_0,
  input logic [3:0] i_register_3_bit_field_1_set,
  output logic [3:0] o_register_3_bit_field_1,
  output logic [3:0] o_register_3_bit_field_1_unmasked,
  input logic [3:0] i_register_3_bit_field_2_clear,
  output logic [3:0] o_register_3_bit_field_2,
  output logic [7:0] o_register_4_bit_field_0,
  output logic [7:0] o_register_4_bit_field_1,
  input logic [3:0] i_register_5_bit_field_0_set,
  output logic [3:0] o_register_5_bit_field_0,
  input logic [3:0] i_register_5_bit_field_1_set,
  output logic [3:0] o_register_5_bit_field_1,
  output logic [3:0] o_register_5_bit_field_1_unmasked,
  input logic [3:0] i_register_5_bit_field_2_set,
  output logic [3:0] o_register_5_bit_field_2,
  input logic [3:0] i_register_5_bit_field_3_set,
  output logic [3:0] o_register_5_bit_field_3,
  output logic [3:0] o_register_5_bit_field_3_unmasked,
  input logic [3:0] i_register_5_bit_field_4_clear,
  output logic [3:0] o_register_5_bit_field_4,
  input logic [3:0] i_register_5_bit_field_5_clear,
  output logic [3:0] o_register_5_bit_field_5,
  output logic [3:0][3:0][7:0] o_register_6_bit_field_0,
  output logic [3:0][3:0][7:0] o_register_6_bit_field_1,
  output logic [1:0][3:0][3:0][7:0] o_register_7_bit_field_0,
  output logic [1:0][3:0][3:0][7:0] o_register_7_bit_field_1,
  rggen_bus_if.master register_8_bus_if
);
  rggen_register_if #(8, 32, 64) register_if[19]();
  rggen_apb_adapter #(
    .ADDRESS_WIDTH  (8),
    .BUS_WIDTH      (32),
    .REGISTERS      (19)
  ) u_adapter (
    .i_clk        (i_clk),
    .i_rst_n      (i_rst_n),
    .apb_if       (apb_if),
    .register_if  (register_if)
  );
  generate if (1) begin : g_register_0
    rggen_bit_field_if #(32) bit_field_if();
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h00),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h000001ff),
      .REGISTER_INDEX (0)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[0]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_bit_field_0
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 4)
      rggen_bit_field_rw #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .o_value      (o_register_0_bit_field_0)
      );
    end
    if (1) begin : g_bit_field_1
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 4, 4)
      rggen_bit_field_rw #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .o_value      (o_register_0_bit_field_1)
      );
    end
    if (1) begin : g_bit_field_2
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 1)
      rggen_bit_field_rw #(
        .WIDTH          (1),
        .INITIAL_VALUE  (1'h0)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .o_value      (o_register_0_bit_field_2)
      );
    end
  end endgenerate
  generate if (1) begin : g_register_1
    rggen_bit_field_if #(32) bit_field_if();
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h04),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h00000f0f),
      .REGISTER_INDEX (0)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[1]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_bit_field_0
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 4)
      rggen_bit_field_ro #(
        .WIDTH  (4)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .i_mask       (4'hf),
        .i_value      (i_register_1_bit_field_0)
      );
    end
    if (1) begin : g_bit_field_1
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 4)
      rggen_bit_field_ro #(
        .WIDTH  (4)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .i_mask       (4'hf),
        .i_value      (i_register_1_bit_field_1)
      );
    end
  end endgenerate
  generate if (1) begin : g_register_2
    rggen_bit_field_if #(32) bit_field_if();
    rggen_default_register #(
      .READABLE       (0),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h04),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h00000f0f),
      .REGISTER_INDEX (0)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[2]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_bit_field_0
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 4)
      rggen_bit_field_wo #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .o_value      (o_register_2_bit_field_0)
      );
    end
    if (1) begin : g_bit_field_1
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 4)
      rggen_bit_field_wo #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .o_value      (o_register_2_bit_field_1)
      );
    end
  end endgenerate
  generate if (1) begin : g_register_3
    rggen_bit_field_if #(32) bit_field_if();
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h08),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h000f0f0f),
      .REGISTER_INDEX (0)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[3]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_bit_field_0
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 4)
      rggen_bit_field_rc #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk            (i_clk),
        .i_rst_n          (i_rst_n),
        .bit_field_if     (bit_field_sub_if),
        .i_set            (i_register_3_bit_field_0_set),
        .i_mask           (4'hf),
        .o_value          (o_register_3_bit_field_0),
        .o_value_unmasked ()
      );
    end
    if (1) begin : g_bit_field_1
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 4)
      rggen_bit_field_rc #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk            (i_clk),
        .i_rst_n          (i_rst_n),
        .bit_field_if     (bit_field_sub_if),
        .i_set            (i_register_3_bit_field_1_set),
        .i_mask           (register_if[0].value[0+:4]),
        .o_value          (o_register_3_bit_field_1),
        .o_value_unmasked (o_register_3_bit_field_1_unmasked)
      );
    end
    if (1) begin : g_bit_field_2
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 4)
      rggen_bit_field_rs #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .i_clear      (i_register_3_bit_field_2_clear),
        .o_value      (o_register_3_bit_field_2)
      );
    end
  end endgenerate
  generate if (1) begin : g_register_4
    rggen_bit_field_if #(32) bit_field_if();
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0c),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h00ff00ff),
      .REGISTER_INDEX (0)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[4]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_bit_field_0
      rggen_bit_field_if #(8) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 8)
      rggen_bit_field_rwe #(
        .WIDTH          (8),
        .INITIAL_VALUE  (8'h00)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .i_enable     (register_if[0].value[8+:1]),
        .o_value      (o_register_4_bit_field_0)
      );
    end
    if (1) begin : g_bit_field_1
      rggen_bit_field_if #(8) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 8)
      rggen_bit_field_rwl #(
        .WIDTH          (8),
        .INITIAL_VALUE  (8'h00)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .i_lock       (register_if[0].value[8+:1]),
        .o_value      (o_register_4_bit_field_1)
      );
    end
  end endgenerate
  generate if (1) begin : g_register_5
    rggen_bit_field_if #(32) bit_field_if();
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h10),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h00ffffff),
      .REGISTER_INDEX (0)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[5]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_bit_field_0
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 4)
      rggen_bit_field_w01c #(
        .CLEAR_VALUE    (1'b0),
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk            (i_clk),
        .i_rst_n          (i_rst_n),
        .bit_field_if     (bit_field_sub_if),
        .i_set            (i_register_5_bit_field_0_set),
        .i_mask           (4'hf),
        .o_value          (o_register_5_bit_field_0),
        .o_value_unmasked ()
      );
    end
    if (1) begin : g_bit_field_1
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 4, 4)
      rggen_bit_field_w01c #(
        .CLEAR_VALUE    (1'b0),
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk            (i_clk),
        .i_rst_n          (i_rst_n),
        .bit_field_if     (bit_field_sub_if),
        .i_set            (i_register_5_bit_field_1_set),
        .i_mask           (register_if[0].value[0+:4]),
        .o_value          (o_register_5_bit_field_1),
        .o_value_unmasked (o_register_5_bit_field_1_unmasked)
      );
    end
    if (1) begin : g_bit_field_2
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 4)
      rggen_bit_field_w01c #(
        .CLEAR_VALUE    (1'b1),
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk            (i_clk),
        .i_rst_n          (i_rst_n),
        .bit_field_if     (bit_field_sub_if),
        .i_set            (i_register_5_bit_field_2_set),
        .i_mask           (4'hf),
        .o_value          (o_register_5_bit_field_2),
        .o_value_unmasked ()
      );
    end
    if (1) begin : g_bit_field_3
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 12, 4)
      rggen_bit_field_w01c #(
        .CLEAR_VALUE    (1'b1),
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk            (i_clk),
        .i_rst_n          (i_rst_n),
        .bit_field_if     (bit_field_sub_if),
        .i_set            (i_register_5_bit_field_3_set),
        .i_mask           (register_if[0].value[0+:4]),
        .o_value          (o_register_5_bit_field_3),
        .o_value_unmasked (o_register_5_bit_field_3_unmasked)
      );
    end
    if (1) begin : g_bit_field_4
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 4)
      rggen_bit_field_w01s #(
        .SET_VALUE      (1'b0),
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .i_clear      (i_register_5_bit_field_4_clear),
        .o_value      (o_register_5_bit_field_4)
      );
    end
    if (1) begin : g_bit_field_5
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 20, 4)
      rggen_bit_field_w01s #(
        .SET_VALUE      (1'b1),
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0)
      ) u_bit_field (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .bit_field_if (bit_field_sub_if),
        .i_clear      (i_register_5_bit_field_5_clear),
        .o_value      (o_register_5_bit_field_5)
      );
    end
  end endgenerate
  generate if (1) begin : g_register_6
    genvar i;
    for (i = 0;i < 4;++i) begin : g
      rggen_bit_field_if #(64) bit_field_if();
      rggen_default_register #(
        .READABLE       (1),
        .WRITABLE       (1),
        .ADDRESS_WIDTH  (8),
        .OFFSET_ADDRESS (8'h20),
        .BUS_WIDTH      (32),
        .DATA_WIDTH     (64),
        .VALID_BITS     (64'hffffffffffffffff),
        .REGISTER_INDEX (i)
      ) u_register (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .register_if  (register_if[6+i]),
        .bit_field_if (bit_field_if)
      );
      if (1) begin : g_bit_field_0
        genvar j;
        for (j = 0;j < 4;++j) begin : g
          rggen_bit_field_if #(8) bit_field_sub_if();
          `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0+16*j, 8)
          rggen_bit_field_rw #(
            .WIDTH          (8),
            .INITIAL_VALUE  (8'h00)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .o_value      (o_register_6_bit_field_0[i][j])
          );
        end
      end
      if (1) begin : g_bit_field_1
        genvar j;
        for (j = 0;j < 4;++j) begin : g
          rggen_bit_field_if #(8) bit_field_sub_if();
          `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8+16*j, 8)
          rggen_bit_field_rw #(
            .WIDTH          (8),
            .INITIAL_VALUE  (8'h00)
          ) u_bit_field (
            .i_clk        (i_clk),
            .i_rst_n      (i_rst_n),
            .bit_field_if (bit_field_sub_if),
            .o_value      (o_register_6_bit_field_1[i][j])
          );
        end
      end
    end
  end endgenerate
  generate if (1) begin : g_register_7
    genvar i;
    genvar j;
    for (i = 0;i < 2;++i) begin : g
      for (j = 0;j < 4;++j) begin : g
        logic [8:0] indirect_index;
        rggen_bit_field_if #(64) bit_field_if();
        assign indirect_index = {register_if[0].value[0+:4], register_if[0].value[4+:4], register_if[0].value[8+:1]};
        rggen_indirect_register #(
          .READABLE             (1),
          .WRITABLE             (1),
          .ADDRESS_WIDTH        (8),
          .OFFSET_ADDRESS       (8'h40),
          .BUS_WIDTH            (32),
          .DATA_WIDTH           (64),
          .VALID_BITS           (64'hffffffffffffffff),
          .INDIRECT_INDEX_WIDTH (9),
          .INDIRECT_INDEX_VALUE ({i[0+:4], j[0+:4], 1'h1})
        ) u_register (
          .i_clk            (i_clk),
          .i_rst_n          (i_rst_n),
          .register_if      (register_if[10+4*i+j]),
          .i_indirect_index (indirect_index),
          .bit_field_if     (bit_field_if)
        );
        if (1) begin : g_bit_field_0
          genvar k;
          for (k = 0;k < 4;++k) begin : g
            rggen_bit_field_if #(8) bit_field_sub_if();
            `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0+16*k, 8)
            rggen_bit_field_rw #(
              .WIDTH          (8),
              .INITIAL_VALUE  (8'h00)
            ) u_bit_field (
              .i_clk        (i_clk),
              .i_rst_n      (i_rst_n),
              .bit_field_if (bit_field_sub_if),
              .o_value      (o_register_7_bit_field_0[i][j][k])
            );
          end
        end
        if (1) begin : g_bit_field_1
          genvar k;
          for (k = 0;k < 4;++k) begin : g
            rggen_bit_field_if #(8) bit_field_sub_if();
            `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8+16*k, 8)
            rggen_bit_field_rw #(
              .WIDTH          (8),
              .INITIAL_VALUE  (8'h00)
            ) u_bit_field (
              .i_clk        (i_clk),
              .i_rst_n      (i_rst_n),
              .bit_field_if (bit_field_sub_if),
              .o_value      (o_register_7_bit_field_1[i][j][k])
            );
          end
        end
      end
    end
  end endgenerate
  generate if (1) begin : g_register_8
    rggen_external_register #(
      .ADDRESS_WIDTH  (8),
      .BUS_WIDTH      (32),
      .START_ADDRESS  (8'h80),
      .END_ADDRESS    (8'hff)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[18]),
      .bus_if       (register_8_bus_if)
    );
  end endgenerate
endmodule
