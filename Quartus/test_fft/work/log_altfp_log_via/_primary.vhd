library verilog;
use verilog.vl_types.all;
entity log_altfp_log_via is
    port(
        clock           : in     vl_logic;
        data            : in     vl_logic_vector(31 downto 0);
        result          : out    vl_logic_vector(31 downto 0)
    );
end log_altfp_log_via;
