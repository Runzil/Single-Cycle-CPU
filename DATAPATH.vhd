library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DATAPATH is
Port( Clk: in STD_LOGIC;
		Reset : in STD_LOGIC;
		--IFSTAGE
		nPC_sel : in STD_LOGIC;
		PC_LdEn : in STD_LOGIC;
		Instruction: in STD_LOGIC_VECTOR(31 downto 0);
		PC_out:out STD_LOGIC_VECTOR(31 downto 0);
		--DECSTAGE
		MemtoReg: in STD_LOGIC;
		RegDst : in STD_LOGIC;
		RegWr: in STD_LOGIC;
		ExtOp : in STD_LOGIC_VECTOR(1 downto 0);
		--EXSTAGE
		ALUsrc:in STD_LOGIC;
		ALUctr:in STD_LOGIC_VECTOR(3 downto 0);
		ALU_ovf:out STD_LOGIC;
		ALU_cout:out STD_LOGIC;
		ALU_zero:out STD_LOGIC;
		--MEMSTAGE
		MemWr: in STD_LOGIC;
		ByteOp: in STD_LOGIC;
		--MEMSTAGE ->RAM
		MM_WrEn   :out STD_LOGIC;
		MM_Addr   :out STD_LOGIC_VECTOR(31 downto 0);
		MM_WrData :out STD_LOGIC_VECTOR(31 downto 0);
		MM_RdData :in STD_LOGIC_VECTOR(31 downto 0));
end DATAPATH;

		
	architecture Behavioral of DATAPATH is
	

--------------------DECSTAGE_SIGNALS---------------
Signal busA : STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
Signal busB : STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
Signal ALU_out_Sig : STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
Signal MEM_out_Sig : STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
Signal Extender_out_Sig: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');



------------------------COMPONENTS---------------------------------

Component IFSTAGE is
	Port(	 PC_Immed 	: in STD_LOGIC_VECTOR(31 downto 0);
			 PC_sel 		: in STD_LOGIC;
			 PC_LdEn 	:in STD_LOGIC;
			 Reset 		:in STD_LOGIC;
			 Clk 			:in STD_LOGIC;
			 PC 			: out STD_LOGIC_VECTOR(31 downto 0));
end Component;

Component DECSTAGE is
	Port( Instr : in STD_LOGIC_VECTOR(31 downto 0);
			RF_WrEn: in STD_LOGIC;
			ALU_out : in STD_LOGIC_VECTOR(31 downto 0);
			MEM_out : in STD_LOGIC_VECTOR(31 downto 0);
			RF_WrData_sel : in STD_LOGIC;
			RF_B_sel :in STD_LOGIC;
			ImmExt :in STD_LOGIC_VECTOR(1 downto 0);
			Clk :in STD_LOGIC;
			Immed: out STD_LOGIC_VECTOR(31 downto 0);
			RF_A: out STD_LOGIC_VECTOR(31 downto 0);
			RF_B: out STD_LOGIC_VECTOR(31 downto 0);
			Reset : in STD_LOGIC);
end Component;

Component EXSTAGE is
	Port(RF_A : in STD_LOGIC_VECTOR(31 downto 0);
		  RF_B : in STD_LOGIC_VECTOR(31 downto 0);
		  Immed: in STD_LOGIC_VECTOR(31 downto 0);
		  ALU_Bin_sel: in STD_LOGIC;
		  ALU_func: in STD_LOGIC_VECTOR(3 downto 0);
		  ALU_out: out STD_LOGIC_VECTOR(31 downto 0);
		  ALU_zero: out STD_LOGIC;
		  Ex_Ovf:out STD_LOGIC;
		  Ex_Cout: out STD_LOGIC);
end Component;

Component MEMSTAGE is
	Port(	ByteOp : in STD_LOGIC;
			Mem_WrEn: in STD_LOGIC;
			ALU_MEM_Addr: in STD_LOGIC_VECTOR(31 downto 0);
			MEM_DataIn: in STD_LOGIC_VECTOR(31 downto 0);
			MEM_DataOut: out STD_LOGIC_VECTOR(31 downto 0);
			MM_WrEn: out STD_LOGIC;
			MM_Addr: out STD_LOGIC_VECTOR(31 downto 0);
			MM_WrData: out STD_LOGIC_VECTOR(31 downto 0);
			MM_RdData: in STD_LOGIC_VECTOR(31 downto 0));
end Component;
------------------------------------------------------------------


begin
----------------------------IFSTAGE----------------------------------------
IFSTAGE_Module:
	IFSTAGE Port MAP (PC_Immed  => Extender_out_Sig, --PC_Immed
							PC_sel 	 => nPC_sel,	
							PC_LdEn   => PC_LdEn,	
							Reset 	 => Reset,	
							Clk 		 => Clk,	
							PC 		 => PC_out);
									 
----------------------------DECSTAGE----------------------------------------
DECSTAGE_Module:
	DECSTAGE Port MAP( Instr 			=> Instruction,
							 RF_WrEn			=> RegWr,
							 ALU_out 		=> ALU_out_Sig,
							 MEM_out			=> MEM_out_Sig,
							 RF_WrData_sel	=> MemtoReg,
							 RF_B_sel 		=> RegDst,
							 ImmExt			=> ExtOp, 
							 Clk 				=> Clk,
							 Immed			=> Extender_out_Sig,
							 RF_A				=> busA,
							 RF_B				=> busB,
							 Reset 			=> Reset);

----------------------------EXSTAGE----------------------------------------
EXSTAGE_Module:
	EXSTAGE Port MAP( RF_A 			=> busA,
							RF_B 			=> busB,
						   Immed			=> Extender_out_Sig,
						   ALU_Bin_sel	=> ALUsrc,
							ALU_func		=> ALUctr,
							ALU_out		=> ALU_out_Sig,
							ALU_zero		=> ALU_zero,
							Ex_Ovf		=> ALU_ovf,
							Ex_Cout		=> ALU_cout);
	
----------------------------MEMSTAGE----------------------------------------
MEMSTAGE_Module:
	MEMSTAGE Port MAP( ByteOp 		  => ByteOp,
							 Mem_WrEn	  => MemWr,
							 ALU_MEM_Addr => ALU_out_Sig,
							 MEM_DataIn	  => busB,
							 MEM_DataOut  => MEM_out_Sig,
							 MM_WrEn		  => MM_WrEn,
							 MM_Addr		  => MM_Addr,
							 MM_WrData	  => MM_WrData,
							 MM_RdData	  => MM_RdData);
	

end Behavioral;

