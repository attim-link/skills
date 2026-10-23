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

- Publish a new static site from a folder or single HTML file
- Update an existing site without changing its URL
- Clone or fork an existing anonymous site
- Claim anonymous sites into the account with the CLI or the `claim_site` MCP tool
- Preserve anonymous `claimToken` handoff fields
- Sign in for claimed/permanent sites with two-step `attim login`: `--email` sends a code, then `--email` with `--code` finishes without a terminal
- Respect the email limit: one sign-in code, claim link, or workspace invitation per address a minute
- Configure password protection
- Configure public variables
- List, name, preview, download, and restore project versions
- Set up the ATTIM profile: one public link-in-bio page per account with links, social icons, a theme, and the user's ATTIM projects
- Build custom link pages and manage their links and click stats
- Target workspaces
- Use ATTIM MCP when the host agent supports MCP
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
- MCP endpoint: https://attim.link/mcp
