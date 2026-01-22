# Contributing to Agentic Project Template

We welcome contributions! This project is designed to be the "Standard Operating System" for AI-assisted development.

## How to Contribute

1.  **Fork the Repo**: Click the fork button.
2.  **Create a Feature Branch**: `git checkout -b feature/amazing-feature`.
3.  **Follow the Spec**:
    *   Update `docs/rules/` if you are changing architectural rules.
    *   Run `python scripts/sync_agents.py` to update AI configs.
4.  **Verify**: Run `bash scripts/verify.sh` locally.
5.  **Push and PR**: Push to your fork and submit a Pull Request.

## Philosophy

*   **Spec-Driven**: Documentation comes before code.
*   **Agent-First**: Every feature must be understandable by an AI agent.
*   **SSoT**: Single Source of Truth for all configurations.
