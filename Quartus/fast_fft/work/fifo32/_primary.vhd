library verilog;
use verilog.vl_types.all;
entity fifo32 is
    port(
        aclr            : in     vl_logic;
        data            : in     vl_logic_vector(31 downto 0);
        rdclk           : in     vl_logic;
        rdreq           : in     vl_logic;
        wrclk           : in     vl_logic;
        wrreq           : in     vl_logic;
        q               : out    vl_logic_vector(31 downto 0);
        rdempty         : out    vl_logic;
        rdusedw         : out    vl_logic_vector(3 downto 0)
    );
end fifo32;
