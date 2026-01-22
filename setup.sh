#!/bin/bash

# Setup Script for Agentic Project Template
# Usage: ./setup.sh

echo "🚀 Initializing Agentic Dev Environment..."

# 1. Fetch Vendor Resources
echo "📦 Fetching vendor tools..."
if [ -f "scripts/fetch_resources.sh" ]; then
    bash scripts/fetch_resources.sh
else
    echo "❌ Error: scripts/fetch_resources.sh not found."
    exit 1
fi

# 2. Sync AI Agents (Compiler)
echo "🧠 Syncing AI Agent configurations..."
if command -v python3 &> /dev/null; then
    python3 scripts/sync_agents.py
elif command -v python &> /dev/null; then
    python scripts/sync_agents.py
else
    echo "⚠️ Python not found. Skipping AI sync. Please run 'scripts/sync_agents.py' manually after installing Python."
fi

# 3. Final Check
echo "🔍 Verifying environment..."
if [ -f "scripts/verify.sh" ]; then
    bash scripts/verify.sh
fi

echo "✨ Setup Complete! You are ready to build."
echo "👉 Next Step: Edit 'docs/PRD.md' to define your project."
