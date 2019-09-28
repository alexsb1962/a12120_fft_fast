library verilog;
use verilog.vl_types.all;
entity fifo_120_48 is
    port(
        aclr            : in     vl_logic;
        data            : in     vl_logic_vector(15 downto 0);
        rdclk           : in     vl_logic;
        rdreq           : in     vl_logic;
        wrclk           : in     vl_logic;
        wrreq           : in     vl_logic;
        q               : out    vl_logic_vector(15 downto 0);
        rdempty         : out    vl_logic;
        wrfull          : out    vl_logic
    );
end fifo_120_48;
