# Claude Code + LiteLLM Setup

This guide explains how to set up Claude Code to work with LiteLLM and optionally configure Claude Opus 4.6 as the default model for your project.

## Prerequisites

- Ubuntu 22.04 / 24.04 or similar Linux
- Access to LiteLLM 
- Access to a LiteLLM API key
- `git`, `python3`, `pip`, `curl`

## Setup Instructions

1. Download the setup_claude_litellm.sh script.

2. Run the interactive setup script:

   ```bash
   chmod +x setup_claude_litellm.sh
   ./setup_claude_litellm.sh
   ```

3. Follow the prompts:

   - Enter your LiteLLM URL
   - Paste your LiteLLM API key
   - If you don't have a key, the script will guide you to request one
   - Choose whether to configure Claude Opus 4.6 as the default model for a project
   - Provide the project path if configuring the default model

4. Verify installation:

   ```bash
   claude --version
   ```

5. Start using Claude Code:

   ```bash
   cd <your-project>
   claude
   ```

## Notes

- Environment variables `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` are automatically set in your `~/.bashrc`.
- Project-specific model configuration is stored in `<project>/.claude/settings.json`.
- To change the default model later, edit the `settings.json` file or pass `--model <model>` to the `claude` command.

## Support

If you encounter issues:

- Check your LiteLLM API key
- Ensure network access to the LiteLLM URL
- Contact DevOps if you need a LiteLLM account

## Optional

You can choose different models by modifying the `settings.json` file in your project folder or passing the `--model <model>` flag when starting Claude Code.
