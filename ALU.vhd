----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:37:36 03/15/2022 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.ALL;


entity ALU is
	 Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           Op : in STD_LOGIC_VECTOR (3 downto 0);
           Dout : out STD_LOGIC_VECTOR (31 downto 0);
           Zero : out STD_LOGIC;
           Cout : out STD_LOGIC;
           Ovf : out STD_LOGIC);
end ALU;


architecture Behavioral of ALU is
signal OutSignal :STD_LOGIC_VECTOR (31 downto 0) := (others => '0');


begin
	
		OutSignal <= signed(A) + signed(B) 	 when Op = "0000" else 
						 signed(A) - signed(B) 	 when Op="0001" else
						 A AND B				 		 when Op="0010" else
						 A OR B 				 		 when Op="0011" else
						 NOT A 					 	 when Op="0100" else
						 A NAND B 				 	 when Op="0101" else
						 A NOR B 				 	 when Op="0110" else
						 A(31) & A(31 downto 1)  when Op="1000" else
						 '0' & A(31 downto 1)    when Op="1001" else
						 A(30 downto 0) & '0'    when Op="1010" else
						 A(30 downto 0) & A(31)  when Op="1100" else
						 A(0) & A(31 downto 1)   when Op="1101";

		Zero <= '1' when OutSignal = "00000000000000000000000000000000" else
				  '0';

		Ovf <= (A(31) XOR OutSignal(31)) when (((A(31) XNOR B(31)) = '1' ) AND Op = "0000") OR (((A(31) XOR B(31))= '1') AND Op = "0001") else '0';

		Dout <= OutSignal after 10ns;
		
end Behavioral;



