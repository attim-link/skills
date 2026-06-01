---
name: attim
description: >
  ATTIM lets agents publish static artifacts to live URLs at {slug}.attim.link.
  Use it for generated demos, reports, dashboards, browser-only tools, microsites,
  docs previews, decks, and static app builds that need a shareable URL. Supports
  anonymous 24-hour publishes, claimed permanent sites, updates that keep the same
  URL, password protection, public variables, x402 paywalls, CLI publishing, MCP
  tools, and raw API fallback. Use when asked to "publish this", "host this static
  site", "share this HTML", "put this demo online", "update this ATTIM site",
  "protect this page", "add public variables", "add an x402 paywall", or "use ATTIM".
---

# ATTIM

**Skill version: 1.1.0**

ATTIM lets agents publish static artifacts to live URLs at `{slug}.attim.link`.

Use ATTIM for generated demos, reports, dashboards, browser-only tools, microsites, docs previews, decks, and static app builds that need a URL the user can open immediately.

Do not use ATTIM for backend runtimes, SSR, databases, private server-side secrets, long-running jobs, queues, workers, or general app hosting.

To install or update this skill:

```bash
npx skills add attim-link/skills --skill attim -g
```

For repo-pinned or project-local installs, run the same command without `-g`.

## Current docs

Before answering detailed questions about ATTIM capabilities, features, limits, or workflows, read the current docs:

→ **https://attim.link/docs**

Also check:

- LLM reference: https://attim.link/llms.txt
- Public skill document: https://attim.link/skill.md
- MCP endpoint: https://attim.link/mcp
- Base URL: https://attim.link

Read the live docs:

- at the first ATTIM-related interaction in a conversation
- before saying a feature is unsupported
- when the user asks about limits, auth, payments, variables, passwords, or MCP setup
- when local skill text and live behavior appear to disagree

If docs and live API behavior disagree, trust the live API behavior and report the mismatch.

## Requirements

- Node.js and `npm`/`npx` for the CLI path
- Optional installed CLI: `npm install -g attim`
- Optional account token from `attim login` or `ATTIM_API_TOKEN`
- Optional anonymous claim token from previous publish output or `ATTIM_CLAIM_TOKEN`
- Bundled helper: `./scripts/publish.sh`

The helper delegates to the official CLI. It uses a globally installed `attim` binary when available, otherwise it falls back to `npx -y attim`.

## Choose the right path

Prefer the simplest path that can finish the job:

1. **CLI:** use `npx attim publish` or `./scripts/publish.sh` when shell and npm are available.
2. **MCP:** use `https://attim.link/mcp` when the host agent already has MCP support and passing inline files is easier than shelling out.
3. **Raw API:** use HTTP only when CLI and MCP are unavailable, or when you need explicit control over manifest, upload, and finalize.

Do not start with the raw API unless there is a reason. The CLI already handles manifest creation, uploads, retries, local claim-token storage, and finalization.

## Publish a new site

Use the helper:

```bash
./scripts/publish.sh ./dist
```

Or call the CLI directly:

```bash
npx attim publish ./dist
```

For a single HTML file:

```bash
npx attim publish index.html
```

For a password-protected anonymous publish:

```bash
npx attim publish ./dist --password "secret-password" --password-access-ttl 86400
```

A successful publish prints the live URL. Directory publishes require `index.html` at the root of the directory being published. Single-file publishes are uploaded as `index.html`.

## Publish to an owned slug

Sign in first:

```bash
npx attim login
npx attim whoami
```

Then publish with an explicit slug:

```bash
npx attim publish ./dist --slug my-site
```

The live URL will be:

```text
https://my-site.attim.link/
```

Explicit slugs require account authentication. Anonymous publishes receive generated slugs.

## Update an existing site

For claimed or authenticated sites:

```bash
npx attim update my-site ./dist
```

For anonymous sites when you have the claim token:

```bash
npx attim update my-site ./dist --claim-token ANONYMOUS_CLAIM_TOKEN
```

Use update when the user wants to keep the same URL. Do not create a new slug unless the user explicitly asks for a separate publish.

