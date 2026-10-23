---
name: attim
description: >
  ATTIM lets agents publish static artifacts to live URLs at {slug}.attim.link.
  Use it for generated demos, reports, dashboards, browser-only tools, microsites,
  docs previews, decks, and static app builds that need a shareable URL. Supports
  anonymous 12-hour publishes, claimed permanent sites, updates that keep the same
  URL, password protection, public variables, cloning and forking, workspaces,
  project version history, the ATTIM profile (one public link-in-bio page per account with the user's links and
  ATTIM projects, with click counts), custom link pages, CLI publishing, MCP tools, and raw API fallback. Use when
  asked to "publish this", "host this static site", "share this HTML", "put this demo online", "update this ATTIM
  site", "rename or restore a version", "protect this page", "add public variables", "make a link in bio page",
  "make me a linktree", "set up my ATTIM profile", "show my projects on my profile", "bio link", "Instagram linkim",
  "add or reorder my links", "clone or fork this ATTIM site", or "use ATTIM".
---

# ATTIM

**Skill version: 2.6.0**

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
| Set up the user's profile (link in bio, Linktree-style page) | MCP `create_profile` | CLI `profile create` |
| Change the profile's name, bio, social icons, theme, language, handle, or projects | MCP `get_public_profile` / `update_profile` | CLI `profile show` / `profile set` / `profile theme` / `profile projects` |
| Design a custom link page with your own markup (developers) | MCP `get_link_page_template`, then `publish_site`; or `create_link_page` | Publish the template from the docs, then CLI `links set` |
| Add, edit, reorder, or count clicks on profile or link page links | MCP `list_links` / `set_links` / `get_link_stats` | CLI `links list` / `links set` / `links stats` |
| Identify the connected account | MCP `get_profile` | CLI `whoami` |
| Keep (claim) a temporary site | MCP `claim_site` with its slug and `claimToken` | CLI `claim` |
| Inspect local CLI setup, or list/delete public variables | CLI or ATTIM web UI | Raw API where that operation is supported |

Apply these rules before every ATTIM action:

1. For local files, let the CLI read and upload the build directly. Do not copy a directory into MCP inline arguments. For files supplied in chat, use MCP without creating a local build solely to reach the CLI.
2. For an owned-site MCP action, use the host's ATTIM OAuth connection. For an owned-site CLI action, use the CLI's stored account API token or its normal login flow. Do not paste either credential into site files or public variables.
3. Publish to the account when the user is signed in through OAuth or the CLI. Use temporary **anonymous** publishing only without an account connection. Confirm that it sends no account credential; `--ttl` alone does not select anonymous publishing. Retain the returned `claimToken` for later anonymous mutations. If the CLI stored it locally, prefer the CLI for that site's update or claim.
4. Choose one path for each mutation and inspect its result before any retry. Do not publish through both MCP and CLI for the same request. An entitlement error is not a reason to switch paths.
5. Use the raw API only when no available MCP or CLI path can complete the operation, or when explicit manifest/upload/finalize control is required. Follow the same ownership, claim-token, and validation rules on that path.

