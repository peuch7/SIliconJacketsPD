.PHONY = clean archive purge

ARCHIVE_ROOT 				:= archives
FLOW_DEFAULT_FILES 	:= envsetup .git resources scripts Makefile archives .gitignore src README.md

.ONESHELL:

clean:
	@echo "Cleaning up non-default files..."
	@find . -maxdepth 1 ! -path . \
		$(foreach item,$(FLOW_DEFAULT_FILES),! -name "$(item)")	-exec rm -rf {} +
	# we have to manually delete some files because Cadence is an evil corporation
	@rm -rf scripts/*lock_flush
	@echo "Cleanup complete."

archive:
	@if [ -z "$(NAME)" ]; then 
		echo "Error: You must provide a name for this archive's folder." 
		echo " " 
		echo "Usage: make archive NAME=archive_name" 
	elif [ -d "$(ARCHIVE_ROOT)/$(NAME)" ]; then 
		echo "Error: $(ARCHIVE_ROOT)/$(NAME)/ already exists. Try again with a different NAME." 
	else 
		echo "=> Creating directory $(ARCHIVE_ROOT)/$(NAME)/ ..." 
		mkdir -p $(ARCHIVE_ROOT)/$(NAME)/ 
		echo "=> Copying flow outputs to $(ARCHIVE_ROOT)/$(NAME)/ ..." 
		rsync -av $(foreach x,$(FLOW_DEFAULT_FILES),--exclude='$(x)') . $(ARCHIVE_ROOT)/$(NAME)/ 
		echo "=> Archive complete." 
	fi

#This purges all archived reports
purge:
	-@ rm -rf archives
