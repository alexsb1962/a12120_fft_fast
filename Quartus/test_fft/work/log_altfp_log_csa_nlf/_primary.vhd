library verilog;
use verilog.vl_types.all;
entity log_altfp_log_csa_nlf is
    port(
        aclr            : in     vl_logic;
        clken           : in     vl_logic;
        clock           : in     vl_logic;
        dataa           : in     vl_logic_vector(25 downto 0);
        datab           : in     vl_logic_vector(25 downto 0);
        result          : out    vl_logic_vector(25 downto 0)
    );
end log_altfp_log_csa_nlf;
