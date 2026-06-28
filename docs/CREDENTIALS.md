# Credentials — never commit

## Kaggle API

| Location | Machine | Notes |
|----------|---------|-------|
| `~/.kaggle/access_token` | Mac | Mode `600`; new `KGAT_…` token format |
| `/home/rstudio/.kaggle/access_token` | VPS | Same token; owner `rstudio` |
| `KAGGLE_API_TOKEN` | env optional | Alternative to file; use in systemd `EnvironmentFile` later |

Generate / rotate: [kaggle.com/settings](https://www.kaggle.com/settings) → Create New Token.

**If a token appears in chat or a screenshot, regenerate it** and update both files above.

## RStudio Server (VPS)

- URL via SSH tunnel: `http://localhost:8787`
- User: `rstudio`
- Password: store in a **local-only** file on your Mac (e.g. `credentials.local.md`), gitignored — not in this repo

## SSH

- Host alias: `ionos-mastr` → `82.165.167.86`
- Key-based login configured via your existing MaStR setup scripts

## What this repo ignores

See root [`.gitignore`](../.gitignore): `.kaggle/`, `data/`, `*.csv`, `*.env`, `*.credentials.local.md`.
