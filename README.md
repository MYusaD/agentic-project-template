# Agentic Project Template 🤖

> **Spec-Driven, Eval-Driven, Loop-Based.**
> A universal "Operating System" for AI-assisted software development.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🌟 Features

*   **Spec-Driven Workflow**: Enforced structure (`PRD.md` -> `ARCHITECTURE.md` -> `TASKS.md`).
*   **Role-Based Prompts**: Specialized prompts for Architects, Tech Leads, and Developers `prompts/`.
*   **Automated Loop**: `scripts/loop.sh` managing the "Code -> Verify -> Log" cycle.
*   **Enterprise CI/CD**: GitHub Actions workflow included for automated verification.
*   **DevContainers**: Ready-to-code environment for GitHub Codespaces and VS Code.
*   **Universal Verification**: `scripts/verify.sh` that detects your stack (Node, Python, Go, Rust) and runs appropriate checks.
*   **Unified AI Orchestration**: `scripts/sync_agents.py` generates config for Copilot, Cursor, Cline, and Windsurf from `docs/rules/`.
*   **Vendor Management**: Keep your AI tools (`browser-use`, `crewai`, etc.) local in `vendor/`.

## 🚀 Usage

### Option 1: GitHub Template (Recommended)
1.  Click the **[Use this template](https://github.com/new?template_name=agentic-project-template&template_owner=MYusaD)** button above.
2.  Create your new repository (e.g., `my-cool-idea`).
3.  Clone it locally:
    ```bash
    git clone https://github.com/YOUR_USERNAME/my-cool-idea.git
    cd my-cool-idea
    ```
4.  Initialize tools:
    ```bash
    bash scripts/fetch_resources.sh
    ```

### Option 2: Local Scaffolder
If you have the `create_project.sh` script:
```bash
bash scripts/create_project.sh my-new-app
```

## 📂 Structure

```tree
.
├── .devcontainer/      # Docker-based Dev Environment
├── .github/            # CI/CD Workflows & Copilot Instructions
├── ai/                 # The "Brain" (Single Source of Truth)
│   ├── AGENTS.md       # The "Constitution" for agents
│   └── rules/          # Modular Laws (Style, Tech Stack)
├── config/             # Configuration Templates (MCP, etc.)
├── docs/               # Project Documentation
├── prompts/            # Role-Based Instructions
│   ├── architect.md
│   ├── tech_lead.md
│   └── developer.md
├── scripts/            # The "Nervous System"
│   ├── loop.sh         # The Agent Loop
│   ├── verify.sh       # The Gatekeeper
│   ├── sync_agents.py  # The Malevych Sync Engine
│   └── fetch.sh        # Vendor Manager
└── vendor/             # External Tools (Local)
```

## ⚡ Quick Start

1.  **Initialize**: Run `./setup.sh` to download tools and configure AI agents.
2.  **Plan**: Fill out `docs/PRD.md`.
3.  **Design**: Use `prompts/architect.md` to generate `docs/ARCHITECTURE.md`.
4.  **Loop**: Run `bash scripts/loop.sh` and watch it build.
