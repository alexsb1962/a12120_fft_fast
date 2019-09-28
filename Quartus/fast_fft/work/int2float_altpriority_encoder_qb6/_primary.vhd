library verilog;
use verilog.vl_types.all;
entity int2float_altpriority_encoder_qb6 is
    port(
        data            : in     vl_logic_vector(31 downto 0);
        q               : out    vl_logic_vector(4 downto 0)
    );
end int2float_altpriority_encoder_qb6;
