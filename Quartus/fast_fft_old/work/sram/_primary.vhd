library verilog;
use verilog.vl_types.all;
entity sram is
    port(
        adr             : in     vl_logic_vector(18 downto 0);
        we              : in     vl_logic;
        oe              : in     vl_logic;
        data            : inout  vl_logic_vector(15 downto 0)
    );
end sram;
