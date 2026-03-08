#!/usr/bin/env bash

set -e

echo "========================================="
echo "Claude Code + LiteLLM Setup"
echo "========================================="
echo

# ---------------------------
# STEP 0 - Ask for LiteLLM URL
# ---------------------------

read -p "Enter your LiteLLM URL: " BASE_URL

if [[ -z "$BASE_URL" ]]; then
    echo "LiteLLM URL is required. Exiting."
    exit 1
fi

echo "Using LiteLLM URL: $BASE_URL"
echo

# ---------------------------
# STEP 1 - Ensure API KEY
# ---------------------------

read -p "Do you have a LiteLLM API key? (y/n): " HAS_KEY

if [[ "$HAS_KEY" != "y" ]]; then
    echo
    read -p "Do you already have a LiteLLM account? (y/n): " HAS_ACCOUNT

    if [[ "$HAS_ACCOUNT" == "y" ]]; then
        echo
        echo "Please generate an API key from:"
        echo "$BASE_URL"
        echo
        echo "After generating the key, run this setup again."
        exit 0
    else
        echo
        echo "You need a LiteLLM account."
        echo
        echo "Please contact DevOps to request access."
        echo
        echo "After you receive access:"
        echo "1. Login to $BASE_URL"
        echo "2. Generate an API key"
        echo "3. Run this setup script again"
        exit 0
    fi
fi

echo
read -s -p "Paste your LiteLLM API key: " LITELLM_KEY
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
# STEP 5 - Configure environment
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
