library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.simd_fpu_pkg.all;
use IEEE.VITAL_timing.all;
use IEEE.VITAL_primitives.all;
entity lane is



    port
      (
        clk : in std_logic;
        reset : in std_logic;
        lanei : in laneiT;
        laneo : out laneoT
      );
    
  end lane;

  architecture rtl of lane is
      COMPONENT ra2sh_256W_32B_8MX_offWRMSK_8WRGRAN
          port ( 
              CLKA: in std_logic;
              CENA: in std_logic;
              WENA: in std_logic;
              AA: in std_logic_vector(7 downto 0);
              DA: in std_logic_vector(31 downto 0);
              QA: out std_logic_vector(31 downto 0);
              CLKB: in std_logic;
              CENB: in std_logic;
              WENB: in std_logic;
              AB: in std_logic_vector(7 downto 0);
              DB: in std_logic_vector(31 downto 0);
              QB: out std_logic_vector(31 downto 0)
    );
    --attribute VITAL_LEVEL1 of ra2sh_256W_32B_8MX_offWRMSK_8WRGRAN : entity is TRUE;
        end COMPONENT;--ra2sh_256W_32B_8MX_offWRMSK_8WRGRAN;

        -- Declare signals connected to the RAMA
        signal CENA_rama_i :  std_logic;
        signal WENA_rama_i :  std_logic;
        signal AA_rama_i: std_logic_vector(7 downto 0);
        signal DA_rama_i : std_logic_vector(31 downto 0);
        signal QA_rama_i:  std_logic_vector(31 downto 0);
        signal CENB_rama_i : std_logic;
        signal WENB_rama_i:  std_logic;
        signal AB_rama_i : std_logic_vector(7 downto 0);
        signal DB_rama_i: std_logic_vector(31 downto 0);
        signal QB_rama_i: std_logic_vector(31 downto 0);

        -- Declare signals connected to the RAMB
        signal CENA_ramb_i :  std_logic;
        signal WENA_ramb_i :  std_logic;
        signal AA_ramb_i: std_logic_vector(7 downto 0);
        signal DA_ramb_i : std_logic_vector(31 downto 0);
        signal QA_ramb_i:  std_logic_vector(31 downto 0);
        signal CENB_ramb_i : std_logic;
        signal WENB_ramb_i:  std_logic;
        signal AB_ramb_i : std_logic_vector(7 downto 0);
        signal DB_ramb_i: std_logic_vector(31 downto 0);
        signal QB_ramb_i: std_logic_vector(31 downto 0);

        -- Declare signals connected to the RAMZ
        signal CENA_ramz_i :  std_logic;
        signal WENA_ramz_i :  std_logic;
        signal AA_ramz_i: std_logic_vector(7 downto 0);
        signal DA_ramz_i : std_logic_vector(31 downto 0);
        signal QA_ramz_i:  std_logic_vector(31 downto 0);
        signal CENB_ramz_i : std_logic;
        signal WENB_ramz_i:  std_logic;
        signal AB_ramz_i : std_logic_vector(7 downto 0);
        signal DB_ramz_i: std_logic_vector(31 downto 0);
        signal QB_ramz_i: std_logic_vector(31 downto 0);
        
        constant DLY : time := 1 ns;


        COMPONENT datapath is

    port
      (
        clk : in std_logic;
        reset : in std_logic;
        dpi : in dpiT;
        dpo : out dpoT
      );
    
  end component datapath;

  -- Datapath connectivity
  signal dpi_i : dpiT;
  signal dpo_i : dpoT;

  signal cmd_ir : cmdT;
  begin

    clkProc : process(clk)
      begin
        if rising_edge(clk) then
          cmd_ir <= lanei.cmd;
        end if;
      end process;
      

      missionModeProc : process(lanei, QA_rama_i, QA_ramb_i, QA_ramz_i, dpo_i, cmd_ir)
          begin
            -- Default: Drive datapath
            dpi_i <= dpiT_INIT;
            laneo <= laneoT_INIT;
            case lanei.mode is
              when DBG =>
                -- In DBG mode, the DBGIF loads the RAMs of the lanes or reads from
                -- the RAMs
                -- Remember RAM controls are active low
                CENA_rama_i <= transport '1' after DLY;
                CENB_rama_i <= transport '1' after DLY;
                WENA_rama_i <= transport '1' after DLY;
                WENB_rama_i <= transport '1' after DLY;
                AA_rama_i <= transport (others=>'0') after DLY;
                AB_rama_i <= transport (others=>'0') after DLY;
                DA_rama_i <= transport conv_std_logic_vector(16#0eadbeef#,32) after DLY;
                DB_rama_i <= transport conv_std_logic_vector(16#0afef00d#,32) after DLY;

                CENA_ramb_i <= transport '1' after DLY;
                CENB_ramb_i <= transport '1' after DLY;
                WENA_ramb_i <= transport '1' after DLY;
                WENB_ramb_i <= transport '1' after DLY;
                AA_ramb_i <= transport (others=>'0') after DLY;
                AB_ramb_i <= transport (others=>'0') after DLY;
                DA_ramb_i <= transport conv_std_logic_vector(16#0eadbeef#,32) after DLY;
                DB_ramb_i <= transport conv_std_logic_vector(16#0afef00d#,32) after DLY;

                CENA_ramz_i <= transport '1' after DLY;
                CENB_ramz_i <= transport '1' after DLY;
                WENA_ramz_i <= transport '1' after DLY;
                WENB_ramz_i <= transport '1' after DLY;
                AA_ramz_i <= transport (others=>'0') after DLY;
                AB_ramz_i <= transport (others=>'0') after DLY;
                DA_ramz_i <= transport conv_std_logic_vector(16#0eadbeef#,32) after DLY;
                DB_ramz_i <= transport conv_std_logic_vector(16#0afef00d#,32) after DLY;
                -- DBG mode
                -- In this mode, the SIMD datapath is idle and the RAM I/O
                -- is released to the DBGIF
                case lanei.cmd is
                  -- RAMA
                  when WRRAMA =>
                    -- Writes only at Port B
                    CENB_rama_i <= transport '0' after DLY;
                    WENB_rama_i <= transport '0' after DLY;
                    AB_rama_i <= transport lanei.addr after DLY;
                    DB_rama_i <= transport lanei.din after DLY;
                  when RDRAMA =>
                    -- Rreads only from Port A
                    CENA_rama_i <= transport '0' after DLY;
                    WENA_rama_i <= transport '1' after DLY;
                    AA_rama_i <= transport lanei.addr after DLY;
                  -- RAMB
                  when WRRAMB =>
                    -- Writes only at Port B
                    CENB_ramb_i <= transport '0' after DLY;
                    WENB_ramb_i <= transport '0' after DLY;
                    AB_ramb_i <= transport lanei.addr after DLY;
                    DB_ramb_i <= transport lanei.din after DLY;
                  when RDRAMB =>
                    -- Rreads only from Port A
                    CENA_ramb_i <= transport '0' after DLY;
                    WENA_ramb_i <= transport '1' after DLY;
                    AA_ramb_i <= transport lanei.addr after DLY;
                  -- RAMZ
                  when WRRAMZ =>
                    -- Writes only at Port B
                    CENB_ramz_i <= transport '0' after DLY;
                    WENB_ramz_i <= transport '0' after DLY;
                    AB_ramz_i <= transport lanei.addr after DLY;
                    DB_ramz_i <= transport lanei.din after DLY;
                  when RDRAMZ =>
                    -- Rreads only from Port A
                    CENA_ramz_i <= transport '0' after DLY;
                    WENA_ramz_i <= transport '1' after DLY;
                    AA_ramz_i <= transport lanei.addr after DLY;
                  when others => -- Don't forget!!!
                end case;

                -- Drive outputs for DBG mode commands
                case cmd_ir is
                  when RDRAMA => laneo.dout <= QA_rama_i;
                  when RDRAMB => laneo.dout <= QA_ramb_i;
                  when RDRAMZ => laneo.dout <= QA_ramz_i;
                  when others => laneo.dout <= conv_std_logic_vector(16#afecafe#,32);
                end case;
              when others => -- Always others!!!
                -- Mission mode
                -- 2 Interfaces:
                -- ########
                -- Read interface (from RAMA/RAMB->datapath)
                dpi_i.opra <= QA_rama_i;
                dpi_i.oprb <= QA_ramb_i;
                dpi_i.addr <= lanei.addr;
                dpi_i.cmd <= lanei.cmd;
                -- Always Enable RAMA (R) for all commands
                CENA_rama_i <= transport '0' after DLY;
                WENA_rama_i <= transport '1' after DLY;
                AA_rama_i <= transport lanei.addr after DLY;
                -- Enable RAMB for dual-operand commands  
                case lanei.cmd is
                  when FADD | FSUB | FMULT | FDIV =>
                    -- Enable RAMB (R)
                    CENA_ramb_i <= transport '0' after DLY;
                    WENA_ramb_i <= transport '1' after DLY;
                    AA_ramb_i <= transport lanei.addr after DLY;
                  when others =>
                        
                end case; -- dpo_i.cmd
                
                -- ########
                -- Write interface (from datapath -> RAMz)
                -- Enable the write port (B) of RAMZ when the command is WR
                if dpo_i.cmd /= NOP then
                  -- Enable RAMZ (W)
                  CENB_ramz_i <= transport '0' after DLY;
                  WENB_ramz_i <= transport '0' after DLY;
                  AB_ramz_i <= transport dpo_i.addr after DLY;
                  DB_ramz_i <= transport dpo_i.res after DLY;
                end if;
            end case; -- Mission
            -- Remember, the only output from the lane is dout. THis is
            -- always coming from port A (reads)
          end process;

      U_RAMA : ra2sh_256W_32B_8MX_offWRMSK_8WRGRAN
          port map
          (
              CLKA => Clk,
              CENA => CENA_rama_i,
              WENA => WENA_rama_i,
              AA => AA_rama_i,
              DA => DA_rama_i,
              QA => QA_rama_i,
              CLKB => Clk,
              CENB => CENB_rama_i,
              WENB => WENB_rama_i,
              AB => AB_rama_i,
              DB => DB_rama_i,
              QB => QB_rama_i

          );

      U_RAMB : ra2sh_256W_32B_8MX_offWRMSK_8WRGRAN
          port map
          (
              CLKA => Clk,
              CENA => CENA_ramb_i,
              WENA => WENA_ramb_i,
              AA => AA_ramb_i,
              DA => DA_ramb_i,
              QA => QA_ramb_i,
              CLKB => Clk,
              CENB => CENB_ramb_i,
              WENB => WENB_ramb_i,
              AB => AB_ramb_i,
              DB => DB_ramb_i,
              QB => QB_ramb_i

          );


          U_RAMZ : ra2sh_256W_32B_8MX_offWRMSK_8WRGRAN
          port map
          (
              CLKA => Clk,
              CENA => CENA_ramz_i,
              WENA => WENA_ramz_i,
              AA => AA_ramz_i,
              DA => DA_ramz_i,
              QA => QA_ramz_i,
              CLKB => Clk,
              CENB => CENB_ramz_i,
              WENB => WENB_ramz_i,
              AB => AB_ramz_i,
              DB => DB_ramz_i,
              QB => QB_ramz_i

          );

          -- Instantiate datapath
          U_datapath : datapath
            port map
            (
              clk => clk,
              reset => reset,
              dpi => dpi_i,
              dpo => dpo_i
            );

  end rtl;
