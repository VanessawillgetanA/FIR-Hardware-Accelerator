module fir_accelerator (
    input  logic signed [7:0] x0, // signed = hardware can represent both +ve and -ve numbers
    input  logic signed [7:0] x1,
    input  logic signed [7:0] x2,

    input  logic signed [7:0] h0,
    input  logic signed [7:0] h1,
    input  logic signed [7:0] h2,

    output logic signed [19:0] y
);

    always_comb begin
        y = (x0 * h0)
          + (x1 * h1)
          + (x2 * h2);
    end

endmodule