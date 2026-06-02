# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Detectoo is a monorepo with two sub-projects:
- **`detectoo_backend/`** — FastAPI backend (Python 3.11+, based on Benav Labs FastAPI boilerplate)
- **`detectoo_app/`** — Flutter mobile/web/desktop app (Dart SDK ^3.11.4, Riverpod, built_value)

Each sub-project has its own CLAUDE.md with detailed commands, architecture, and conventions.

## Git Conventions

- Git is managed at the monorepo root — all git operations (commits, branches, etc.) must be run from this directory, not from sub-project directories
- **Commits**: Never commit unless explicitly asked. When asked to commit (e.g., "commit this"), stage all changes, write a detailed descriptive commit message covering all changes, and push to the current working branch. Never include "Claude" or "Co-Authored-By: Claude" in commit messages
- **Branches**:
  - `develop` is the main working branch. Version/release branches (e.g., `beta`, `v1.0`) are created off `develop`
  - Work branches (`feature/`, `fix/`, `hotfix/`, `bug/`, etc.) must be created off the relevant version branch (e.g., branch off `beta` for beta work), not off `develop` directly
  - Always ask the user for the branch name prefix before creating a new branch
