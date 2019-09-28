library verilog;
use verilog.vl_types.all;
entity r595 is
    port(
        clk             : in     vl_logic;
        ds              : in     vl_logic;
        load            : in     vl_logic;
        data            : out    vl_logic_vector(15 downto 0)
    );
end r595;
