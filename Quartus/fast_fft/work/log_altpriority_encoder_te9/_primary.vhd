library verilog;
use verilog.vl_types.all;
entity log_altpriority_encoder_te9 is
    port(
        data            : in     vl_logic_vector(31 downto 0);
        q               : out    vl_logic_vector(4 downto 0);
        zero            : out    vl_logic
    );
end log_altpriority_encoder_te9;
