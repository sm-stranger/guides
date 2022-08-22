# change Rust version
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# or
rustup update stable






./target/release/neard --home ~/.near init --chain-id mainnet --download-genesis --download-config


aws s3 --no-sign-request cp --no-sign-request --recursive s3://near-protocol-public/backups/mainnet/archive/$LATEST /data/near_db