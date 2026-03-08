#!/usr/bin/env bash

set -e

echo "========================================="
echo "Claude Code + LiteLLM Interactive Setup"
echo "========================================="
echo

# ---------------------------
# STEP 0 - Ask if user has LiteLLM URL and API key
# ---------------------------

read -p "Do you already have a LiteLLM URL and API key? (y/n): " HAS_LITELLM

if [[ "$HAS_LITELLM" != "y" ]]; then
    echo
    echo "You need a LiteLLM account and API key to proceed."
    echo "Please follow these steps:"
    echo "1. Create/Request a LiteLLM account."
    echo "2. Login to your LiteLLM portal."
    echo "3. Generate an API key."
    echo "4. Run this setup script again."
    exit 0
fi

# ---------------------------
# STEP 1 - Ask for LiteLLM URL and API key
# ---------------------------
echo
read -p "Enter your LiteLLM URL: " BASE_URL
if [[ -z "$BASE_URL" ]]; then
    echo "LiteLLM URL is required. Exiting."
    exit 1
fi

echo
read -s -p "Enter your LiteLLM API key: " LITELLM_KEY
echo

# ---------------------------
# STEP 2 - Verify key
# ---------------------------

echo
echo "Verifying API key..."

if curl -s "$BASE_URL/v1/models" -H "Authorization: Bearer $LITELLM_KEY" | grep -q "data"; then
    echo "Key verified successfully."
else
    echo "Invalid key or cannot reach LiteLLM. Exiting."
    exit 1
fi

# ---------------------------
# STEP 3 - Install dependencies
# ---------------------------

echo
echo "Installing dependencies..."

sudo rm -f /etc/apt/sources.list.d/insomnia.list || true
sudo apt update
sudo apt install -y git python3 python3-pip curl

# ---------------------------
# STEP 4 - Install Claude Code
# ---------------------------

echo
echo "Installing Claude Code..."

curl -fsSL https://claude.ai/install.sh | bash

if ! grep -q '.local/bin' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

source ~/.bashrc

echo
echo "Claude version:"
claude --version

# ---------------------------
# STEP 5 - Configure environment variables
# ---------------------------

echo
echo "Configuring environment variables..."

grep -q "ANTHROPIC_BASE_URL" ~/.bashrc || \
echo "export ANTHROPIC_BASE_URL=\"$BASE_URL\"" >> ~/.bashrc

grep -q "ANTHROPIC_AUTH_TOKEN" ~/.bashrc || \
echo "export ANTHROPIC_AUTH_TOKEN=\"$LITELLM_KEY\"" >> ~/.bashrc

source ~/.bashrc

# ---------------------------
# STEP 6 - Optional project configuration
# ---------------------------

echo
read -p "Do you want to configure Claude Opus 4.6 as the default model for a project? (y/n): " CONFIG_MODEL

if [[ "$CONFIG_MODEL" == "y" ]]; then
    read -p "Enter the full path to your project directory: " PROJECT_PATH

    if [[ ! -d "$PROJECT_PATH" ]]; then
        echo "Directory does not exist. Exiting."
        exit 1
    fi

    mkdir -p "$PROJECT_PATH/.claude"

    cat <<EOF > "$PROJECT_PATH/.claude/settings.json"
{
  "model": "claude-opus-4-6"
}
EOF

    echo
    echo "Default model set to Claude Opus 4.6 for project:"
    echo "$PROJECT_PATH"
fi

echo
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo
echo "You can now use Claude Code in your project:"
echo "cd <your-project>"
echo "claude"
echo