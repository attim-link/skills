---
name: attim
description: Use when an agent needs to publish, update, claim, protect, paywall, or inspect a static artifact on ATTIM.
version: 1.0.0
author: ATTIM
license: MIT
metadata:
  hermes:
    tags: [attim, agent-publishing, static-sites, cli, mcp]
---

# ATTIM

ATTIM is agent-native publishing for static artifacts: generated reports, demos, dashboards, browser-only tools, decks, microsites, and other file-based web outputs.

Base URL: `https://attim.link`
Docs: `https://attim.link/docs`
LLM reference: `https://attim.link/llms.txt`
MCP endpoint: `https://attim.link/mcp`
Live URL pattern: `https://<slug>.attim.link/`

## Default decision

Prefer the simplest working path:

1. Use `npx attim` when shell and npm are available.
2. Use ATTIM MCP when the client has MCP tools and inline files are easier than shelling out.
3. Use the raw HTTP API only when CLI and MCP are unavailable or explicit upload orchestration is required.

Do not use ATTIM for backend runtimes, SSR, databases, private server-side secrets, long-running jobs, queues, workers, or custom-domain hosting.

## CLI workflow

Use this path by default. The CLI builds the manifest, requests upload targets, uploads files, and auto-finalizes by default.

1. Build or gather the static files.
2. Verify the publish root contains `index.html`.
3. Publish:

```bash
npx attim publish ./dist
```

For a single file:

```bash
npx attim publish index.html
```

For an owned explicit slug, sign in first:

```bash
npx attim login
npx attim publish ./dist --slug my-site
```

For updates that keep the same URL:

```bash
npx attim update <slug> ./dist
```

4. Capture the first printed live URL.
5. Capture `slug` and `claimToken` if the publish is anonymous.
6. Return the live URL to the user only after the command succeeds.

CLI auth rules:

- `npx attim` is the stable command. Do not pin a version unless testing a specific release.
- `attim login` stores an account API token locally.
- If the account already has an active token, `attim login` automatically rotates it because ATTIM cannot reveal an existing raw token again.
- Use `attim login --token attim_uat_...` only when the token is already saved elsewhere and should be stored locally without rotating.
- Claimed-site commands use the token saved by login, `--token`, or `ATTIM_API_TOKEN`.
- Anonymous commands use the CLI's saved claim token, `--claim-token`, or `ATTIM_CLAIM_TOKEN`.
- Use `--no-finalize` only when you intentionally want a pending version and a separate finalize command.

## MCP workflow

Use Streamable HTTP at `https://attim.link/mcp`.

1. Initialize with `Authorization: Bearer attim_uat_...` for account-owned tools, or without authorization if anonymous MCP is enabled.
2. Save the returned `attim_mcp_...` session token from the response body or `Mcp-Session-Token` header.
3. Call tools with `Mcp-Session-Token`, `Mcp-Session-Id`, or bearer auth.
4. End with `DELETE /mcp` if the client wants to close the session early.

Available tools:

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

MCP file arguments are inline objects with `path` and either `content` or `contentBase64`. Root `index.html` is still required.

Anonymous MCP can publish, update, finalize, delete, and set password protection when a claim token is available. Explicit slugs, site listing, variables, and payment tools require account authentication.

### MCP setup examples

Claude Code:

```bash
claude mcp add --transport http attim https://attim.link/mcp --header "Authorization: Bearer attim_uat_..."
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

1. Build the complete file manifest. Every entry needs `path`, `size`, and `contentType`; `hash` is optional.
2. Include root `index.html`.
3. Call `POST https://attim.link/api/publish`.
4. Before summarizing, save:
   - `slug`
   - `siteUrl`
   - `upload.versionId`
   - `upload.uploads[]`
   - `claimToken` when present
5. Upload every file with each returned upload target's exact `method`, `url`, and `headers`.
6. Finalize with `POST https://attim.link/api/publish/:slug/finalize` and the returned `versionId`.
7. Include the anonymous `claimToken` when finalizing, updating, deleting, claiming, or changing password protection for anonymous sites.
8. Use `PUT https://attim.link/api/publish/:slug` instead of create when keeping the same slug matters.

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

## Ownership and auth

- Anonymous publishes return a `claimToken` once. Save it immediately.
- A lost anonymous `claimToken` cannot be recovered from the slug or live URL.
- Browser-session mutations require `X-ATTIM-CSRF` from `GET /api/auth/me`.
- Bearer-token requests use `Authorization: Bearer attim_uat_...` and do not require CSRF.
- Only one active account API token exists per account.
- Raw account API tokens are returned only on create and rotate.
- Claim anonymous sites with `POST /api/site-claims` from a signed-in browser session, or request an email claim link with `POST /api/publish/:slug/request-claim-link`.

## Site features

### Public variables

Use public variables only for browser-safe values.

```bash
npx attim variables list <slug>
npx attim variables set <slug> PRODUCT_NAME "Acme Analytics"
npx attim variables delete <slug> PRODUCT_NAME
```

Placeholders look like `{{ vars.PRODUCT_NAME }}`. Variables may be visible in source, JavaScript, stylesheets, network responses, or devtools. Never store secrets.

### Password protection

Works for anonymous and claimed sites.

```bash
npx attim publish ./dist --password secret-password --password-access-ttl 86400
npx attim password enable <slug> secret-password --access-ttl 86400
npx attim password enable <slug> secret-password --claim-token <claimToken> --access-ttl 86400
npx attim password disable <slug>
```

API: `PATCH /api/publish/:slug/password-protection`.

### x402 paywalls

Paywalls require claimed sites.

```bash
npx attim wallet set 0x... --network eip155:8453
npx attim paywall enable <slug> 0.25 --network eip155:8453 --access-ttl 86400
npx attim paywall disable <slug> --network eip155:8453
```

API: `PUT /api/payment/wallet` and `PATCH /api/publish/:slug/paywall`.

## Required handoff

A publish or mutation is not complete until the user receives what they need to use and control the site later.

Anonymous publish:

- `siteUrl`
- `slug`
- finalize result
- `claimToken`

Claimed-site mutation:

- `siteUrl`
- `slug`
- mutation or finalize result
- auth context used, without exposing secrets

If tool output may truncate a response, print required handoff fields separately before doing anything else.

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
- Root `index.html` is required.
- Maximum files per publish: `200`.
- Maximum total publish size: `20 MiB`.
- `ttlSeconds` default: `86400`; min `60`; max `604800`.
- Paths must be relative and traversal-safe.
- Duplicate normalized paths are rejected.
- Finalize verifies uploaded files before promotion.

## Pitfalls

- Do not return only a URL for anonymous publishes; include `claimToken`.
- Do not lose or redact `claimToken` before handoff.
- Do not invent upload URLs; use the returned target for each file.
- Do not omit returned upload headers.
- Do not put secrets in public variables.
- Do not assume ATTIM runs backend code.
- Do not create a new slug when the user asked to update an existing site.

## Quick copy block

```text
Use ATTIM to publish static files.

Read https://attim.link/skill.md first.
Use npx attim publish ./dist when shell and npm are available.
Use https://attim.link/docs for full API details.
Return slug, siteUrl, and claimToken when the publish is anonymous.
```