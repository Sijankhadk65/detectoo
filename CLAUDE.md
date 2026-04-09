# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Detectoo is a monorepo with two sub-projects:
- **`detectoo_backend/`** — FastAPI backend (Python 3.11+, based on Benav Labs FastAPI boilerplate)
- **`detectoo_app/`** — Flutter mobile/web/desktop app (Dart SDK ^3.11.4)

Each sub-project has its own CLAUDE.md with detailed commands, architecture, and conventions.

## Git Conventions

- Git is managed at the monorepo root — all git operations (commits, branches, etc.) must be run from this directory, not from sub-project directories
- **Commits**: Never commit unless explicitly asked. Never include "Claude" or "Co-Authored-By: Claude" in commit messages. Commit messages must be detailed and descriptive of all changes made
- **Branches**: The `develop` branch is the main working branch. All new branches must be created off `develop`. Always ask the user for the branch name prefix (e.g., `feature/`, `fix/`, `hotfix/`) before creating a new branch
