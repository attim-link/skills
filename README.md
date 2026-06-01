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
- Preserve anonymous `claimToken` handoff fields
- Use claimed/permanent sites through `attim login`
- Configure password protection
- Configure public variables
- Configure x402 paywalls for claimed sites
- Use ATTIM MCP when the host agent supports MCP
- Fall back to the raw HTTP API when CLI/MCP are unavailable

## Bundled helper

After install, agents can run:

```bash
./scripts/publish.sh ./dist
```

The helper delegates to the official ATTIM CLI. It uses an installed `attim` binary when available, otherwise it runs `npx -y attim`.

## Product docs

- ATTIM docs: https://attim.link/docs
- Public skill document: https://attim.link/skill.md
- LLM reference: https://attim.link/llms.txt
- MCP endpoint: https://attim.link/mcp
