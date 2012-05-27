
all:	sim
SHELL = /bin/sh
#MS=-s

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../rtl/verilog
_TARGETS_=	$(DUT_SRC_DIR)/common/MUX.v			\
			$(DUT_SRC_DIR)/common/ADDER.v		\
			$(DUT_SRC_DIR)/common/MemModel.v 	\
			$(DUT_SRC_DIR)/common/REGISTER.v	\
			$(DUT_SRC_DIR)/ARM_Thumb.v			\
			$(DUT_SRC_DIR)/IF_DP.v				\
			$(DUT_SRC_DIR)/ID_CP.v				\
			$(DUT_SRC_DIR)/ID_DP.v				\
			$(DUT_SRC_DIR)/EXEv2.v				\
			$(DUT_SRC_DIR)/MEM.v				\
			$(DUT_SRC_DIR)/WB.v					\
			$(DUT_SRC_DIR)/NZCVupdater.v		\
			$(DUT_SRC_DIR)/shifter.v			\
			$(DUT_SRC_DIR)/RegFile16x32.v		\
			$(DUT_SRC_DIR)/COND.v				\
			$(DUT_SRC_DIR)/HAZD.v				\


##########################################################################
#
# Test Bench Sources
#
##########################################################################
TB_SRC_DIR=../../../bench/verilog
_TB_=
#_TB_=		$(TB_SRC_DIR)/test_bench_top.v


##########################################################################
#
# Misc Variables
#
##########################################################################

INCDIR=+incdir+./$(DUT_SRC_DIR)/ +incdir+./$(TB_SRC_DIR)/
LOGF=-l .nclog

ACCESS=+access+rw

##########################################################################
#
# Make Targets
#
##########################################################################

ss:
	signalscan -do waves/waves.do -waves waves/waves.trn &

simw:
	$(MAKE) $(MS) sim ACCESS="+access+r " WAVES="+define+WAVES"

sim:
	ncverilog $(_TARGETS_) $(_TB_)      \
		$(INCDIR) $(WAVES) $(ACCESS) $(LOGF) +ncstatus  \

gatew:
	@$(MAKE) -s gate ACCESS="+access+r" WAVES="+define+WAVES"

gate:
	ncverilog -q +define+RUDIS_TB $(_TB_) $(UMC_LIB)        \
		$(GATE_NETLIST) $(INCDIR) $(WAVES) $(ACCESS)    \
		$(LOGF) +ncstatus +ncuid+`hostname`

clean:
	rm -rf	./waves/*.dsn ./waves/*.trn		\
		INCA_libs				\
		./verilog.* .nclog hal.log

##########################################################################
