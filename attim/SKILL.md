---
name: attim
description: >
  ATTIM lets agents publish static artifacts to live URLs at {slug}.attim.link.
  Use it for generated demos, reports, dashboards, browser-only tools, microsites,
  docs previews, decks, and static app builds that need a shareable URL. Supports
  anonymous 12-hour publishes, claimed permanent sites, updates that keep the same
  URL, password protection, public variables, cloning and forking, workspaces,
  project version history, CLI publishing, MCP tools, and raw API fallback. Use when asked to "publish this",
  "host this static site", "share this HTML", "put this demo online", "update this
  ATTIM site", "rename or restore a version", "protect this page", "add public variables", "clone or fork this
  ATTIM site", or "use ATTIM".
---

# ATTIM

**Skill version: 2.2.0**

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
- Full LLM reference: https://attim.link/llms-full.txt
- MCP endpoint: https://attim.link/mcp
- Base URL: https://attim.link

Read the live docs:

- at the first ATTIM-related interaction in a conversation
- before saying a feature is unsupported
- when the user asks about limits, auth, payments, variables, passwords, version history, or MCP setup
- when local skill text and live behavior appear to disagree

If docs and live API behavior disagree, trust the live API behavior and report the mismatch.

## Requirements

- Node.js and `npm`/`npx` for the CLI path
- Optional installed CLI: `npm install -g attim`
- Optional account token from `attim login` or `ATTIM_API_TOKEN`
- Optional anonymous claim token from previous publish output or `ATTIM_CLAIM_TOKEN`
- Bundled helpers in `./scripts/`: `publish.sh`, `update.sh`, `login.sh`, `claim.sh`

Every helper delegates to the official CLI. Each uses a globally installed `attim` binary when available, otherwise it falls back to `npx -y attim`.

## Choose the right path

Choose by the location of the files and the requested operation. Check which tools the agent actually has.

| Request | First choice | If unavailable |
| --- | --- | --- |
| Publish or update a local file, build folder, or many assets | CLI (`attim publish` / `attim update`) | Raw API upload flow |
| Publish or update a small set of inline files already in the conversation | MCP (`publish_site` / `update_site`) | CLI if files are already on disk; otherwise raw API |
| Clone or fork an existing site | MCP (`clone_site` / `fork_site`) | CLI `clone` / `fork` |
| List owned sites or versions; rename, preview, download, restore, protect, or delete a remote site | Matching MCP tool | Matching CLI command |
| Set a browser-visible public variable | MCP `set_variables` | CLI `variables set` |
| Identify the connected account | MCP `get_profile` | CLI `whoami` |
| Claim an anonymous site, inspect local CLI setup, or list/delete public variables | CLI or ATTIM web UI | Raw API where that operation is supported |

Apply these rules before every ATTIM action:

1. For local files, let the CLI read and upload the build directly. Do not copy a directory into MCP inline arguments. For files supplied in chat, use MCP without creating a local build solely to reach the CLI.
2. For an owned-site MCP action, use the host's ATTIM OAuth connection. For an owned-site CLI action, use the CLI's stored account API token or its normal login flow. Do not paste either credential into site files or public variables.
3. Publish to the account when the user is signed in through OAuth or the CLI. Use temporary **anonymous** publishing only without an account connection. Confirm that it sends no account credential; `--ttl` alone does not select anonymous publishing. Retain the returned `claimToken` for later anonymous mutations. If the CLI stored it locally, prefer the CLI for that site's update or claim.
4. Choose one path for each mutation and inspect its result before any retry. Do not publish through both MCP and CLI for the same request. An entitlement error is not a reason to switch paths.
5. Use the raw API only when no available MCP or CLI path can complete the operation, or when explicit manifest/upload/finalize control is required. Follow the same ownership, claim-token, and validation rules on that path.

The MCP server has no `claim_site`, `doctor`, `info`, or public-variable list/delete tool today. Do not invent one.

## CLI quick start

Publish a directory:

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

A successful publish prints the live URL on the first line. Directory publishes require `index.html` at the root of the directory being published. Single-file publishes are uploaded as `index.html`.

