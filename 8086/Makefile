###############################################################################
# Makefile - 8086 + MASM (ml.exe) + link16.exe
# - Build dir: build/
# - Sources : all *.asm in current directory
# - Output  : build\ChronoX.exe
# - Map     : build\ChronoX.map
###############################################################################

SHELL := C:/Windows/System32/cmd.exe
.SHELLFLAGS := /c

# ===== Tools =====
ASM     := ml.exe
LINK16  := link16.exe

ASMFLAGS := /c /Zd /Zi /nologo
LDFLAGS  := /CODEVIEW /nologo

# ===== Output =====
BUILD   := build
TARGET  := ChronoX.exe
MAPFILE := $(BUILD)/ChronoX.map

# ===== Sources =====
ASM_SRCS := $(wildcard *.asm)
ifeq ($(strip $(ASM_SRCS)),)
  $(error No .asm files found in current directory)
endif

# ===== Objects (built into build/) =====
OBJS := $(patsubst %.asm,$(BUILD)/%.obj,$(ASM_SRCS))

# link16 wants: obj1+obj2+obj3 (no spaces)
empty :=
space := $(empty) $(empty)
OBJLIST := $(subst $(space),+,$(strip $(OBJS)))

# ---- IMPORTANT: link16 treats '/' as option prefix. Convert to '\' for linking.
to_win = $(subst /,\,$1)

OBJLIST_WIN := $(call to_win,$(OBJLIST))
OUT_WIN     := $(call to_win,$(BUILD)/$(TARGET))
MAP_WIN     := $(call to_win,$(MAPFILE))

.PHONY: all clean rebuild info

all: $(BUILD) $(BUILD)/$(TARGET)

info:
	@echo ASM_SRCS=$(ASM_SRCS)
	@echo OBJLIST=$(OBJLIST)
	@echo OUT=$(BUILD)/$(TARGET)
	@echo MAP=$(MAPFILE)

$(BUILD):
	@if not exist "$(BUILD)" mkdir "$(BUILD)"

# Assemble: xxx.asm -> build/xxx.obj
$(BUILD)/%.obj: %.asm | $(BUILD)
	$(ASM) $(ASMFLAGS) /Fo$@ $<

# Link: build\ChronoX.exe + build\ChronoX.map
$(BUILD)/$(TARGET): $(OBJS) | $(BUILD)
	$(LINK16) $(LDFLAGS) $(OBJLIST_WIN),$(OUT_WIN),$(MAP_WIN),,,

clean:
	@if exist "$(BUILD)" rmdir /s /q "$(BUILD)"

rebuild: clean all
