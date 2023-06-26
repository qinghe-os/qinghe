# Cargo features and build args
default_features := y

build_args-release := --release
build_args-c := --crate-type staticlib
build_args-rust :=

build_args := \
  --target $(TARGET) \
  --target-dir $(CURDIR)/target \
  $(build_args-$(MODE)) \
  $(build_args-$(APP_LANG)) \
  --features "$(features-y)" \

ifeq ($(default_features),n)
  build_args += --no-default-features
endif

rustc_flags := -Clink-args="-T$(LD_SCRIPT) -no-pie"

define cargo_build
  cargo rustc $(build_args) $(1) -- $(rustc_flags)
endef

define cargo_clippy
  cargo clippy --target $(TARGET) --all-features --workspace --exclude axlog
  cargo clippy --target $(TARGET) -p axlog -p percpu -p percpu_macros
endef

all_packages := arch

define cargo_doc
  RUSTDOCFLAGS="--enable-index-page -Zunstable-options -D rustdoc::broken_intra_doc_links $(1)" \
    cargo doc --no-deps --all-features --workspace --exclude "arceos-*"
  @# run twice to fix broken hyperlinks
  $(foreach p,$(all_packages), \
    cargo rustdoc --all-features -p $(p)
  )
  @# for some crates, re-generate without `--all-features`
  cargo doc --no-deps -p percpu
endef