## Command reference

### Authentication

```bash
npx attim login                      # interactive email-code login; creates or rotates an account API token
npx attim login --rotate             # explicit rotation for scripted flows
npx attim login --token attim_uat_...  # store a token you already saved, without rotating
npx attim whoami                     # verify the stored token
npx attim logout                     # remove the local token (does not revoke it server-side)
```

- `attim login` stores an account API token locally at `~/.config/attim/config.json` (override with `ATTIM_CONFIG_DIR`).
- If the account already has an active token, `attim login` rotates it because ATTIM cannot reveal an existing raw token again.
- `attim logout` does not revoke the server-side token; revoke it from `/settings/advanced` if needed.

### Publish

```bash
npx attim publish ./dist
npx attim publish index.html
npx attim publish ./dist --slug my-site                    # owned site; requires account auth
npx attim publish ./dist --password "secret-password" --password-access-ttl 86400  # signed-in only
npx attim publish ./dist --ttl 43200                        # expiry for a credential-free publish (60 to 43200 seconds)
npx attim publish ./dist --workspace 1                      # publish into a workspace
npx attim publish ./dist --no-finalize                      # upload but leave the version pending
npx attim publish ./dist --dry-run                          # validate locally, no network calls
npx attim publish ./dist --json                             # machine-readable JSON on stdout
```

- Anonymous publishes receive generated slugs; explicit `--slug` requires account authentication.
- Owned sites are permanent; anonymous sites expire after up to 12 hours.
- A saved CLI login makes `publish` an owned publish; `--ttl` is rejected for that publish.
- `--no-finalize` requires a later `finalize` command to make the version live.

### Update an existing site

Use update when the user wants to keep the same URL. Do not create a new slug unless the user explicitly asks for a separate publish.

```bash
npx attim update my-site ./dist                             # owned site using stored token
npx attim update my-site ./dist --claim-token ANONYMOUS_CLAIM_TOKEN   # anonymous site
npx attim update my-site ./dist --dry-run
npx attim update my-site ./dist --no-finalize
```

### Clone and fork

```bash
npx attim clone source-site --ttl 43200                     # anonymous copy with a new claim token
npx attim fork source-site --slug my-copy                   # owned copy; requires account auth
npx attim fork source-site --workspace 1                    # owned copy into a workspace
```

- `clone` creates a new anonymous site with independent storage and its own one-time `claimToken`.
- `fork` copies the source into your account as a permanent owned site.
- Copies include static files and basic metadata, not passwords or source claim tokens.

### Lifecycle commands

```bash
npx attim finalize my-site 12 --claim-token ANONYMOUS_CLAIM_TOKEN
npx attim delete my-site --token attim_uat_...
npx attim info my-site
npx attim list
npx attim list --workspace 1
```

- Anonymous sites require `--claim-token` or `ATTIM_CLAIM_TOKEN` for finalize and delete.
- Claimed sites require an account API token (stored, `--token`, or `ATTIM_API_TOKEN`).

### Project versions

Finalized uploads to an owned project create permanent version IDs. ATTIM retains the latest 10 finalized versions in one history per project, including Team projects. Optional names label versions without changing their IDs or files.

```bash
npx attim versions my-site
npx attim rename-version my-site 12 "Before redesign"
npx attim rename-version my-site 12 --clear
npx attim preview my-site 12
npx attim download my-site 12 --output my-site-12.zip
npx attim restore my-site 12
```

- `versions` shows each retained ID, optional name, and which version is live.
- Names must be one line and 1–120 characters. `--clear` removes a name.
- `preview` prints a private, one-use URL. Open it within 60 seconds; its preview session lasts 15 minutes. Treat the URL as sensitive.
- `download` saves a ZIP and will not overwrite an existing file.
- `restore` copies the selected version's files into a **new, unnamed version ID** and makes that copy live. The source version and its name stay intact. If another publish changes the live version first, refresh the history and retry.
- These commands require an account API token. Personal project owners can read, rename, and restore. Team owners and editors can read, rename, and restore; Team viewers can list, preview, and download. Frozen Team workspaces remain readable but cannot publish, rename, or restore. Removed members lose access.

