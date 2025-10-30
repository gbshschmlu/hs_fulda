#!/bin/bash
if ! command -v pandoc &> /dev/null; then
    echo "Installing pandoc..."
    brew install pandoc
fi

# Check if any TeX distribution is installed
if ! command -v pdflatex &> /dev/null; then
    echo "Installing basictex..."
    brew install --cask basictex
else
    echo "TeX distribution already installed, skipping..."
fi

echo "Setup complete!"
