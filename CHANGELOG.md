# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-22

### Added
- **Unified AI Orchestration**: "Smart Compiler" architecture (`sync_agents.py`) to generate rules for Copilot, Cursor, Cline, and Windsurf from `ai/` source of truth.
- **Enterprise CI/CD**: Added `.github/workflows/agent-verify.yml` with Drift Detection to prevent manual rule edits.
- **DevContainers**: Added `.devcontainer/` configuration for consistent environments across Codespaces and VS Code.
- **Auditor Persona**: Added `prompts/auditor.md` for automated compliance checking.
- **Setup Script**: Unified `./setup.sh` for one-command initialization.
- **Community Docs**: Added `CONTRIBUTING.md`, `LICENSE`, `PULL_REQUEST_TEMPLATE.md`, and Issue Templates.
- **Architecture**: Restructured to `ai/` folder for rules SSoT.

### Changed
- **SSoT Location**: Moved `docs/rules` to `ai/rules` to better separate AI logic from human documentation.
- **Verification**: Updated `verify.sh` to support stack detection and automated testing.

### Fixed
- **Sync Drift**: Resolved potential non-determinism in AI rule generation.
- **Structure**: Ensured empty directories (`vendor`, `logs`) are tracked properly.