### Claim anonymous sites

```bash
npx attim claim my-site
npx attim claim --all
npx attim claim my-site --workspace 1
```

Claiming converts an anonymous site into an owned site. The CLI reuses the locally saved claim token from the original publish. After claiming, the site becomes permanent and account-managed.

### Public variables

Public variables let claimed sites change browser-visible values without re-uploading files. Placeholders like `{{ vars.PRODUCT_NAME }}` in text files are replaced at serve time.

```bash
npx attim variables list my-site
npx attim variables set my-site PRODUCT_NAME "Acme Analytics"
npx attim variables delete my-site PRODUCT_NAME
```

Use variables only for values that are safe to expose in source, JavaScript, stylesheets, network responses, and browser devtools. Never store passwords, API keys, private URLs, database strings, or other secrets in public variables.

### Password protection

New password protection requires an account-owned site. A previously protected anonymous site can keep, update, or disable its existing protection with its claim token, but cannot newly enable protection.

```bash
# Enable during publish
npx attim publish ./dist --password "secret-password" --password-access-ttl 86400

# Enable on a claimed site
npx attim password enable my-site "secret-password" --access-ttl 86400

# Disable
npx attim password disable my-site
```

- `--access-ttl` (or `--password-access-ttl` at publish time) controls how long a successful password unlock lasts, in seconds. If omitted, ATTIM chooses the duration.
- Do not invent or reveal passwords in summaries. If a password is user-provided, acknowledge that protection is enabled without repeating the secret unless the user explicitly needs it restated.

### Diagnostics

```bash
npx attim doctor      # checks local Node support, API reachability, config location, and token validity
npx attim whoami      # verifies the stored account token
npx attim list        # lists owned sites visible to the saved token
```

## Global options

| Option | Meaning |
| --- | --- |
| `--base-url <url>` | ATTIM base URL. Defaults to `https://attim.link` or `ATTIM_BASE_URL`. |
| `--token <token>` | Account API token. Defaults to `ATTIM_API_TOKEN`, then the token saved by `attim login`. |
| `--claim-token <token>` | Anonymous site management token. Defaults to `ATTIM_CLAIM_TOKEN`. |
| `--ttl <seconds>` | TTL for anonymous publishes or clones, from 60 to 43200 seconds. |
| `--slug <slug>` | Explicit destination slug for authenticated publishes or forks. |
| `--workspace <id>` | Target workspace for publish, fork, list, and claim. |
| `--access-ttl <seconds>` | Password unlock duration for `password enable`. |
| `--password-access-ttl <seconds>` | Password unlock duration when enabling protection during publish. |
| `--json` | Machine-readable JSON on stdout. |
| `--no-finalize` | Leave the version pending for a separate finalize. |
| `--dry-run` | Build and validate locally without API or upload calls. |
| `--rotate` | Explicitly rotate the account API token during login. |
| `--all` | Apply the command to all stored anonymous sites (claim). |
| `--help` / `--version` | Show usage or the CLI version. |

Environment variables: `ATTIM_API_TOKEN`, `ATTIM_CLAIM_TOKEN`, `ATTIM_BASE_URL`, `ATTIM_CONFIG_DIR`.

Credential precedence for account operations: `--token` → `ATTIM_API_TOKEN` → token saved by `attim login`.

Credential precedence for anonymous management: `--claim-token` → `ATTIM_CLAIM_TOKEN` → the CLI's locally saved claim token from an earlier publish.

## Scenario playbook

### Publish a demo for someone to open

```bash
./scripts/publish.sh ./dist
```

Hand back the live URL plus the anonymous handoff fields (slug, claimToken, expiry) if the user may want to update or delete it later.

### Publish, regenerate, then update the same URL

```bash
./scripts/publish.sh ./dist
# ...user regenerates the build...
./scripts/update.sh demo-slug ./dist
```

Do not create a second slug; the user asked to keep the URL.

### Permanent owned site

```bash
./scripts/login.sh
npx attim publish ./dist --slug my-site
```

Explicit slugs require account authentication. Owned sites never expire.

### Protect a page

