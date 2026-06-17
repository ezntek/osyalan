ifeq ($(OS),Windows_NT)
OUTFILE = osyalan.exe
else
OUTFILE = osyalan
endif

COMMON_ODIN_FLAGS = -out:$(OUTFILE) -show-debug-messages -show-more-timings -linker:radlink

run: debug
ifeq ($(OS),Windows_NT)
	.\\$(OUTFILE)
else
	./$(OUTFILE)
endif

debug:
	odin build src $(COMMON_ODIN_FLAGS) -debug -o:none

release:
	odin build src $(COMMON_ODIN_FLAGS) -o:speed

release_native:
	odin build src $(COMMON_ODIN_FLAGS) -o:speed -microarch:native

.PHONY: clean
clean:
	rm $(OUTFILE) *.pdb
