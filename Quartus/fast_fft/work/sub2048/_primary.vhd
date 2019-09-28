library verilog;
use verilog.vl_types.all;
entity sub2048 is
    port(
        dataa           : in     vl_logic_vector(11 downto 0);
        result          : out    vl_logic_vector(11 downto 0)
    );
end sub2048;
