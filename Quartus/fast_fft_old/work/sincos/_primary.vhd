library verilog;
use verilog.vl_types.all;
entity sincos is
    port(
        outsin          : out    vl_logic_vector(15 downto 0);
        outcos          : out    vl_logic_vector(15 downto 0);
        sig             : in     vl_logic_vector(11 downto 0);
        perenos         : in     vl_logic;
        get             : in     vl_logic_vector(15 downto 0);
        clock           : in     vl_logic;
        reset           : in     vl_logic
    );
end sincos;
