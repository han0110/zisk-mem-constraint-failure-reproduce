#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

CARGO_ZISK="$SCRIPT_DIR/zisk/target/release/cargo-zisk"
ELF_PATH="$SCRIPT_DIR/target/elf/riscv64ima-zisk-zkvm-elf/release/zisk-mem-constraint-failure-reproduce"
INPUT_PATH="/tmp/zisk-mem-constraint-failure-reproduce-input"

# Build cargo-zisk
echo "Building cargo-zisk"
cargo build --release -p cargo-zisk --manifest-path "$SCRIPT_DIR/zisk/Cargo.toml"

# Build guest
echo "Building guest"
cd "$SCRIPT_DIR"
"$CARGO_ZISK" build --release

# Generate input
INPUT=${INPUT:-250000}
echo "Generating input n=$INPUT"
python3 -c "import struct,sys; sys.stdout.buffer.write(struct.pack('<QQ',8,$INPUT))" > "$INPUT_PATH"

# Run verify-constraints
echo "Running cargo-zisk verify-constraints -e $ELF_PATH -i $INPUT_PATH"
RUST_LOG=info "$CARGO_ZISK" verify-constraints -e "$ELF_PATH" -i "$INPUT_PATH"
