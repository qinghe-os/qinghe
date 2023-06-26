# Main building script

$(OUT_DIR):
	mkdir -p $@

rust_package := $(shell cat arch/Cargo.toml | sed -n 's/name = "\([a-z0-9A-Z_\-]*\)"/\1/p')
rust_target_dir := $(CURDIR)/target/$(TARGET)/$(MODE)
rust_elf := $(rust_target_dir)/$(rust_package)

_cargo_build:
	$(call cargo_build,--manifest-path arch/Cargo.toml)
	@cp $(rust_elf) $(OUT_ELF)

$(OUT_BIN): _cargo_build $(OUT_ELF)
	$(OBJCOPY) $(OUT_ELF) --strip-all -O binary $@

.PHONY: _cargo_build
