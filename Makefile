# Paths
RUST_DIR = .
PASCAL_DIR = pascal
TARGET_DIR = $(RUST_DIR)/target/release
BUILD_DIR = $(PASCAL_DIR)/build

# Binary name
APP_NAME = main

.PHONY: all clean run valgrind

all: rust fpc

rust:
	cargo build --release

fpc: rust
	@mkdir -p $(BUILD_DIR)
	fpc -Mobjfpc -Sh -Fl$(TARGET_DIR) -FU$(BUILD_DIR) -FE$(BUILD_DIR) $(PASCAL_DIR)/$(APP_NAME).pas

run:
	LD_LIBRARY_PATH=$(TARGET_DIR) ./$(BUILD_DIR)/$(APP_NAME)

valgrind:
	LD_LIBRARY_PATH=$(TARGET_DIR) valgrind --leak-check=full --show-leak-kinds=all ./$(BUILD_DIR)/$(APP_NAME)

clean:
	cargo clean
	rm -rf $(BUILD_DIR)
	rm -f $(APP_NAME)
