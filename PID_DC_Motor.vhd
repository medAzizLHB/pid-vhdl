library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Use this for numeric operations

entity PID_DC_Motor is
    Port (
        clk         : in  STD_LOGIC;               
        reset       : in  STD_LOGIC;               
        setpoint    : in  STD_LOGIC_VECTOR(7 downto 0);  
        feedback    : in  STD_LOGIC_VECTOR(7 downto 0);  
        pwm_output   : out STD_LOGIC                
    );
end PID_DC_Motor;

architecture Behavioral of PID_DC_Motor is

    signal error       : signed(7 downto 0);  -- Change to signed for arithmetic
    signal integral    : INTEGER := 0;  
    signal derivative   : signed(7 downto 0);  -- Change to signed
    signal last_error   : signed(7 downto 0) := (others => '0');
    signal pid_output    : INTEGER := 0;  
    signal pwm_counter   : INTEGER := 0;
    constant PWM_PERIOD  : INTEGER := 1000;       
    constant Kp          : INTEGER := 2;            
    constant Ki          : INTEGER := 1;            
    constant Kd          : INTEGER := 1;            

begin

    -- PID Control Process
    process(clk, reset)
    begin
        if reset = '1' then
            integral <= 0;
            last_error <= (others => '0');
        elsif rising_edge(clk) then
            -- Compute the error as a signed type
            error <= signed(setpoint) - signed(feedback);

            -- Integral calculation with limiting
            integral <= integral + to_integer(error);
            if (integral > 255) then
                integral <= 255;
            elsif (integral < 0) then
                integral <= 0;
            end if;

            -- Derivative calculation
            derivative <= error - last_error;
            last_error <= error;

            -- PID output calculation
            pid_output <= (to_integer(error) * Kp) +
                          (integral * Ki) +
                          (to_integer(derivative) * Kd);
        end if;
    end process;

    -- PWM Generation Process
    process(clk, reset)
    begin
        if reset = '1' then
            pwm_counter <= 0;
            pwm_output <= '0';
        elsif rising_edge(clk) then
            if pwm_counter < PWM_PERIOD then
                pwm_counter <= pwm_counter + 1;
            else
                pwm_counter <= 0;
            end if;

            if pwm_counter < pid_output then
                pwm_output <= '1';
            else
                pwm_output <= '0';
            end if;
        end if;
    end process;

end Behavioral;