The MCP server has no `doctor`, `info`, or public-variable list/delete tool today. Do not invent one.

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
npx attim login --email you@example.com                # step 1: email a sign-in code (in a terminal, it then asks for the code)
npx attim login --email you@example.com --code 123456  # step 2: sign in with the emailed code; sends no new code
npx attim login --rotate                               # explicit rotation for scripted flows
npx attim login --token attim_uat_...                  # store a token you already saved, without rotating
npx attim whoami                                       # verify the stored token
npx attim logout                                       # remove the local token (does not revoke it server-side)
```

- `attim login` creates or rotates an account API token and stores it locally at `~/.config/attim/config.json` (override with `ATTIM_CONFIG_DIR`).
- If the account already has an active token, `attim login` rotates it because ATTIM cannot reveal an existing raw token again.
- Agents have no terminal to type a code in, so sign in in two steps. Ask the user for their email and run `attim login --email <email>`: it emails the code and exits 1 without signing in, by design, printing the finishing command. Ask the user for the code from that email, then run `attim login --email <email> --code <code>`. The CLI prints that command as `attim login ...`; run it the same way you ran step 1 (`npx attim` or `./scripts/login.sh`). Without `--email`, login stops before sending anything.
- ATTIM emails one sign-in code per address per minute, shared by the CLI and browser sign-in. A second `attim login` within that minute sends no new code and points to the code already sent, which still works. If the user is waiting for a code, do not run step 1 again: ask them for the code from the first email (and to check spam), then run step 2.
- A CLI older than 0.1.5 (`npx attim --version`) cannot finish this without a terminal: it asks for a new code even with `--code` (within the minute it stops with `ATTIM_EMAIL_COOLDOWN`; after it, the new code retires the one the user has), and without `--code` it waits for input it cannot read. Ask the user to run `npx attim login` in their own terminal instead.
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

### Profile (link in bio)

Each ATTIM account has one profile: a public page at `<handle>.attim.link` that works as a link in bio. Every profile has the same structure: name, bio, avatar, and optional social icons; up to 2 pinned links on top; the rest of the links; then a Projects section with the user's own ATTIM sites. ATTIM renders the page itself; the owner customizes only the theme (a preset plus colors, font, button shape/fill/shadow, and background). Link and project clicks are counted, and on paid plans the unpinned links are ordered by what visitors click. Free profiles show a small "Made with ATTIM" badge.

The handle is free on every plan; on Free it can change once a week, and the old address redirects for 30 days. The profile is public and can appear in search results unless the user turns that off; it cannot be password-protected and does not count toward the plan's project limit. Projects stay hidden from search unless the user turns search on for each one.

Call `get_public_profile` first. If there is no profile, ask the user for their display name, a short bio, an optional https avatar image URL, the links (say which, if any, to pin), and the handle they want, then call `create_profile`. Use `update_profile` for profile, theme, handle, or project changes (pass `projects` as their site slugs, in order) and `set_links` for link changes. Images can also be uploaded with `attim profile avatar` / `attim profile background`, or in the dashboard: the user selects their email at the top right to open the account menu, chooses **Your profile** (`/me`), then uploads the avatar on the **Profile** tab and the background photo on the **Design** tab. The older tool names `create_uplist`, `update_uplist`, and `get_uplist` still work but are no longer listed.

```bash
npx attim profile create ada --name "Ada Lovelace" --bio "Engines and ideas" --pin "Newsletter=https://news.example.com/" --link "Talks=https://talks.example.com/"
npx attim profile show
npx attim profile set --bio "Analytical engines" --social github=https://github.com/ada
npx attim profile theme --preset paper --accent "#aa3300" --shape pill
npx attim profile avatar ./avatar.png
npx attim profile projects add engine-notes demo
```

Profiles and other managed link pages refuse new file uploads and version restores. CLI profile commands act on the account's profile; pass a slug to edit an older extra link page (`attim profile show <slug>`), and turn one back into an ordinary site with `attim profile detach <slug>`. `attim uplist` still works as another name for `attim profile`.

### Custom link pages (developers)

A custom link page is a claimed site whose HTML contains `{{ attim.links.pinned }}` and `{{ attim.links.smart }}`. ATTIM stores the links with the project, renders them at serve time as `<a class="attim-link">` buttons, counts clicks through a same-site redirect, and lets the owner change links without republishing. Pinned links (at most 2) stay on top in the owner's order; the rest are Smart links. Up to 50 links, public `http(s)` destinations only.

```bash
npx attim links list my-links
npx attim links add my-links https://shop.example.com/ My shop --pinned
npx attim links set my-links links.json
npx attim links remove my-links lk_0123456789abcdef
npx attim links stats my-links --days 30
```

Template contract for custom designs (full text: `get_link_page_template` or https://attim.link/docs/features/link-pages):

- Place each placeholder once where its list belongs; `{{ attim.links.all }}` renders both lists and `{{ attim.links.json }}` gives `{ id, section, position, label, href }` items for script-rendered pages (keep `href` so clicks count).
- Never hand-write the link `<a>` tags; they are not tracked. Style `.attim-link`, `.attim-links`, `[data-attim-section="pinned"]`, and hide empty lists with `[data-attim-empty]`.
- Theme values are public variables (`LINKS_TITLE`, `LINKS_BIO`, `LINKS_BG`, ...). In CSS write a literal fallback first: `color: #fff; color: {{ vars.LINKS_TEXT }};`. Never put variables inside CSS custom properties.
- Set every text variable the page uses before finalizing; unset variables render literally. Keep titles and bios plain text without `<`, `>`, or `"`.

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
| `--email <email>` | Email for `attim login`. |
| `--code <code>` | Sign in with a code already emailed; `attim login` checks it and sends no new code. |
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
./scripts/login.sh --email you@example.com                # emails a code; ask the user for it
./scripts/login.sh --email you@example.com --code 123456  # signs in with that code
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

