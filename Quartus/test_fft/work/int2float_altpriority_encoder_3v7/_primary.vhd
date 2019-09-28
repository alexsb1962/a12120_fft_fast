library verilog;
use verilog.vl_types.all;
entity int2float_altpriority_encoder_3v7 is
    port(
        data            : in     vl_logic_vector(1 downto 0);
        q               : out    vl_logic_vector(0 downto 0)
    );
end int2float_altpriority_encoder_3v7;
