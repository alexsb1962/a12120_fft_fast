library verilog;
use verilog.vl_types.all;
entity cypres is
    port(
        ifclk           : in     vl_logic;
        fd              : out    vl_logic_vector(15 downto 0);
        flaga           : in     vl_logic;
        slwr            : out    vl_logic;
        fdata           : in     vl_logic_vector(31 downto 0);
        sink_ready      : out    vl_logic;
        sink_valid      : in     vl_logic;
        reset           : in     vl_logic
    );
end cypres;