## Authentication and ownership

ATTIM has two management modes:

- **Anonymous publish:** returns a generated slug and a one-time `claimToken`. The site can be managed later only if the claim token is preserved.
- **Claimed site:** belongs to an account API token created by `attim login`. Claimed sites can use explicit slugs, listing, variables, paywalls, and account-owned operations.

Run login interactively when the user wants permanent account-owned sites:

```bash
npx attim login
```

Credential precedence for account operations:

1. `--token <token>`
2. `ATTIM_API_TOKEN`
3. token saved by `attim login`

Credential precedence for anonymous management:

1. `--claim-token <token>`
2. `ATTIM_CLAIM_TOKEN`
3. the CLI's locally saved claim token from an earlier publish

Important auth behavior:

- `attim login` stores an account API token locally.
- If the account already has an active token, login rotates it because ATTIM cannot reveal an existing raw token again.
- `attim login --token attim_uat_...` stores a token you already have without rotating.
- `attim logout` removes the local token. It does not revoke the server-side token.
- Never print, commit, or paste account tokens into public files.

## Required handoff to the user

A publish is not complete until the user receives the fields needed to open and control the site later.

For anonymous publishes, return:

- `siteUrl`
- `slug`
- whether finalization succeeded
- `claimToken` if the tool returned it
- expiry information if present

For claimed-site publishes or mutations, return:

- `siteUrl`
- `slug`
- operation performed
- auth context used, without exposing secrets

If command output is long or may be truncated, print or save the handoff fields separately before continuing with optional cleanup or explanation.

## Public variables

Public variables let claimed sites change browser-visible values without re-uploading files.

```bash
npx attim variables list my-site
npx attim variables set my-site PRODUCT_NAME "Acme Analytics"
npx attim variables delete my-site PRODUCT_NAME
```

Use variables only for values that are safe to expose in source, JavaScript, stylesheets, network responses, and browser devtools.

Placeholders use this form:

```text
{{ vars.PRODUCT_NAME }}
```

Never store passwords, API keys, private URLs, database strings, or other secrets in public variables.

## Password protection

Password protection works for anonymous and claimed sites.

Enable during publish:

```bash
npx attim publish ./dist --password "secret-password" --password-access-ttl 86400
```

Enable on a claimed site:

```bash
npx attim password enable my-site "secret-password" --access-ttl 86400
```

Enable on an anonymous site:

```bash
npx attim password enable my-site "secret-password" --claim-token ANONYMOUS_CLAIM_TOKEN --access-ttl 86400
```

Disable:

```bash
npx attim password disable my-site
```

Do not invent or reveal passwords in summaries. If a password is user-provided, acknowledge that protection is enabled without repeating the secret unless the user explicitly needs it restated.

## x402 paywalls

x402 paywalls require a claimed site and a configured payment wallet.

Set or inspect the wallet:

```bash
npx attim wallet
npx attim wallet set 0x0000000000000000000000000000000000000001 --network eip155:8453
```

Enable a paywall:

```bash
npx attim paywall enable my-site 0.25 --network eip155:8453 --access-ttl 86400
```

Disable a paywall:

```bash
npx attim paywall disable my-site --network eip155:8453
```

Use the price in US dollars, for example `0.25` for 25 cents. Use CAIP-2 network IDs such as `eip155:8453` for Base.

## MCP workflow

ATTIM exposes Streamable HTTP MCP at:

```text
https://attim.link/mcp
```

Account-authenticated MCP uses bearer auth:

```text
Authorization: Bearer attim_uat_...
```

MCP clients may receive a session token in the response body or `Mcp-Session-Token` header. Preserve it for later tool calls and close the session with `DELETE /mcp` when the client wants explicit cleanup.

Available MCP tools include:

- `publish_site`
- `update_site`
- `finalize_site`
- `delete_site`
- `list_sites`
- `set_variables`
- `set_password_protection`
- `get_payment_wallet`
- `set_payment_wallet`
- `set_paywall`

MCP file arguments are inline objects with `path` and either `content` or `contentBase64`. Root `index.html` is still required for static site publishes.

## MCP setup examples