```bash
npx attim publish ./dist --password "user-chosen-password" --password-access-ttl 86400
```

For an already-published owned site, use `npx attim password enable <slug> <password>` with a stored account token.

### Multi-environment variables on a claimed site

```bash
npx attim variables set my-site API_BASE_URL https://api.example.com
```

Placeholders (`{{ vars.API_BASE_URL }}`) are replaced at serve time. Only use values safe for public exposure.

### Clone a demo into a workspace

```bash
npx attim fork source-site --workspace 1
```

Fork requires account authentication; the copy is owned and permanent.

### Label an older version before a redesign

```bash
npx attim versions my-site
npx attim rename-version my-site 12 "Before redesign"
```

Use the listed permanent ID. Renaming changes only the label. To return its files to the live site later, run `npx attim restore my-site 12`; this creates a new, unnamed version.

### CI publishing

Export an account API token and publish without interaction:

```bash
export ATTIM_API_TOKEN=attim_uat_...
npx attim publish ./dist --slug ci-preview
```

Never print or commit the token; use the CI secret store.

### Claim token lost

If the claim token for an anonymous site is gone, the site cannot be updated, deleted, or claimed — claim tokens are shown once and cannot be recovered from the slug. Publish a new site instead and preserve the new claim token.

## MCP workflow

ATTIM exposes Streamable HTTP MCP at:

```text
https://attim.link/mcp
```

For owned sites and account tools, connect an ATTIM account through the MCP host's OAuth sign-in flow. Clients without OAuth support can continue to use an account API token as a bearer token. Never place an account token in a chat message or public file.

Modern MCP clients use `server/discover` and send protocol metadata and authentication on each request; no MCP session is created. Older clients using `initialize` may receive a session token in the response body or `Mcp-Session-Token` header. Preserve it for later tool calls and close it with `DELETE /mcp` when needed. OAuth clients send their access token on each call.

Anonymous MCP publishing works only after the server enables that path. Until then, use the credential-free CLI or API path. Do not silently substitute anonymous publishing for a signed-in user.

Available MCP tools:

| Tool | Purpose | Requires account |
| --- | --- | --- |
| `publish_site` | Publish a new site from inline files | No when anonymous MCP is enabled; sign in for an owned site |
| `clone_site` | Clone an anonymous live site into a new anonymous site | No |
| `fork_site` | Fork an anonymous site into an owned site | Yes |
| `update_site` | Upload a new version for a site | Yes, or claim token |
| `finalize_site` | Promote a pending version to live | Yes, or claim token |
| `delete_site` | Delete a site | Yes, or claim token |
| `rename_site` | Change an owned site's slug | Yes; paid plan |
| `list_sites` | List owned sites | Yes |
| `list_versions` | List retained versions and the live version ID for an owned project | Yes |
| `rename_version` | Set or clear a retained version's name | Yes; owner or editor |
| `preview_version` | Create a private preview link for a retained version | Yes |
| `download_version` | Get an MCP resource link for a retained version's ZIP | Yes |
| `restore_version` | Copy retained files into a new live version | Yes; owner or editor |
| `set_variables` | Set public variables on an owned site | Yes |
| `set_password_protection` | Enable or change owned-site protection; maintain grandfathered anonymous protection | Yes, or claim token for an already protected anonymous site |
| `get_profile` | Identify the connected account | Yes |

MCP file arguments are inline objects with `path` and either `content` or `contentBase64`. Root `index.html` is still required for static site publishes. A temporary publish returns a one-time `claimToken`; pass it to later update, finalize, or delete calls. Preserve it for user handoff without adding it to public files.

For version tools, use the project `slug` and the permanent `versionId` returned by `list_versions({"slug":"my-site"})`. To name version 12, call `rename_version({"slug":"my-site","versionId":"12","name":"Before redesign"})`; pass `name: null` to clear it. `preview_version` returns a one-use URL. `download_version` returns an `attim://versions/{slug}/{versionId}/download` resource link; read that resource with account authentication to receive the ZIP as base64 `application/zip` content. Do not treat the URI as a public download URL.

