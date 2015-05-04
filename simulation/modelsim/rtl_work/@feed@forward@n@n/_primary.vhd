library verilog;
use verilog.vl_types.all;
entity FeedForwardNN is
    port(
        x0              : in     vl_logic;
        x1              : in     vl_logic;
        x2              : in     vl_logic;
        x3              : in     vl_logic;
        y0              : out    vl_logic;
        y1              : out    vl_logic;
        CLK             : in     vl_logic
    );
end FeedForwardNN;
