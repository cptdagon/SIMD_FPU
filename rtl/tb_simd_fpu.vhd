library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.simd_fpu_pkg.all;

entity tb_simd_fpu is

end tb_simd_fpu;

architecture exercise of tb_simd_fpu is
  -- Declare the signals
  signal clk_i :  std_logic;
  signal reset_i : std_logic;
  signal addr_i : std_logic_vector(31 downto 0);
  signal wrdata_i : std_logic_vector(31 downto 0);
  signal rd_i : std_logic;
  signal wr_i : std_logic;
  signal rddata_i : std_logic_vector(31 downto 0);
  -- Clock and delays
  constant CLK_PERIOD : time := 20 ns;
  constant DLY : time := CLK_PERIOD/4;

  constant LOCATIONS : integer := 256;
  -- SIMD_FPU component
  component simd_fpu

    port
      (
        clk : in std_logic;
        reset : in std_logic;
        addr : in std_logic_vector(31 downto 0);
        wrdata : in std_logic_vector(31 downto 0);
        rd : in std_logic;
        wr : in std_logic;
        rddata : out std_logic_vector(31 downto 0)
      );
    
  end component;

  begin
    -- Create clock
    clkmeProc : process
      begin
        clk_i <= '1';
        wait for CLK_PERIOD/2;
        clk_i <= '0';
        wait for CLK_PERIOD/2;
      end process;
    -- Create RESET
    resetmeProc : process
      begin
        wait for DLY;
        reset_i <= '1';
        wait for CLK_PERIOD;
        reset_i <= '0';
        wait;
      end process;      
      -- Instantiate DUT
      DUT :simd_fpu
      port map
      (
        clk =>clk_i,
        reset => reset_i,
        addr => addr_i,
        wrdata => wrdata_i,
        rd => rd_i,
        wr => wr_i,
        rddata => rddata_i
      );

      -- StimulusChk
      stimProc : process
      begin
        wait on reset_i until reset_i = '0';
        addr_i <= conv_std_logic_vector(0,32);
        wrdata_i <= conv_std_logic_vector(0,32);
        rd_i <= '0';
        wr_i <= '0';

          -- wait for a clock and then start writing to registers
          -- This is part of the whole verification campaign which checks the mux.
          --**********************************************************
          -- Check ADDR_REG
          wait for CLK_PERIOD;
          -- Write R0 (opr1)
          addr_i <= conv_std_logic_vector(ADDR_REG , 32);
          wrdata_i <= conv_std_logic_vector(16#dead# , 32);
          wr_i <= '1';
          wait for CLK_PERIOD;
          -- Check R0
          wr_i <= '0';
          rd_i <= '1';
          wait for CLK_PERIOD;
          assert (conv_integer(rddata_i) = 16#dead#) report "SIMD_FPU:ADDR_REG read  error" severity failure;
          -- All OK
          -- Check WRDATA_REG
          rd_i <= '0';
          wait for CLK_PERIOD;
          -- Write R0 (opr1)
          addr_i <= conv_std_logic_vector(WRDATA_REG , 32);
          wrdata_i <= conv_std_logic_vector(16#deadbeef# , 32);
          wr_i <= '1';
          wait for CLK_PERIOD;
          -- Check R0
          wr_i <= '0';
          rd_i <= '1';
          wait for CLK_PERIOD;
        rd_i <= '0';

          assert (conv_integer(rddata_i) = 16#deadbeef#) report "SIMD_FPU:WRDATA_REG read  error" severity failure;

          wait for 8 * CLK_PERIOD;
        -- Time to write to all RAMs
        -- Remember, we have LANES RAMs, each 256 locations deep
        for i in 0 to LANES * LOCATIONS -1 loop
          --------------------------------------
          -- ADDR_REG
          addr_i <= conv_std_logic_vector(ADDR_REG , 32);
          -- Address
          wrdata_i <= conv_std_logic_vector(i , 32);
          -- Perform write cmd to ADDR_REG
          wr_i <= '1';
          -- Wait for a clock
           wait for CLK_PERIOD;
          --------------------------------------
          -- WRDATA_REG
          addr_i <= conv_std_logic_vector(WRDATA_REG , 32);
          wrdata_i <= conv_std_logic_vector(16#cafe# +   i,32);
          -- Perform write cmd to CMD_REG
          wr_i <= '1';
           wait for CLK_PERIOD;
          --------------------------------------
          -- CMD_REG - Issue WRRAMA
          addr_i <= conv_std_logic_vector(CMD_REG , 32);
          wrdata_i <= conv_std_logic_vector(cmdT'pos(WRRAMA),32);
          -- Perform write cmd to CMD_REG
          wr_i <= '1';
          wait for CLK_PERIOD;
          -- Busy-wait
          rd_i <= '1';
          wr_i <= '0';
          addr_i <= conv_std_logic_vector(BUSY_REG,32);
          wait on clk_i until  clk_i = '1' and rddata_i(0) = '0'; wait for DLY;
          --wait for 4*CLK_PERIOD;
          rd_i <= '0';
          --------------------------------------
          -- WRDATA_REG
          addr_i <= conv_std_logic_vector(WRDATA_REG , 32);
          wrdata_i <= conv_std_logic_vector(16#f00d# +   i,32);
          -- Perform write cmd to CMD_REG
          wr_i <= '1';
           wait for CLK_PERIOD;

          --------------------------------------
          -- CMD_REG - Issue WRRAMB
          addr_i <= conv_std_logic_vector(CMD_REG , 32);
          wrdata_i <= conv_std_logic_vector(cmdT'pos(WRRAMB),32);
          -- Perform write cmd to CMD_REG
          wr_i <= '1';
          wait for CLK_PERIOD;
          -- Busy-wait
          rd_i <= '1';
          wr_i <= '0';
          addr_i <= conv_std_logic_vector(BUSY_REG,32);
          wait on clk_i until  clk_i = '1' and rddata_i(0) = '0'; wait for DLY;
          --wait for 4*CLK_PERIOD;
          rd_i <= '0';

          wait for 4 * CLK_PERIOD;
       end loop;

        wait for 100 * CLK_PERIOD;

        -- Time to read back from  all RAMs
        -- Remember, we have LANES RAMs, each 256 locations deep
        for i in 0 to LANES * LOCATIONS -1 loop
          --------------------------------------
          -- ADDR_REG
          addr_i <= conv_std_logic_vector(ADDR_REG , 32);
          -- Address
          wrdata_i <= conv_std_logic_vector(i , 32);
          -- Perform write cmd to ADDR_REG
          wr_i <= '1';
          -- Wait for a clock
           wait for CLK_PERIOD;
          --------------------------------------
          -- CMD_REG
          addr_i <= conv_std_logic_vector(CMD_REG , 32);
          wrdata_i <= conv_std_logic_vector(cmdT'pos(RDRAMA),32);
          -- Perform write cmd to CMD_REG
          wr_i <= '1';
          wait for CLK_PERIOD;
          -- Busy-wait
          rd_i <= '1';
          wr_i <= '0';
          addr_i <= conv_std_logic_vector(BUSY_REG,32);
          wait on clk_i until  clk_i = '1' and rddata_i(0) = '0'; wait for DLY;
          --wait for 4*CLK_PERIOD;
          -- Now, grab thea data
          rd_i <= '1';
          addr_i <= conv_std_logic_vector(RDDATA_REG,32);
          wait for CLK_PERIOD;
          rd_i <= '0';
          -- Now, compare to value written and break if different
          assert (16#cafe# + i=conv_integer(rddata_i)) report "RAMA ERROR" severity failure;
       end loop;

          -- Start operation
          -- CMD_REG
          addr_i <= conv_std_logic_vector(CMD_REG , 32);
          wrdata_i <= conv_std_logic_vector(cmdT'pos(FADD),32);
          -- Perform write cmd to CMD_REG
          wr_i <= '1';
          wait for CLK_PERIOD;
          -- Busy-wait
          rd_i <= '1';
          wr_i <= '0';
          addr_i <= conv_std_logic_vector(BUSY_REG,32);
          wait on clk_i until  clk_i = '1' and rddata_i(0) = '0'; wait for DLY;
          rd_i <= '0';
          
        -- Now, read back
          --rd_i <= '0';
          ---- Now, compare to value written and break if different
          --assert (16#f00d# + i=conv_integer(rddata_i)) report "RAMB ERROR" severity failure;
        -- Finish
        assert (False) report "Simulation ended succsfully" severity failure;

      end process;
  end exercise;