Before `restore_version`, use `list_versions` to get `currentVersionId`, then call `restore_version({"slug":"my-site","versionId":"12","expectedCurrentVersionId":"<currentVersionId>"})`. The expected ID protects against overwriting a newer publish. On conflict, list again and ask the user to reconsider the now-current version before retrying.

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
  "ttlSeconds": 43200
}
```

Finalize anonymous site:

```json
{
  "versionId": "1",
  "claimToken": "returned-on-create"
}
```

Version history fallback for owned projects uses an account bearer token:

```text
GET    /api/publish/:slug/versions
PATCH  /api/publish/:slug/versions/:versionId       {"name":"Before redesign"}
PATCH  /api/publish/:slug/versions/:versionId       {"name":null}
POST   /api/publish/:slug/versions/:versionId/preview
GET    /api/publish/:slug/versions/:versionId/download
POST   /api/publish/:slug/versions/:versionId/restore  {"expectedCurrentVersionId":"<currentVersionId>"}
```

Use `currentVersionId` from the list response for restore. Account bearer requests do not need browser CSRF headers. Browser-session mutations do require `X-ATTIM-CSRF`. The same owner/editor/viewer access rules apply as in the CLI.

## Main endpoints

```text
POST   /api/publish
GET    /api/publish/:slug
PUT    /api/publish/:slug
PATCH  /api/publish/:slug/metadata
DELETE /api/publish/:slug
POST   /api/publish/:slug/finalize
POST   /api/publish/:slug/clone
POST   /api/publish/:slug/fork
POST   /api/publish/:slug/claim
POST   /api/publish/:slug/request-claim-link
GET    /api/publishes
GET    /api/publish/:slug/variables
POST   /api/publish/:slug/variables
PUT    /api/publish/:slug/variables/:name
DELETE /api/publish/:slug/variables/:name
PATCH  /api/publish/:slug/password-protection
GET    /api/publish/:slug/versions
PATCH  /api/publish/:slug/versions/:versionId
POST   /api/publish/:slug/versions/:versionId/preview
GET    /api/publish/:slug/versions/:versionId/download
POST   /api/publish/:slug/versions/:versionId/restore
POST   /api/auth/request-code
POST   /api/auth/verify-code
GET    /api/auth/me
GET    /api/access/token
POST   /api/access/token
POST   /api/access/token/rotate
DELETE /api/access/token
GET    /api/plan
GET    /api/public/plans
GET    /api/workspaces
GET    /api/analytics
GET    /api/public/stats
POST   /api/support-requests
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
- Anonymous `ttlSeconds`: default `43200` (12 hours); min `60`; max `43200`.
- Owned sites are permanent and do not expire.
- Paths must be relative and traversal-safe.
- Duplicate normalized paths are rejected.
- Finalize verifies uploaded files before promotion.

Check live docs before treating these limits as permanent product facts.

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

## Pitfalls

- Do not return only a URL for anonymous publishes; include the claim token when it is returned.
- Do not lose a claim token before handoff. It cannot be recovered from the slug.
- Do not publish a parent folder that contains the site folder. Publish the folder that directly contains `index.html`.
- Do not put secrets in public variables, uploaded static files, or client-side configuration.
- Do not assume ATTIM runs backend code.
- Do not use `--slug` without account authentication.
- Do not use `--ttl` for owned sites; owned sites are permanent.
- Do not create a new slug when the user asked to update an existing site.
- Do not say a site is permanent unless it is claimed/authenticated or the command output confirms permanence.
- Do not invent upload URLs, version IDs, claim tokens, or finalization results.
- Do not reuse a preview URL or share it publicly; request a fresh preview when needed.
- Do not restore from a stale `currentVersionId`; list versions again after a conflict.
- Never print, commit, or paste account tokens into public files.

## Quick copy block

```text
Use ATTIM to publish static artifacts.
Read https://attim.link/docs for current capabilities.
Use ./scripts/publish.sh ./dist or npx attim publish ./dist when shell and npm are available.
Use https://attim.link/mcp when MCP is a better fit.
Return siteUrl, slug, finalization status, and claimToken when the publish is anonymous.
```
