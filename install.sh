#!/bin/bash
if ! command -v just &> /dev/null
then
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to $(pwd)
else
    echo "just command found, skipping installation"
fi

./just install