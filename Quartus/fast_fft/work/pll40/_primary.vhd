library verilog;
use verilog.vl_types.all;
entity pll40 is
    port(
        inclk0          : in     vl_logic;
        c0              : out    vl_logic
    );
end pll40;
