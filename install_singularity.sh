#!/bin/bash

#set -euo pipefail

# Check if two arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <tmp_dir> <install_path> [use_mirror]"
    exit 1
fi

tmp_dir=$1
install_path=$2

if [ $# -eq 3 ]; then
    use_mirror=true
else
    use_mirror=false
fi

# Ensure directories exist
mkdir -p "$tmp_dir" "$install_path"

get_absolute_path() {
    local path="$1"
    # Check if the path starts with '/'
    if [[ "$path" == /* ]]; then
        echo "$path"  # Absolute path, return as is
    else
        echo "$(realpath "$path")"  # Convert relative path to absolute
    fi
}

tmp_dir=$(get_absolute_path $tmp_dir)

install_path=$(get_absolute_path $install_path)

# Function to download and extract tarballs
download_and_extract() {
    local url=$1 output=$2 extract_dir=$3
    wget "$url" -O "$output"
    tar -C "$extract_dir" -xzf "$output"
}

# Download and install Go
cd "$tmp_dir" || exit 1
GO_URL=$(curl -s https://go.dev/dl/ | grep -o '/dl/go[0-9.]*.linux-amd64.tar.gz' | head -n1)
if ! $use_mirror; then
     GO_URL="https://go.dev${GO_URL}"
else
     GO_URL=$(curl -s https://go.dev/dl/ | grep -o '/go[0-9.]*.linux-amd64.tar.gz' | head -n1)
     GO_URL="https://mirrors.aliyun.com/golang${GO_URL}"
fi
echo $GO_URL
download_and_extract "$GO_URL" "go.tar.gz" "$install_path"
export PATH="$PATH:$install_path/go/bin"
cd -

# Download, build, and install Singularity
SINGULAR_TAG=$(curl -s https://api.github.com/repos/apptainer/singularity/releases/latest | grep 'tag_name' | cut -d '"' -f4)
SINGULAR_TAR="https://github.com/apptainer/singularity/releases/download/${SINGULAR_TAG}/singularity-${SINGULAR_TAG#v}.tar.gz"
download_and_extract "$SINGULAR_TAR" "$tmp_dir/singularity.tar.gz" "$tmp_dir"
SINGULAR_DIR="$tmp_dir/singularity-${SINGULAR_TAG#v}"
cd "$SINGULAR_DIR" || exit 1
./mconfig --prefix="$install_path/singularity"
make -C ./builddir
make -C ./builddir install

# Set environment variables based on shell
current_shell=$(basename "$SHELL")
if [ "$current_shell" = "bash" ]; then
    config_file="$HOME/.bashrc"
elif [ "$current_shell" = "zsh" ]; then
    config_file="$HOME/.zshrc"
else
    echo "Unsupported shell: $current_shell. Please manually add: export PATH=\"\$PATH:$install_path/go/bin:$install_path/singularity/bin\""
    exit 1
fi

echo "export PATH=\"\$PATH:$install_path/go/bin:$install_path/singularity/bin\"" >> "$config_file"
echo "Environment variables added to $config_file. Run 'source $config_file' or restart your shell."
