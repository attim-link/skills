# ATTIM skill

Agent skill for publishing static artifacts to ATTIM.

ATTIM turns generated demos, reports, dashboards, browser-only tools, microsites, docs previews, decks, and static app builds into live URLs at `{slug}.attim.link`.

## Install

Recommended global install:

```bash
npx skills add attim-link/skills --skill attim -g
```

Project-local install:

```bash
npx skills add attim-link/skills --skill attim
```

View on skills.sh:

```txt
https://www.skills.sh/attim-link/skills/attim
```

Repository path:

```txt
https://github.com/attim-link/skills/tree/main/attim
```

## What the skill covers

- Publish a new static site from a folder or single HTML file; folder publishes leave out hidden files such as `.env` and `.git` unless `--include-dotfiles` is passed
- Never publish secret files: ATTIM refuses `.env`, `.git/`, `.npmrc`, and other files that can hold secrets or source history (`ATTIM_SENSITIVE_PATH`), even with `--include-dotfiles`, and sites never serve them
- Publish temporary 12-hour sites through MCP without an account; Claude and ChatGPT show the site in a card with a preview
- Update an existing site without changing its URL
- Change part of a live site from any chat with the `read_site` and `edit_site` MCP tools, as a new version at the same link
- Copy an existing temporary site with the CLI (`clone` / `fork`) or the `copy_site` MCP tool
- Claim anonymous sites into the account with the CLI or the `claim_site` MCP tool, or keep one by email: `claim_site` with the user's email sends a link that keeps it and creates their free account
- Preserve anonymous `claimToken` handoff fields
- Sign in for claimed/permanent sites with two-step `attim login`: `--email` sends a code, then `--email` with `--code` finishes without a terminal
- Respect the email limit: one sign-in code, claim link, or workspace invitation per address a minute
- Configure password protection, with `--password-stdin` to keep the password out of shell history
- Configure public variables
- List, name, preview, download, and restore project versions
- Set up or change the ATTIM profile, with the CLI or the `save_profile` MCP tool: one public link-in-bio page per account with links, social icons, a theme, and the user's ATTIM projects
- Build custom link pages and manage their links and click stats
- See how sites are doing with `attim insights` or the `get_insights` MCP tool: people, AI agents, and other bots counted apart (Hobby and Team plans)
- Register WebMCP tools on interactive pages so AI agents in the browser can use them
- Target workspaces
- Use ATTIM MCP when the host agent supports MCP
- Read CLI exit codes and JSON errors before retrying, and pass arguments by name
- Fall back to the raw HTTP API when CLI/MCP are unavailable

## Bundled helpers

After install, agents can run:

```bash
./scripts/publish.sh ./dist
./scripts/update.sh my-site ./dist
./scripts/login.sh --email you@example.com
./scripts/login.sh --email you@example.com --code 123456
./scripts/claim.sh my-site
```

Each helper delegates to the official ATTIM CLI. It uses an installed `attim` binary when available, otherwise it runs `npx -y attim`.

## Product docs

- ATTIM docs: https://attim.link/docs
- LLM reference: https://attim.link/llms.txt
- HTTP API reference: https://attim.link/docs/api
- MCP endpoint: https://attim.link/mcp
