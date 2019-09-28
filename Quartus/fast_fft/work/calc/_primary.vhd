library verilog;
use verilog.vl_types.all;
entity calc is
    port(
        ifclk           : in     vl_logic;
        reset           : in     vl_logic;
        real_data       : in     vl_logic_vector(15 downto 0);
        image_data      : in     vl_logic_vector(15 downto 0);
        exp_data        : in     vl_logic_vector(5 downto 0);
        source_data     : out    vl_logic_vector(31 downto 0)
    );
end calc;
