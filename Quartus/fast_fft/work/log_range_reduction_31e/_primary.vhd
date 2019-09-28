library verilog;
use verilog.vl_types.all;
entity log_range_reduction_31e is
    port(
        a0_in           : in     vl_logic_vector(4 downto 0);
        aclr            : in     vl_logic;
        almostlog       : out    vl_logic_vector(38 downto 0);
        clk_en          : in     vl_logic;
        clock           : in     vl_logic;
        y0_in           : in     vl_logic_vector(24 downto 0);
        z               : out    vl_logic_vector(25 downto 0)
    );
end log_range_reduction_31e;
