# Arguments
ARCH ?= x86_64
SMP ?= 1
MODE ?= release
LOG ?= warn

FS ?= n
NET ?= n
GRAPHIC ?= n
BUS ?= mmio

QEMU_LOG ?= n

OUT_DIR ?= build

# Platform
ifeq ($(ARCH), x86_64)
  ACCEL ?= y
  PLATFORM ?= pc-x86
  TARGET := x86_64-unknown-none
  BUS := pci
else ifeq ($(ARCH), riscv64)
  ACCEL ?= n
  PLATFORM ?= qemu-virt-riscv
  TARGET := riscv64gc-unknown-none-elf
else ifeq ($(ARCH), aarch64)
  ACCEL ?= n
  PLATFORM ?= qemu-virt-aarch64
  TARGET := aarch64-unknown-none-softfloat
else
  $(error "ARCH" must be one of "x86_64", "riscv64", or "aarch64")
endif

export ARCH
export PLATFORM
export SMP
export MODE
export LOG

OBJDUMP ?= rust-objdump -d --print-imm-hex --x86-asm-syntax=intel
OBJCOPY ?= rust-objcopy --binary-architecture=$(ARCH)
GDB ?= gdb-multiarch

LD_SCRIPT := $(CURDIR)/arch/kernel.ld
OUT_ELF := $(OUT_DIR)/$(PLATFORM).elf
OUT_BIN := $(OUT_DIR)/$(PLATFORM).bin

all: build

include scripts/make/utils.mk
include scripts/make/cargo.mk
include scripts/make/qemu.mk
include scripts/make/build.mk
include scripts/make/test.mk

build: $(OUT_BIN)

disasm:
	$(OBJDUMP) $(OUT_ELF) | less

run: build justrun

justrun:
	$(call run_qemu)

debug: build
	$(call run_qemu_debug) &
	sleep 1
	$(GDB) $(OUT_ELF) \
	  -ex 'target remote localhost:1234' \
	  -ex 'b rust_entry' \
	  -ex 'continue' \
	  -ex 'disp /16i $$pc'

clippy:
	$(call cargo_clippy)

doc:
	$(call cargo_doc)

doc_check_missing:
	$(call cargo_doc,-D missing-docs)

fmt:
	cargo fmt --all

test:
	$(call app_test)

unittest:
	$(call unit_test)

unittest_no_fail_fast:
	$(call unit_test,--no-fail-fast)

disk_img:
ifneq ($(wildcard $(DISK_IMG)),)
	@printf "$(YELLOW_C)warning$(END_C): disk image \"$(DISK_IMG)\" already exists!\n"
else
	$(call make_disk_image,fat32,$(DISK_IMG))
endif

clean:
	rm -rf $(OUT_DIR)/*.bin $(OUT_DIR)/*.elf
	cargo clean --manifest-path arch/Cargo.toml

.PHONY: all build disasm run justrun debug clippy fmt test test_no_fail_fast clean doc disk_image
