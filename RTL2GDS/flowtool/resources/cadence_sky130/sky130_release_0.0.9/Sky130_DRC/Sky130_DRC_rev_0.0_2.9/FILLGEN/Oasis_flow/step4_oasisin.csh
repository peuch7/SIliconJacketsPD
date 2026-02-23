#!/bin/csh -vf

oasisin \
 -library 	 	CELLNAME.wFill_june20 \
 -oasisFile  	 	CELLNAME.wFill.oas \
 -topCell        	CELLNAME \
 -view           	layout \
 -logFile        	oasisin.log \
 -attachTechFileOfLib  	sky130_fd_pr_main	\
 -hierDepth      	32	\
 -layerMap       	./sky130_fd_pr_main.layermap    \
 -case           	Preserve 	\

