`ifndef rggen_connect_bit_field_if
  `define rggen_connect_bit_field_if(RIF, FIF, LSB, WIDTH) \
  assign  FIF.valid                 = RIF.valid; \
  assign  FIF.read_mask             = RIF.read_mask[LSB+:WIDTH]; \
  assign  FIF.write_mask            = RIF.write_mask[LSB+:WIDTH]; \
  assign  FIF.write_data            = RIF.write_data[LSB+:WIDTH]; \
  assign  RIF.read_data[LSB+:WIDTH] = FIF.read_data; \
  assign  RIF.value[LSB+:WIDTH]     = FIF.value;
`endif
module block_1
  import rggen_rtl_pkg::*;
(
  input logic i_clk,
  input logic i_rst_n,
  rggen_apb_if.slave apb_if,
  output logic [1:0][3:0][3:0][7:0] o_register_0_bit_field_0,
  output logic [1:0][3:0][3:0][7:0] o_register_1_bit_field_1
);
  rggen_register_if #(7, 32, 64) register_if[16]();
  rggen_apb_adapter #(
    .ADDRESS_WIDTH  (7),
    .BUS_WIDTH      (32),
    .REGISTERS      (16)
  ) u_adapter (
    .i_clk        (i_clk),
    .i_rst_n      (i_rst_n),
    .apb_if       (apb_if),
    .register_if  (register_if)
  );
  generate if (1) begin : g_register_0
    genvar i;
    genvar j;
    for (i = 0;i < 2;++i) begin : g
      for (j = 0;j < 4;++j) begin : g
        rggen_bit_field_if #(64) bit_field_if();
        rggen_default_register #(
          .READABLE       (1),
          .WRITABLE       (1),
          .ADDRESS_WIDTH  (7),
          .OFFSET_ADDRESS (7'h00),
          .BUS_WIDTH      (32),
          .DATA_WIDTH     (64),
          .VALID_BITS     (64'hffffffffffffffff),
          .REGISTER_INDEX (4*i+j)
        ) u_register (
          .i_clk        (i_clk),
          .i_rst_n      (i_rst_n),
          .register_if  (register_if[0+4*i+j]),
          .bit_field_if (bit_field_if)
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
              .o_value      (o_register_0_bit_field_0[i][j][k])
            );
          end
        end
        if (1) begin : g_bit_field_1
          genvar k;
          for (k = 0;k < 4;++k) begin : g
            rggen_bit_field_if #(8) bit_field_sub_if();
            `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8+16*k, 8)
            rggen_bit_field_ro #(
              .WIDTH  (8)
            ) u_bit_field (
              .bit_field_if (bit_field_sub_if),
              .i_value      (register_if[8+4*i+j].value[8+16*k+:8])
            );
          end
        end
      end
    end
  end endgenerate
  generate if (1) begin : g_register_1
    genvar i;
    genvar j;
    for (i = 0;i < 2;++i) begin : g
      for (j = 0;j < 4;++j) begin : g
        rggen_bit_field_if #(64) bit_field_if();
        rggen_default_register #(
          .READABLE       (1),
          .WRITABLE       (1),
          .ADDRESS_WIDTH  (7),
          .OFFSET_ADDRESS (7'h40),
          .BUS_WIDTH      (32),
          .DATA_WIDTH     (64),
          .VALID_BITS     (64'hffffffffffffffff),
          .REGISTER_INDEX (4*i+j)
        ) u_register (
          .i_clk        (i_clk),
          .i_rst_n      (i_rst_n),
          .register_if  (register_if[8+4*i+j]),
          .bit_field_if (bit_field_if)
        );
        if (1) begin : g_bit_field_0
          genvar k;
          for (k = 0;k < 4;++k) begin : g
            rggen_bit_field_if #(8) bit_field_sub_if();
            `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0+16*k, 8)
            rggen_bit_field_ro #(
              .WIDTH  (8)
            ) u_bit_field (
              .bit_field_if (bit_field_sub_if),
              .i_value      (register_if[0+4*i+j].value[0+16*k+:8])
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
              .o_value      (o_register_1_bit_field_1[i][j][k])
            );
          end
        end
      end
    end
  end endgenerate
endmodule
