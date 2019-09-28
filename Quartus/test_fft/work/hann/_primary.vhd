library verilog;
use verilog.vl_types.all;
entity hann is
    port(
        cos             : in     vl_logic_vector(15 downto 0);
        data            : in     vl_logic_vector(15 downto 0);
        result          : out    vl_logic_vector(15 downto 0)
    );
end hann;
