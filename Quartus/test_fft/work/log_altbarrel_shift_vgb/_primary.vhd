library verilog;
use verilog.vl_types.all;
entity log_altbarrel_shift_vgb is
    port(
        data            : in     vl_logic_vector(63 downto 0);
        distance        : in     vl_logic_vector(5 downto 0);
        result          : out    vl_logic_vector(63 downto 0)
    );
end log_altbarrel_shift_vgb;
