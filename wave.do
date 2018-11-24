add_wave {{/nyuProcessor_tb/uut/PC_d}} 
add_wave {{/nyuProcessor_tb/uut/instruction}} 
log_wave {/nyuProcessor_tb/uut/regDst_mux} 
add_wave {{/nyuProcessor_tb/uut/signImm}} 
add_wave {{/nyuProcessor_tb/uut/PCSrc}} 
add_wave {{/nyuProcessor_tb/uut/PCplus4}} {{/nyuProcessor_tb/uut/PCbranch}} 
add_wave {{/nyuProcessor_tb/uut/signext}} {{/nyuProcessor_tb/uut/signext_lshf}} 
add_wave {{/nyuProcessor_tb/uut/instructMem_map/instructAddr}} {{/nyuProcessor_tb/uut/instructMem_map/rd}} 
add_wave {{/nyuProcessor_tb/uut/controlUnit_map/opcode}} {{/nyuProcessor_tb/uut/controlUnit_map/func}} {{/nyuProcessor_tb/uut/controlUnit_map/MemtoReg}} {{/nyuProcessor_tb/uut/controlUnit_map/MemWrite}} {{/nyuProcessor_tb/uut/controlUnit_map/Branch}} {{/nyuProcessor_tb/uut/controlUnit_map/ALUControl}} {{/nyuProcessor_tb/uut/controlUnit_map/ALUsrc}} {{/nyuProcessor_tb/uut/controlUnit_map/RegDst}} {{/nyuProcessor_tb/uut/controlUnit_map/RegWrite}} 
add_wave {{/nyuProcessor_tb/uut/regFile_map/A1}} {{/nyuProcessor_tb/uut/regFile_map/A2}} {{/nyuProcessor_tb/uut/regFile_map/A3}} {{/nyuProcessor_tb/uut/regFile_map/WD3}} {{/nyuProcessor_tb/uut/regFile_map/WE3}} {{/nyuProcessor_tb/uut/regFile_map/RD1}} {{/nyuProcessor_tb/uut/regFile_map/RD2}} 
add_wave {{/nyuProcessor_tb/uut/ALU_map/ALUControl}} {{/nyuProcessor_tb/uut/ALU_map/SrcA}} {{/nyuProcessor_tb/uut/ALU_map/SrcB}} {{/nyuProcessor_tb/uut/ALU_map/Zero}} {{/nyuProcessor_tb/uut/ALU_map/ALUResult}} 
add_wave {{/nyuProcessor_tb/uut/dataMem_map/ALUResult}} {{/nyuProcessor_tb/uut/dataMem_map/WriteData}} {{/nyuProcessor_tb/uut/dataMem_map/MemWrite}} {{/nyuProcessor_tb/uut/dataMem_map/ReadData}} 
