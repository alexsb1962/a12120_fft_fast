library verilog;
use verilog.vl_types.all;
entity cypres is
    port(
        ifclk           : in     vl_logic;
        fd              : out    vl_logic_vector(15 downto 0);
        flaga           : in     vl_logic;
        slwr            : out    vl_logic;
        real_data       : in     vl_logic_vector(15 downto 0);
        image_data      : in     vl_logic_vector(15 downto 0);
        exp_data        : in     vl_logic_vector(5 downto 0);
        sink_ready      : out    vl_logic;
        sink_valid      : in     vl_logic;
        reset           : in     vl_logic
    );
end cypres;
