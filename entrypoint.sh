#!/bin/bash

# Source environment variables
source ~/.bashrc
rustup default esp
# Run the command passed as arguments
exec "$@"