RUST_DIR = rust
PASCAL_DIR = pascal
TARGET_DIR = ../target/release
BUILD_DIR = $(PASCAL_DIR)/build

APP_NAME = main

.PHONY: all clean run valgrind rust fpc

all: rust fpc

rust:

	cd $(RUST_DIR) && cargo build --release

fpc: rust
	@mkdir -p $(BUILD_DIR)
	fpc -Mobjfpc -Sh -Fl$(TARGET_DIR) -FU$(BUILD_DIR) -FE$(BUILD_DIR) $(PASCAL_DIR)/$(APP_NAME).pas

run:
	LD_LIBRARY_PATH=$(TARGET_DIR) ./$(BUILD_DIR)/$(APP_NAME)

valgrind:
	LD_LIBRARY_PATH=$(TARGET_DIR) valgrind --leak-check=full --show-leak-kinds=all ./$(BUILD_DIR)/$(APP_NAME)

clean:
	cd $(RUST_DIR) && cargo clean
	rm -rf $(BUILD_DIR)
	rm -f $(APP_NAME)
