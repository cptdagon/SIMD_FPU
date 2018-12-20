library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.simd_fpu_pkg.all;
use IEEE.VITAL_timing.all;
use IEEE.VITAL_primitives.all;
entity datapath is

    port
      (
        clk : in std_logic;
        reset : in std_logic;
        dpi : in dpiT;
        dpo : out dpoT
      );
    
  end datapath;

  architecture rtl of datapath is
    -- Declare inp regs
    signal dpi_ir : dpiT;

    -- Declare internal decode signals -- CW_fp_addsub
    signal add_sub_a_i : std_logic_vector(31 downto 0);
    signal add_sub_b_i : std_logic_vector(31 downto 0);
    signal rnd_i : std_logic_vector(2 downto 0);
    signal add_sub_op_i : std_logic;
    signal add_sub_res_i : std_logic_vector(31 downto 0);

    -- Declare internal decode signals -- CW_fp_mult
    signal mult_a_i : std_logic_vector(31 downto 0);
    signal mult_b_i : std_logic_vector(31 downto 0);
    signal mult_res_i : std_logic_vector(31 downto 0);

    -- Declare internal decode signals -- CW_fp_mult
    signal div_a_i : std_logic_vector(31 downto 0);
    signal div_b_i : std_logic_vector(31 downto 0);
    signal div_res_i : std_logic_vector(31 downto 0);

    -- Declare internal decode signals -- CW_fp_exp2
    signal exp2_a_i : std_logic_vector(31 downto 0);
    signal exp2_res_i : std_logic_vector(31 downto 0);

    -- Declare internal decode signals -- CW_fp_log2
    signal log2_a_i : std_logic_vector(31 downto 0);
    signal log2_res_i : std_logic_vector(31 downto 0);

    
    -- Declare internal decode signals -- CW_fp_i2flt
    signal i2flt_a_i : std_logic_vector(31 downto 0);
    signal i2flt_res_i : std_logic_vector(31 downto 0);
    
    -- Declare internal decode signals -- CW_fp_flt2i
    signal flt2i_a_i : std_logic_vector(31 downto 0);
    signal flt2i_res_i : std_logic_vector(31 downto 0);
    
    signal dpo_i : dpoT;

    -- Declare CW_fp_addsub component
    component CW_fp_addsub
      generic
        (
          sig_width : integer :=23;
          exp_width : integer := 8;
          ieee_compliance : integer := 1
        );
        port
        (
          a : in std_logic_vector(31 downto 0);
          b : in std_logic_vector(31 downto 0);
          rnd : in std_logic_vector(2 downto 0);
          op : in std_logic;
          status : out std_logic_vector(7 downto 0);
          z : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Declare CW_fp_addsub component
    component CW_fp_mult
      generic
        (
          sig_width : integer :=23;
          exp_width : integer := 8;
          ieee_compliance : integer := 1
        );
        port
        (
          a : in std_logic_vector(31 downto 0);
          b : in std_logic_vector(31 downto 0);
          rnd : in std_logic_vector(2 downto 0);
          status : out std_logic_vector(7 downto 0);
          z : out std_logic_vector(31 downto 0)
        );
    end component;


    -- Declare CW_fp_addsub component
    component CW_fp_exp2
      generic
        (
          sig_width : integer :=23;
          exp_width : integer := 8;
          ieee_compliance : integer := 1
        );
        port
        (
          a : in std_logic_vector(31 downto 0);
          status : out std_logic_vector(7 downto 0);
          z : out std_logic_vector(31 downto 0)
        );
    end component;

        -- Declare CW_fp_addsub component
    component CW_fp_log2
      generic
        (
          sig_width : integer :=23;
          exp_width : integer := 8;
          ieee_compliance : integer := 1
        );
        port
        (
          a : in std_logic_vector(31 downto 0);
          status : out std_logic_vector(7 downto 0);
          z : out std_logic_vector(31 downto 0)
        );
    end component;

    
    -- Declare CW_fp_div component
    component CW_fp_div
      generic
        (
          sig_width : integer :=23;
          exp_width : integer := 8;
          ieee_compliance : integer := 1
        );
        port
        (
          a : in std_logic_vector(31 downto 0);
          b : in std_logic_vector(31 downto 0);
          rnd : in std_logic_vector(2 downto 0);
          status : out std_logic_vector(7 downto 0);
          z : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Declare CW_fp_i2flt component
    component CW_fp_i2flt
      generic
        (
          sig_width : integer :=23;
          exp_width : integer := 8;
          ieee_compliance : integer := 1
        );
        port
        (
          a : in std_logic_vector(31 downto 0);
          rnd : in std_logic_vector(2 downto 0);
          status : out std_logic_vector(7 downto 0);
          z : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Declare CW_fp_i2flt component
    component CW_fp_flt2i
      generic
        (
          sig_width : integer :=23;
          exp_width : integer := 8;
          ieee_compliance : integer := 1
        );
        port
        (
          a : in std_logic_vector(31 downto 0);
          rnd : in std_logic_vector(2 downto 0);
          status : out std_logic_vector(7 downto 0);
          z : out std_logic_vector(31 downto 0)
        );
    end component;
    
    begin

      -- Input registers

      inpRegsProc : process (clk ,reset)
        begin
          if reset = '1' then
            dpi_ir <= dpiT_INIT;
          elsif rising_edge(clk) then
            dpi_ir <= dpi;
          end if;
        end process;


      -- Output registers

      outpRegsProc : process (clk ,reset)
        begin
          if reset = '1' then
            dpo <= dpoT_INIT;
          elsif rising_edge(clk) then
            dpo <= dpo_i;
          end if;
        end process;

      -- Instantiate CW_fp_addsub
      U_CW_fp_addsub : CW_fp_addsub
        generic map
        (
          sig_width => 23,
          exp_width => 8,
          ieee_compliance => 1
        )
        port map
        (
          a => add_sub_a_i,
          b => add_sub_b_i,
          op => add_sub_op_i,
          rnd => rnd_i,
          z => add_sub_res_i,
          status =>open
        );
      -- Instantiate CW_fp_mult
      U_CW_fp_mult : CW_fp_mult
        generic map
        (
          sig_width => 23,
          exp_width => 8,
          ieee_compliance => 1
        )
        port map
        (
          a => mult_a_i,
          b => mult_b_i,
          rnd => rnd_i,
          z => mult_res_i,
          status =>open
        );

        -- Instantiate CW_fp_div
      U_CW_fpdiv : CW_fp_div
        generic map
        (
          sig_width => 23,
          exp_width => 8,
          ieee_compliance => 1
        )
        port map
        (
          a => div_a_i,
          b => div_b_i,
          rnd => rnd_i,
          z => div_res_i,
          status =>open
        ); 



        -- Instantiate CW_fp_exp2
      U_CW_fp_exp2 : CW_fp_exp2
        generic map
        (
          sig_width => 23,
          exp_width => 8,
          ieee_compliance => 1
        )
        port map
        (
          a => exp2_a_i,
          z => exp2_res_i,
          status =>open
        ); 

        -- Instantiate CW_fp_exp2
      U_CW_fp_log2 : CW_fp_log2
        generic map
        (
          sig_width => 23,
          exp_width => 8,
          ieee_compliance => 1
        )
        port map
        (
          a => log2_a_i,
          z => log2_res_i,
          status =>open
        ); 



-- Instantiate CW_fp_exp2
      U_CW_fp_i2flt : CW_fp_i2flt
        generic map
        (
          sig_width => 23,
          exp_width => 8,
          ieee_compliance => 1
        )
        port map
        (
          a => i2flt_a_i,
          z => i2flt_res_i,
          rnd => rnd_i,
          status =>open
        ); 

        -- Instantiate CW_fp_exp2
      U_CW_fp_flt2i : CW_fp_flt2i
        generic map
        (
          sig_width => 23,
          exp_width => 8,
          ieee_compliance => 1
        )
        port map
        (
          a => flt2i_a_i,
          z => flt2i_res_i,
          rnd => rnd_i,
          status =>open
        ); 

        
-- Simple Decode Process
        decProc : process (dpi_ir)
          begin
            -- Default assignments
            add_sub_a_i <= dpi_ir.opra;
            add_sub_b_i <= dpi_ir.oprb;
            mult_a_i <= dpi_ir.opra;
            mult_b_i <= dpi_ir.oprb;
            div_a_i <= dpi_ir.opra;
            div_b_i <= dpi_ir.oprb;

            exp2_a_i <= dpi_ir.opra;
            log2_a_i <= dpi_ir.opra;
            i2flt_a_i <= dpi_ir.opra;
            flt2i_a_i <= dpi_ir.opra;
            
            rnd_i <= "000";
            case dpi_ir.cmd is
              when FADD => add_sub_op_i <= '0';
               when others => add_sub_op_i <= '1';
            end case;
          end process;

        -- Output mux proc
          outMxProc : process (dpi_ir, add_sub_res_i, mult_res_i, div_res_i, exp2_res_i, i2flt_res_i, flt2i_res_i, log2_res_i)
            begin
              -- Universal outputs
              dpo_i.addr <= dpi_ir.addr;
              dpo_i.cmd <= dpi_ir.cmd;
              -- Results per datapath component
              case dpi_ir.cmd is
                when FADD | FSUB => dpo_i.res <= add_sub_res_i;
                when FMULT => dpo_i.res <= mult_res_i;
                when FDIV => dpo_i.res <= div_res_i;
                when FEXP2 => dpo_i.res <= exp2_res_i;
                when I2F => dpo_i.res <= i2flt_res_i;
                when F2I => dpo_i.res <= flt2i_res_i;
                when LOG2 => dpo_i.res <= log2_res_i;
                              -- ADD MORE STUFF !!
                when others => dpo_i.res <= (others=>'1');
                end case;
            end process;
        
    end rtl;
