# 🌊 Agentic Dev Workflow

> How to build software with AI agents without hallucinations.

## The Spec-Driven Lifecycle

### Phase 1: Inception (Idea -> Brief)
1.  **Idea**: You have a new project idea.
2.  **Brief**: Write a short paragraph in `docs/PRD.md` (Section 1).
3.  **Research**: Use `browser-use` or `perplexity` to validate technical feasibility.

### Phase 2: Architecture (Brief -> Technical Design)
1.  **Select Prompt**: Use `prompts/architect.md`.
2.  **Agent Instruction**: "You are the Architect. Read `docs/PRD.md` and create `docs/ARCHITECTURE.md`."
3.  **Review**: Ensure the system design, data models, and API interfaces are sound.
4.  **Approve**: Commit `docs/ARCHITECTURE.md`.

### Phase 3: Planning (Spec -> Tasks)
1.  **Select Prompt**: Use `prompts/tech_lead.md`.
2.  **Agent Instruction**: "You are the Tech Lead. Read `docs/PRD.md` and `docs/ARCHITECTURE.md`. Break it down into atomic tasks in `docs/TASKS.md`."
3.  **Review Tasks**: Ensure dependencies are correct and verification steps are executable.
4.  **Prioritize**: Mark P0 (Critical) tasks.

### Phase 4: Execution (Tasks -> Code)
1.  **Loop**: Run `bash scripts/loop.sh`.
    *   *Tip*: You can use `prompts/developer.md` as the system prompt for the loop if needed.
2.  **Monitor**: Watch `logs/progress.md`.
3.  **Intervene**: If the agent gets stuck, stop the loop, clarify the task, and restart.

### Phase 5: Verification (Code -> Truth)
1.  **Verify**: Run `bash scripts/verify.sh`.
2.  **Manual Check**: Open the app/feature yourself.
3.  **Commit**: Only commit if verification passes.

## Golden Rules
1.  **Never skip the PRD**. Code without spec is legacy code.
2.  **Verify continuously**. Don't wait until the end.
3.  **Docs are code**. Keep `docs/` folder as up-to-date as `src/`.
