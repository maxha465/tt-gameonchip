library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_mastermind is
    port (
        ui_in   : in  std_logic_vector(7 downto 0);
        uo_out  : out std_logic_vector(7 downto 0);
        uio_in  : in  std_logic_vector(7 downto 0);
        uio_out : out std_logic_vector(7 downto 0);
        uio_oe  : out std_logic_vector(7 downto 0);
        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end tt_um_mastermind;

architecture Behavioral of tt_um_mastermind is
signal zero_in      : unsigned(2 downto 0) := (others => '0');
signal one_in       : unsigned(2 downto 0) := (others => '0');
signal two_in       : unsigned(2 downto 0) := (others => '0');
signal three_in     : unsigned(2 downto 0) := (others => '0');
signal zero         : unsigned(2 downto 0) := (others => '0');
signal one          : unsigned(2 downto 0) := (others => '0');
signal two          : unsigned(2 downto 0) := (others => '0');
signal three        : unsigned(2 downto 0) := (others => '0');
signal k            : std_logic_vector(3 downto 0);
signal m            : std_logic_vector(3 downto 0);
signal correct      : unsigned(2 downto 0) := (others => '0');
signal half_correct : unsigned(2 downto 0) := (others => '0');
signal dice         : unsigned(11 downto 0) := (others => '0');
signal dice_vector  : std_logic_vector(11 downto 0);
signal submit       : std_logic;
signal submit_old   : std_logic;
signal submit_pulse : std_logic;
signal turns        : unsigned(3 downto 0) := (others => '0');

begin
    -- räknare 
    process(clk, rst_n) begin
        if rising_edge(clk) then
            dice <= dice + 1;
        end if;
    end process;
    dice_vector <= std_logic_vector(dice);

    -- enpulsare
    process(clk) begin
        if rising_edge(clk) then
            submit <= uio_in(4); 
            submit_old <= submit;
        end if;
    end process;

    submit_pulse <= submit and (not submit_old);
     
    process(clk) begin
        if rising_edge(clk) then
            if rst_n = '0' then
                zero <= dice_vector(0) & dice_vector(4) & dice_vector(8);
                one <= dice_vector(1) & dice_vector(5) & dice_vector(9);
                two <= dice_vector(2) & dice_vector(6) & dice_vector(10);
                three <= dice_vector(3) & dice_vector(7) & dice_vector(11);
            end if;
        end if;
    end process;

    -- register
    process(clk) begin
        if rst_n = '0' then
            k <= "0000";
            m <= "0000";
            turns <= "1111";
        elsif rising_edge(clk) then
            if submit_pulse = '1' then
                if zero_in = zero then
                    k(0) <= '1';
                    m(0) <= '0';
                elsif zero = one_in or zero = two_in or zero = three_in then
                    k(0) <= '0';
                    m(0) <= '1';
                else
                    k(0) <= '0';
                    m(0) <= '0';
                end if;

                if one_in = one then
                    k(1) <= '1';
                    m(1) <= '0';
                elsif one = zero_in or one = two_in or one = three_in then
                    k(1) <= '0';
                    m(1) <= '1';
                else
                    k(1) <= '0';
                    m(1) <= '0';
                end if;

                if two_in = two then
                    k(2) <= '1';
                    m(2) <= '0';
                elsif two = zero_in or two = one_in or two = three_in then
                    k(2) <= '0';
                    m(2) <= '1';
                else
                    k(2) <= '0';
                    m(2) <= '0';
                end if;

                if three_in = three then
                    k(3) <= '1';
                    m(3) <= '0';
                elsif three = zero_in or three = one_in or three = two_in then
                    k(3) <= '0';
                    m(3) <= '1';
                else
                    k(3) <= '0';
                    m(3) <= '0';
                end if;

                turns <= turns - 1;
            end if;
        end if;
    end process;

    zero_in <= ui_in(0) & ui_in(1) & ui_in(2);
    one_in <= ui_in(3) & ui_in(4) & ui_in(5);
    two_in <= ui_in(6) & ui_in(7) & uio_in(0);
    three_in <= uio_in(1) & uio_in(2) & uio_in(3);
    
    correct <= (("00" & k(0)) + ("00" & k(1)) + ("00" & k(2)) + ("00" & k(3)));
    half_correct <= (("00" & m(0)) + ("00" & m(1)) + ("00" & m(2)) + ("00" & m(3)));


    uo_out <= std_logic_vector(correct & half_correct & turns(3) & "0");
    uio_out <= ("00000" & turns(0) & turns(1) & turns(2));
    uio_oe <= "00000111";

end Behavioral;