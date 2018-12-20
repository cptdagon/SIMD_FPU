library ieee;
use ieee.std_logic_1164.all;
use work.simd_fpu_pkg.all;

entity simd_fpu is

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
    
  end simd_fpu;

  architecture rtl of simd_fpu is
      -- Declare components
      component dbgif
        port
          (
              clk : in std_logic;
                reset : in std_logic;
                addr : in std_logic_vector(31 downto 0);
        wrdata : in std_logic_vector(31 downto 0);
        rd : in std_logic;
        wr : in std_logic;
        rddata : out std_logic_vector(31 downto 0);
        -- Output to all lanes
        lanei : out allLaneiT;
        -- Input from all lanes
        laneo : in allLaneoT
      );
    
  end component;
component lane
    port
      (
        clk : in std_logic;
        reset : in std_logic;
        lanei : in laneiT;
        laneo : out laneoT
      );
    
  end component;
  -- Declare internal signals
  signal lanei_i :  allLaneiT;
  signal laneo_i : allLaneoT;
  
begin
  -- Instantiate DBGIF
  U_DBGIF : DBGIF
    port map
    (
      clk => clk,
      reset => reset,
      addr => addr,
      wrdata => wrdata,
      rd =>  rd,
      wr => wr,
      rddata => rddata,
      lanei => lanei_i,
      laneo => laneo_i
    );

    -- Instantiate Lanes
    GEN_LANES : for i in 0 to LANES-1 generate
      U_LANE : lane
        port map
        (
          clk => clk,
          reset => reset,
          lanei => lanei_i(i),
          laneo => laneo_i(i)
        );
    end generate;

  end rtl;
