library verilog;
use verilog.vl_types.all;
entity ram_pos_thru is
    port(
        q               : out    vl_logic_vector(255 downto 0);
        a               : in     vl_logic_vector(3 downto 0);
        d               : in     vl_logic_vector(255 downto 0);
        we              : in     vl_logic;
        clk             : in     vl_logic
    );
end ram_pos_thru;
