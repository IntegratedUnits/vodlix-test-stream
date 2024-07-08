```sudo bash -c '
REPO_URL="https://github.com/IntegratedUnits/vodlix-test-stream.git";
CLONE_DIR="/tmp/vodlix-test-stream";
INSTALL_SCRIPT="install_vodlix_stream.sh";

# Remove existing clone directory if it exists
if [ -d "$CLONE_DIR" ]; then
    rm -rf "$CLONE_DIR";
fi

# Clone the repository
echo "Cloning the repository from $REPO_URL...";
git clone "$REPO_URL" "$CLONE_DIR";

# Change to the cloned directory
cd "$CLONE_DIR";

# Make the install script executable
chmod +x "$INSTALL_SCRIPT";

# Run the install script
./"$INSTALL_SCRIPT";
'```
