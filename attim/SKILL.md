---
name: attim
description: >
  Publish static work to live links at {slug}.attim.link and manage it: demos, reports,
  dashboards, browser-only tools, microsites, docs previews, decks, and static app builds.
  Covers temporary 12-hour publishes, keeping a link by email or claiming it, updates at the
  same link, targeted edits to a live site from any chat, version history, Insights, password
  protection, public variables, cloning and forking, workspaces, the ATTIM profile (one
  link-in-bio page with the user's links and projects), custom link pages, and WebMCP tools
  on published pages, through the CLI, MCP tools, or the HTTP API. Use when asked to
  "publish this", "host this static site", "share this HTML", "put this demo online",
  "update this ATTIM site", "change the page I published yesterday", "how is my page doing",
  "rename or restore a version", "protect this page", "add public variables", "make me a
  linktree", "set up my ATTIM profile", "bio link", "Instagram linkim", "clone or fork this
  ATTIM site", or "use ATTIM".
---

# ATTIM

**Skill version: 2.11.0**

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
| Change part of a site published before, in this chat or another | MCP `read_site`, then `edit_site` | CLI `download`, edit the files, then `update` |
| Copy a temporary site (clone or fork) | MCP `copy_site` | CLI `clone` / `fork` |
| List owned sites or versions; rename, preview, download, restore, protect, or delete a remote site | Matching MCP tool | Matching CLI command |
| Set a browser-visible public variable | MCP `set_variables` | CLI `variables set` |
| Set up the user's profile (link in bio, Linktree-style page) | MCP `get_public_profile`, then `save_profile` | CLI `profile create` |
| Change the profile's name, bio, social icons, theme, language, handle, or projects | MCP `get_public_profile` / `save_profile` | CLI `profile show` / `profile set` / `profile theme` / `profile projects` |
| Design a custom link page with your own markup (developers) | Write HTML to the contract below, `publish_site`, then `set_links` | Publish the template from the docs, then CLI `links set` |
| Add, edit, reorder, or count clicks on profile or link page links | MCP `list_links` / `set_links` / `get_link_stats` | CLI `links list` / `links set` / `links stats` |
| See how sites are doing: views and visitors from people, AI agents, and other bots | MCP `get_insights` | CLI `insights` |
| Identify the connected account | MCP `get_profile` | CLI `whoami` |
| Keep (claim) a temporary site | MCP `claim_site` with its slug and `claimToken`, plus the user's email when no account is connected | CLI `claim` |
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
npx attim login --rotate                               # replace the token; signing in already does this
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
npx attim publish ./dist --include-dotfiles                 # also publish hidden files and folders
npx attim publish ./dist --json                             # machine-readable JSON on stdout
```

- Anonymous publishes receive generated slugs; explicit `--slug` requires account authentication.
- Owned sites are permanent; anonymous sites expire after up to 12 hours.
- A saved CLI login makes `publish` an owned publish; `--ttl` is rejected for that publish.
- `--no-finalize` requires a later `finalize` command to make the version live.
- Folder publishes leave out hidden files and folders, such as `.env`, `.git`, and `.DS_Store`, and list what they left out. `--include-dotfiles` publishes them too; `.well-known/` is always published.
- ATTIM never publishes or serves files that can hold secrets or source history, even with `--include-dotfiles`: `.env` and `.env.*`, `.npmrc`, `.pypirc`, `.netrc`, `.git-credentials`, `.htpasswd`, and anything in `.git/`, `.svn/`, `.hg/`, `.ssh/`, or `.aws/`. On `ATTIM_SENSITIVE_PATH` (from the CLI, MCP, or API), leave them out and publish again; in `edit_site`, delete ones the site already has in the same edit.
- Before uploading, `publish` says whether it makes a temporary site or one the account owns, and from which token. `--dry-run --json` returns `anonymous`, `ownershipStatus`, and `tokenSource` without uploading anything.

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

Claiming converts an anonymous site into an owned site. The CLI reuses the locally saved claim token from the original publish. After claiming, the site becomes permanent and account-managed. `claim --all` reports every saved site, keeps going when one fails, keeps the failed ones for another try, and forgets the ones that expired or were claimed already.

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

Call `get_public_profile` first. If there is no profile, ask the user for their display name, a short bio, an optional https avatar image URL, the links (say which, if any, to pin), and the handle they want, then call `save_profile` with them. To change it, call `save_profile` with only what changes: profile, theme, handle, or projects (pass `projects` as their site slugs, in order), and the `version` from `get_public_profile` as `expectedVersion`; use `set_links` for link changes. Images can also be uploaded with `attim profile avatar` / `attim profile background`, or in the dashboard: the user selects their email at the top right to open the account menu, chooses **Your profile** (`/me`), then uploads the avatar on the **Profile** tab and the background photo on the **Design** tab. The older tool names `create_profile`, `update_profile`, `create_uplist`, `update_uplist`, and `get_uplist` still work but are no longer listed.

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

Template contract for custom designs (full text and the official template: https://attim.link/docs/features/link-pages, or the unlisted `get_link_page_template` MCP tool called by name):

- Place each placeholder once where its list belongs; `{{ attim.links.all }}` renders both lists and `{{ attim.links.json }}` gives `{ id, section, position, label, href }` items for script-rendered pages (keep `href` so clicks count).
- Never hand-write the link `<a>` tags; they are not tracked. Style `.attim-link`, `.attim-links`, `[data-attim-section="pinned"]`, and hide empty lists with `[data-attim-empty]`.
- Theme values are public variables (`LINKS_TITLE`, `LINKS_BIO`, `LINKS_BG`, ...). In CSS write a literal fallback first: `color: #fff; color: {{ vars.LINKS_TEXT }};`. Never put variables inside CSS custom properties.
- Set every text variable the page uses before finalizing; unset variables render literally. Keep titles and bios plain text without `<`, `>`, or `"`.

### Insights

On the Hobby and Team plans, `insights` shows how the account's sites are doing: page views and visitors from people first, then AI agents (by name) and other bots, counted apart, with the top sites, referrers, and countries (which count people).

```bash
npx attim insights
npx attim insights my-site --days 7
npx attim insights --workspace 42 --json
```

`--days` is 7, 30, or 90. `--json` prints the same fields as MCP `get_insights`. On the Free plan it exits with 3 and a hint to pass on; a slug that isn't one of the account's sites exits with 4.

### Password protection

New password protection requires an account-owned site. A previously protected anonymous site can keep, update, or disable its existing protection with its claim token, but cannot newly enable protection.

```bash
# Enable during publish
npx attim publish ./dist --password "secret-password" --password-access-ttl 86400

# Enable on a claimed site
npx attim password enable my-site "secret-password" --access-ttl 86400

# The same, with the password kept out of shell history and the process list
printf '%s' "$SITE_PASSWORD" | npx attim password enable my-site --password-stdin --access-ttl 86400

# Disable
npx attim password disable my-site
```

- `--access-ttl` (or `--password-access-ttl` at publish time) controls how long a successful password unlock lasts, in seconds. If omitted, ATTIM chooses the duration.
- The password can be an argument, `--password-stdin` (for `password enable` and `publish`), or `ATTIM_SITE_PASSWORD` (for `password enable`). Prefer stdin in scripts.
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
| `--workspace <id>` | Target workspace for publish, fork, list, claim, and insights. |
| `--access-ttl <seconds>` | Password unlock duration for `password enable`. |
| `--password-access-ttl <seconds>` | Password unlock duration when enabling protection during publish. |
| `--json` | Machine-readable JSON on stdout. Errors are JSON on stderr. |
| `--include-dotfiles` | Also publish hidden files and folders, except secret files such as `.env` and `.git/`. |
| `--password-stdin` | Read the site password from stdin. |
| `--output <file.zip>` | Output path for `attim download`. |
| `--no-finalize` | Leave the version pending for a separate finalize. |
| `--dry-run` | Build and validate locally without API or upload calls. |
| `--email <email>` | Email for `attim login`. |
| `--code <code>` | Sign in with a code already emailed; `attim login` checks it and sends no new code. |
| `--rotate` | Replace the account API token. Signing in with `attim login` already does this. |
| `--all` | Apply the command to all stored anonymous sites (claim). |
| `--help` / `--version` | Show usage or the CLI version. After a command, `--help` shows that command's options, examples, and exit codes. |

Arguments can also be passed by name, so their order never matters: `--site <slug>`, `--path <file-or-dir>`, `--version-id <id>`, `--name`, `--value`, `--label`, `--url`, and `--link-id`. A command rejects options it doesn't use instead of ignoring them.

Environment variables: `ATTIM_API_TOKEN`, `ATTIM_CLAIM_TOKEN`, `ATTIM_SITE_PASSWORD`, `ATTIM_BASE_URL`, `ATTIM_CONFIG_DIR`.

Credential precedence for account operations: `--token` → `ATTIM_API_TOKEN` → token saved by `attim login`.

Credential precedence for anonymous management: `--claim-token` → `ATTIM_CLAIM_TOKEN` → the CLI's locally saved claim token from an earlier publish.

### Exit codes and errors

The CLI never waits for input it can't get. Read its exit code before retrying:

| Exit code | Meaning |
| --- | --- |
| 0 | Success |
| 1 | Error; `attim doctor` also exits 1 when a check fails |
| 2 | Usage: the command can't run as typed; see `attim <command> --help` |
| 3 | Sign in, pass a claim token, or use an account or plan with access; a signed-out `whoami` exits 3 |
| 4 | Not found: no such site, version, or profile |
| 5 | Conflict: the site changed meanwhile, the name is taken, or `download` would overwrite a file |
| 6 | Rate-limited: wait `retryAfterSeconds`, then try again |

With `--json`, an error is JSON on stderr, `{"error":{"message","code","hint","status","retryAfterSeconds","exitCode"}}`, and stdout stays empty. Without it, an `Error:` line is followed by `Hint:` and `Retry after:` lines when there is a hint or a wait.

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

1. Call `get_public_profile`. Without a profile, ask the user for their display name, a short bio, an optional https avatar URL, the links (and which, at most 2, to pin), and the handle they want, then call `save_profile`. With one, use `save_profile` for the profile, theme, handle, or projects, and `set_links` for links. Hand off the profile link.
2. Only when a developer wants their own markup: write HTML that follows the contract above (or start from the template in the docs), publish it with `publish_site`, set the `LINKS_*` (or your own) variables with `set_variables`, then add links with `set_links`. The unlisted `create_link_page` tool, called by name, publishes the official template with theme values and links in one call.
3. To change links later, call `list_links` first and pass each kept link's `id` back to `set_links` so its click history survives. Links you omit are deleted.
4. Use `get_link_stats` to report clicks and why each link sits where it does.

### Make an interactive page usable by browser agents

When you publish a calculator, a dashboard with filters, a form, or another interactive page, you can register WebMCP tools in its script so AI agents in the browser can use it instead of clicking around: https://attim.link/docs/features/agent-tools. Keep it static: tools run in the visitor's browser, and everything in the page, public variables included, is public, so never put API keys or secrets in a tool.

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

Without a connected account, `publish_site` and `copy_site` create temporary sites that last up to 12 hours. Tell the user how long the link stays live and offer to keep it by email with `claim_site`. Do not make a temporary site for a user who is signed in.

Available MCP tools:

| Tool | Purpose | Requires account |
| --- | --- | --- |
| `publish_site` | Publish a new site from inline files | No (temporary site); sign in for an owned site |
| `copy_site` | Copy a live temporary site to a new link: permanent in the connected account, or temporary with its own `claimToken` without one | No (temporary copy); sign in for an owned copy |
| `claim_site` | Keep a temporary site with its slug and `claimToken`: move it into the connected account, or with the user's `email`, email them a link that keeps it and creates their free account | No with an `email`; without one, the user is asked to connect an account |
| `update_site` | Replace every file of a site with a new version | Yes, or claim token |
| `read_site` | Open a site published before: live `versionId`, file list, and text of HTML, CSS, and JS files, in pages; `search` finds text | Yes, or claim token; Team viewers can read |
| `edit_site` | Change a live site at the same link with exact replacements, whole-file writes, and deletes, as a new named version | Yes, or claim token; owner or editor |
| `delete_site` | Delete a site | Yes, or claim token |
| `rename_site` | Change an owned site's slug | Yes; paid plan |
| `list_sites` | List owned sites, one line each with title and link | Yes |
| `list_versions` | List retained versions and the live version ID for an owned project | Yes |
| `rename_version` | Set or clear a retained version's name | Yes; owner or editor |
| `preview_version` | Create a private preview link for a retained version | Yes |
| `download_version` | Get an MCP resource link for a retained version's ZIP | Yes |
| `restore_version` | Copy retained files into a new live version | Yes; owner or editor |
| `set_variables` | Set public variables on an owned site | Yes |
| `set_password_protection` | Enable or change owned-site protection; maintain grandfathered anonymous protection | Yes, or claim token for an already protected anonymous site |
| `save_profile` | Set up the account's profile, its one link-in-bio page, or change it: name, bio, socials, theme, language, links, projects, and handle | Yes |
| `get_public_profile` | Read the profile with its links and projects, or `profile: null` before set-up | Yes |
| `list_links` | List a link page's links, ids, and visible positions | Yes |
| `set_links` | Replace every link on a link page; pass ids to keep click history | Yes; owner or editor |
| `get_link_stats` | Link page views, clicks, click-through rate, and position reasons | Yes |
| `get_insights` | Page views and visitors from people, AI agents (by name) and other bots counted apart, and top sites, referrers, and countries, for every site or one | Yes; Hobby or Team plan |
| `get_profile` | Identify the connected account | Yes |

Not listed, but still callable by name for saved prompts and scripts: `clone_site` (always a temporary copy) and `fork_site` (now `copy_site`), `create_profile` and `update_profile` (now `save_profile`), `finalize_site` (makes a version published with `finalize: false` live), and the developer tools `create_link_page` and `get_link_page_template`.

A tool that runs and fails answers with `isError: true`: its text says what went wrong and what to do next, and `_meta["attim/error"]` carries the `code`, `status`, and details such as `retryAfterSeconds`. Fix the call from that hint instead of switching paths. Site results' `structuredContent` has `slug`, `siteUrl`, `status` (`live` or `pending`), and `versionId`, plus `expiresAt` and the new `claimToken` for a temporary site; upload links and internal IDs are never included. AI apps with MCP Apps, such as Claude and ChatGPT, also show the site in a card with a preview, **Open site**, and, for a temporary site, **Keep this link**.

MCP file arguments are inline objects with `path` and either `content` or `contentBase64`. Root `index.html` is still required for static site publishes. A temporary publish returns a one-time `claimToken`; pass it to later read, edit, update, or delete calls. Preserve it for user handoff without adding it to public files.

For version tools, use the project `slug` and the permanent `versionId` returned by `list_versions({"slug":"my-site"})`. To name version 12, call `rename_version({"slug":"my-site","versionId":"12","name":"Before redesign"})`; pass `name: null` to clear it. `preview_version` returns a one-use URL. `download_version` returns an `attim://versions/{slug}/{versionId}/download` resource link; read that resource with account authentication to receive the ZIP as base64 `application/zip` content. Do not treat the URI as a public download URL.

When the user asks how a page or their sites are doing, call `get_insights` with the site's `slug` or link, or with no slug for every site; `days` is 7, 30, or 90 (30 by default) and `workspaceId` reads a team Workspace. Report people first (`pageViews` and `visitors` count people only, as do `topSites`, `topReferrers`, and `topCountries`), then `aiAgents` with `topAgents` by name, then `bots`. On `ATTIM_ANALYTICS_PLAN_REQUIRED`, pass the hint on: Insights come with the Hobby and Team plans.

Before `restore_version`, use `list_versions` to get `currentVersionId`, then call `restore_version({"slug":"my-site","versionId":"12","expectedCurrentVersionId":"<currentVersionId>"})`. The expected ID protects against overwriting a newer publish. On conflict, list again and ask the user to reconsider the now-current version before retrying.

### Change a site later

To change a site published before, in this chat or another, do not rebuild it. Rebuilding changes its look and loses earlier changes.

1. Find it with `list_sites` (one line per site, with title and link), or use the link the user gives you.
2. Open it with `read_site({"slug":"my-site"})`; a link works as the slug. It returns the live `versionId`, the file list, and the text of the HTML, CSS, and JS files. For a big site, follow the `path` and `offset` lines it prints, or pass `search` to find the part to change.
3. Change only what was asked, with every requested change in one `edit_site` call:

   ```json
   {"slug":"my-site","baseVersionId":"42","versionName":"Added Q3 numbers","replacements":[{"path":"index.html","oldText":"<td>Q3</td><td>TBD</td>","newText":"<td>Q3</td><td>$1.2M</td>"}]}
   ```

   Copy `oldText` exactly from `read_site`, with enough surrounding text to appear once, or set `replaceAll`. Use `writes` for new or fully rewritten files and `deletes` to remove files. Only the last 10 versions are kept, so many small edits push out the version from before the chat.
4. Report the same link and the new version name. For an owned site, the version from before the change can be restored with `restore_version`.

On `ATTIM_EDIT_NO_MATCH` or `ATTIM_EDIT_AMBIGUOUS`, read or `search` again and fix `oldText`. On `ATTIM_VERSION_CONFLICT`, the site changed in the meantime: read it again and redo the edit on the current text. Keep `{{ vars.* }}` and `{{ attim.links.* }}` placeholders as they are. Use `update_site` only to replace the whole site. A temporary site can only be changed with its `claimToken`, so if the user may want to change it later in another chat, ask for their email and keep it with `claim_site` first. Profiles and managed link pages are not edited as files; use `save_profile` or `set_links`. Confirm with the user before changing a live site.

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

Use this only when CLI and MCP are not viable. Full reference: https://attim.link/docs/api.

The HTTP API needs an account API token on each request (`Authorization: Bearer attim_uat_...`). Without an account, use the CLI or MCP: temporary publishing over plain HTTP asks for a browser check that scripts can't pass (`ATTIM_TURNSTILE_REQUIRED`).

Create or update flow:

1. Build a complete file manifest. Every file needs `path`, `size`, and `contentType`; `hash` is optional.
2. Include root `index.html`.
3. Create with `POST https://attim.link/api/publish`, or update with `PUT https://attim.link/api/publish/:slug`.
4. Save `slug`, `siteUrl`, `upload.versionId`, `upload.uploads[]`, and `claimToken` when present.
5. Upload every file with the returned upload target's exact method, URL, and headers.
6. Finalize with `POST https://attim.link/api/publish/:slug/finalize` and the returned `versionId`.
7. For a temporary site made by the CLI or MCP, send its `claimToken` in the `X-ATTIM-Claim-Token` header or the JSON body.

Minimal publish request:

```json
{
  "files": [
    {
      "path": "index.html",
      "size": 1234,
      "contentType": "text/html; charset=utf-8"
    }
  ]
}
```

Finalize a temporary site made by the CLI or MCP:

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
- Emails: at most one of each kind per address per minute. Sign-in codes and links share one wait per address across the CLI and browser; claim links wait per site and address; workspace invitations per workspace and address. During the wait, `POST /api/auth/request-code`, `POST /api/auth/magic-link/request`, `POST /api/publish/:slug/request-claim-link` (and MCP `claim_site` with an `email`), and `POST /api/workspaces/:workspaceId/invitations` send nothing and return `429` with `code: "ATTIM_EMAIL_COOLDOWN"`, `retryAfterSeconds`, and a `Retry-After` header. The code, link, or invitation already emailed keeps working.

Check live docs before treating these limits as permanent product facts.

## Required handoff to the user

A publish is not complete until the user receives the fields needed to open and control the site later.

For anonymous publishes, return:

- `siteUrl`
- `slug`
- whether finalization succeeded
- `claimToken` if the tool returned it
- expiry information if present

After an anonymous MCP publish, tell the user how long the link stays live and ask for their email to keep it. When they give it, call `claim_site` with the slug, `claimToken`, and `email`. ATTIM emails them a **Keep this link** button that keeps the site and creates their free account; it works for a few minutes, and a new email can be sent until the site expires. Keeping it this way doesn't connect the chat to their account: to change the site later, they sign in to ATTIM when asked.

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
- Do not put secrets in public variables, uploaded static files, client-side configuration, or WebMCP tools.
- Do not assume ATTIM runs backend code.
- Do not use `--slug` without account authentication.
- Do not use `--ttl` for owned sites; owned sites are permanent.
- Do not create a new slug when the user asked to update an existing site.
- Do not rebuild a site from scratch, or resend every file with `update_site`, when the user asked to change part of it; use `read_site` and `edit_site`.
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