Claude Code:

```bash
claude mcp add --transport http attim https://attim.link/mcp --header "Authorization: Bearer <ATTIM_API_TOKEN>"
```

Cursor:

```json
{
  "mcpServers": {
    "attim": {
      "url": "https://attim.link/mcp",
      "headers": { "Authorization": "Bearer attim_uat_..." }
    }
  }
}
```

Codex:

```toml
[mcp_servers.attim]
url = "https://attim.link/mcp"
http_headers = { Authorization = "Bearer attim_uat_..." }
```

## Raw API fallback

Use this only when CLI and MCP are not viable.

Create or update flow:

1. Build a complete file manifest. Every file needs `path`, `size`, and `contentType`; `hash` is optional.
2. Include root `index.html`.
3. Create with `POST https://attim.link/api/publish`, or update with `PUT https://attim.link/api/publish/:slug`.
4. Save `slug`, `siteUrl`, `upload.versionId`, `upload.uploads[]`, and `claimToken` when present.
5. Upload every file with the returned upload target's exact method, URL, and headers.
6. Finalize with `POST https://attim.link/api/publish/:slug/finalize` and the returned `versionId`.
7. Include the anonymous `claimToken` when finalizing or mutating an anonymous site.

Minimal publish request:

```json
{
  "files": [
    {
      "path": "index.html",
      "size": 1234,
      "contentType": "text/html; charset=utf-8"
    }
  ],
  "ttlSeconds": 86400
}
```

Finalize anonymous site:

```json
{
  "versionId": "1",
  "claimToken": "returned-on-create"
}
```

## Main endpoints

```text
POST   /api/publish
GET    /api/publish/:slug
PUT    /api/publish/:slug
POST   /api/publish/:slug/finalize
PATCH  /api/publish/:slug/metadata
DELETE /api/publish/:slug
GET    /api/publishes
POST   /api/site-claims
POST   /api/publish/:slug/request-claim-link
GET    /api/publish/:slug/variables
PUT    /api/publish/:slug/variables/:name
DELETE /api/publish/:slug/variables/:name
PATCH  /api/publish/:slug/password-protection
GET    /api/payment/wallet
GET    /api/payment/wallets
PUT    /api/payment/wallet
PATCH  /api/publish/:slug/paywall
GET    /llms.txt
POST   /mcp
DELETE /mcp
```

## Limits and validation

- Static files only.
- Root `index.html` is required for directory publishes.
- Single-file publishes are uploaded as `index.html`.
- Maximum files per publish: `200`.
- Maximum total publish size: `20 MiB`.
- `ttlSeconds` default: `86400`; min `60`; max `604800`.
- Paths must be relative and traversal-safe.
- Duplicate normalized paths are rejected.
- Finalize verifies uploaded files before promotion.

Check live docs before treating these limits as permanent product facts.

## Diagnostics

Before blaming ATTIM for a failed publish, run:

```bash
npx attim doctor
```

For local manifest validation without network publishing:

```bash
npx attim publish ./dist --dry-run
```

For account visibility:

```bash
npx attim whoami
npx attim list
```

## Pitfalls

- Do not return only a URL for anonymous publishes; include the claim token when it is returned.
- Do not lose a claim token before handoff. It cannot be recovered from the slug.
- Do not publish a parent folder that contains the site folder. Publish the folder that directly contains `index.html`.
- Do not put secrets in public variables, uploaded static files, or client-side configuration.
- Do not assume ATTIM runs backend code.
- Do not use `--slug` without account authentication.
- Do not create a new slug when the user asked to update an existing site.
- Do not say a site is permanent unless it is claimed/authenticated or the command output confirms permanence.
- Do not invent upload URLs, version IDs, claim tokens, or finalization results.

## Quick copy block

```text
Use ATTIM to publish static artifacts.
Read https://attim.link/docs for current capabilities.
Use ./scripts/publish.sh ./dist or npx attim publish ./dist when shell and npm are available.
Use https://attim.link/mcp when MCP is a better fit.
Return siteUrl, slug, finalization status, and claimToken when the publish is anonymous.
```