### Build a link-in-bio page

1. If the user has no custom design, call `create_link_page` with `title`, optional `bio`, `avatarUrl`, `theme` (`background`, `text`, `buttonBackground`, `buttonText`, `accent` as CSS colors; `font` as `system`, `serif`, `rounded`, `geometric`, or `mono`), and `links` (`{ label, url, section? }`, at most 2 pinned). It publishes, seeds variables and links, then finalizes in one call.
2. For a custom design, call `get_link_page_template`, write HTML that follows its contract, publish it with `publish_site`, set the `LINKS_*` (or your own) variables with `set_variables`, then add links with `set_links`.
3. To change links later, call `list_links` first and pass each kept link's `id` back to `set_links` so its click history survives. Links you omit are deleted.
4. Hand off the `siteUrl` and the dashboard Links URL. Use `get_link_stats` to report clicks and why each link sits where it does.

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
| `claim_site` | Keep a temporary site: move it into the connected account with its slug and `claimToken` | Yes; the user is asked to connect a free account first |
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
| `create_link_page` | Publish the official link page template with theme values and links set | Yes |
| `list_links` | List a link page's links, ids, and visible positions | Yes |
| `set_links` | Replace every link on a link page; pass ids to keep click history | Yes; owner or editor |
| `get_link_stats` | Link page views, clicks, click-through rate, and position reasons | Yes |
| `get_link_page_template` | Official link page HTML, theme variables, and placeholder contract | Yes |
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
POST   /api/publish/:slug/request-claim-link        # emails a claim link; one per site and address per minute
GET    /api/publishes
GET    /api/publish/:slug/variables
POST   /api/publish/:slug/variables
PUT    /api/publish/:slug/variables/:name
DELETE /api/publish/:slug/variables/:name
GET    /api/publish/:slug/links
PUT    /api/publish/:slug/links
POST   /api/publish/:slug/links
PUT    /api/publish/:slug/links/order
PATCH  /api/publish/:slug/links/settings
GET    /api/publish/:slug/links/stats
PATCH  /api/publish/:slug/links/:linkId
DELETE /api/publish/:slug/links/:linkId
GET    /api/links/template
PATCH  /api/publish/:slug/password-protection
GET    /api/publish/:slug/versions
PATCH  /api/publish/:slug/versions/:versionId
POST   /api/publish/:slug/versions/:versionId/preview
GET    /api/publish/:slug/versions/:versionId/download
POST   /api/publish/:slug/versions/:versionId/restore
POST   /api/auth/request-code                       # emails a sign-in code; one per address per minute
POST   /api/auth/verify-code
GET    /api/auth/me
GET    /api/access/token
POST   /api/access/token
POST   /api/access/token/rotate
DELETE /api/access/token
GET    /api/plan
GET    /api/public/plans
GET    /api/workspaces
POST   /api/workspaces/:workspaceId/invitations     # emails an invitation; one per workspace and address per minute
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
- Emails: at most one of each kind per address per minute. Sign-in codes and links share one wait per address across the CLI and browser; claim links wait per site and address; workspace invitations per workspace and address. During the wait, `POST /api/auth/request-code`, `POST /api/auth/magic-link/request`, `POST /api/publish/:slug/request-claim-link`, and `POST /api/workspaces/:workspaceId/invitations` send nothing and return `429` with `code: "ATTIM_EMAIL_COOLDOWN"`, `retryAfterSeconds`, and a `Retry-After` header. The code, link, or invitation already emailed keeps working.

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
- Do not retry a sign-in code, sign-in link, claim-link, or invitation request that returned `429 ATTIM_EMAIL_COOLDOWN`. Ask the user to use the code or link already emailed, or wait `retryAfterSeconds`; a new sign-in code retires the previous one.
- Do not hand-write tracked links on a link page; render them with `{{ attim.links.* }}` placeholders.
- Do not call `set_links` without ids from `list_links` when the user wants to keep click history; omitted links are deleted.
- Do not pin more than 2 links, and do not expect clone or fork to copy a link page's links.

## Quick copy block

```text
Use ATTIM to publish static artifacts.
Read https://attim.link/docs for current capabilities.
Use ./scripts/publish.sh ./dist or npx attim publish ./dist when shell and npm are available.
Use https://attim.link/mcp when MCP is a better fit.
Return siteUrl, slug, finalization status, and claimToken when the publish is anonymous.
```
