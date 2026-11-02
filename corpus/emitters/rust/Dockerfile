FROM rust:1.99.1
RUN rustup component add llvm-tools-preview \
 && cargo install --locked cargo-llvm-cov@0.9.1 cargo-tarpaulin@0.37.5 \
 && rm -rf /usr/local/cargo/registry
