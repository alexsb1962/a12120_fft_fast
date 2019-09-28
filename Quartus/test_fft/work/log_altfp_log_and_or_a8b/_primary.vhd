library verilog;
use verilog.vl_types.all;
entity log_altfp_log_and_or_a8b is
    port(
        aclr            : in     vl_logic;
        clken           : in     vl_logic;
        clock           : in     vl_logic;
        data            : in     vl_logic_vector(22 downto 0);
        result          : out    vl_logic
    );
end log_altfp_log_and_or_a8b;
