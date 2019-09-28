library verilog;
use verilog.vl_types.all;
entity asvm12120_fft is
    generic(
        LEN_FFT         : integer := 8192
    );
    port(
        fd              : inout  vl_logic_vector(15 downto 0);
        flaga           : in     vl_logic;
        flagb           : in     vl_logic;
        slwr            : out    vl_logic;
        slrd            : out    vl_logic;
        ds              : out    vl_logic;
        lclk            : out    vl_logic;
        clk595          : out    vl_logic;
        ifclk           : in     vl_logic;
        sclk            : in     vl_logic;
        ramd0           : inout  vl_logic_vector(15 downto 0);
        ramd1           : inout  vl_logic_vector(15 downto 0);
        rama0           : out    vl_logic_vector(18 downto 0);
        rama1           : out    vl_logic_vector(18 downto 0);
        ramoe0          : out    vl_logic;
        ramoe1          : out    vl_logic;
        ramwe0          : out    vl_logic;
        ramwe1          : out    vl_logic;
        adc_data        : in     vl_logic_vector(11 downto 0);
        chan            : out    vl_logic;
        pe7             : in     vl_logic;
        pe6             : in     vl_logic;
        pe5             : in     vl_logic;
        k13             : in     vl_logic;
        k14             : out    vl_logic;
        k15             : out    vl_logic;
        k16             : out    vl_logic;
        k17             : out    vl_logic;
        k18             : out    vl_logic;
        k19             : out    vl_logic;
        k20             : out    vl_logic;
        k21             : out    vl_logic;
        k22             : out    vl_logic;
        k23             : out    vl_logic
    );
end asvm12120_fft;
