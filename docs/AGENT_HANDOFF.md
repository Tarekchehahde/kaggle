# Agent handoff — Kaggle → R → Shiny pipeline

**Purpose:** Onboard a **new Cursor agent** to continue this project or solve **another Kaggle dataset** the same way.

**Repo:** [Tarekchehahde/kaggle](https://github.com/Tarekchehahde/kaggle) · branch **`main`**  
**Local path:** `/Users/tarek-lokal/Documents/kaggle/`  
**VPS code:** `/opt/kaggle/` on **`82.165.167.86`** (SSH alias `ionos-mastr`)  
**Not related to:** transtek, MaStR (`/opt/mastr-shiny/`)

---

## Copy this prompt into a new chat

### Continue existing AI-on-students solution

```
I'm continuing the Kaggle pipeline project (Tarekchehahde/kaggle).

Read first:
1. docs/AGENT_HANDOFF.md
2. docs/WORKFLOW.md
3. docs/SOLUTION.md

Live Shiny app: http://82.165.167.86/ai_impact_students/
VPS service: kaggle-ai-impact-students (port 3856)
Local repo: /Users/tarek-lokal/Documents/kaggle/

Credentials: ~/.kaggle/access_token on Mac; /home/rstudio/.kaggle/access_token on VPS.
Never commit tokens or data/ CSVs.

Deploy after changes: bash scripts/deploy-vps.sh
```

### Start a new Kaggle dataset (second project in same repo)

```
I'm adding a new Kaggle dataset to the kaggle repo (standalone from MaStR/transtek).

Read first:
1. docs/AGENT_HANDOFF.md
2. docs/WORKFLOW.md
3. docs/ARCHITECTURE.md

Workflow:
1. I will send a Kaggle dataset URL + goal.
2. Document it in docs/datasets/<slug>.md — wait for my "go" before fetch.
3. Fetch → R loader in R/ → Shiny in shiny/ or shiny/<slug>/ → deploy VPS.

Patterns to copy from the first solution:
- R/load_ai_students.R (paths, base read.csv)
- shiny/app.R (bslib + plotly; use sample_rows() not slice_sample(n = min(..., n())))
- scripts/fetch-*.sh, scripts/deploy-vps.sh, systemd/kaggle-*.service
- Next free VPS port after checking nginx (currently 3856 used by ai_impact_students)

SSH: ionos-mastr. Kaggle CLI on Mac and VPS (user rstudio).
GitHub: https://github.com/Tarekchehahde/kaggle
```

---

## What exists today (pilot)

| Item | Location |
|------|----------|
| Dataset | `laveshjadon/ai-impact-on-students` |
| Dataset doc | `docs/datasets/ai-impact-on-students.md` |
| Loader | `R/load_ai_students.R` |
| Shiny app | `shiny/app.R` |
| Fetch | `scripts/fetch-ai-impact-on-students.sh` |
| Deploy | `scripts/deploy-vps.sh` |
| systemd | `systemd/kaggle-ai-impact-students.service` |
| Live URL | http://82.165.167.86/ai_impact_students/ |

### Titanic (competition)

| Item | Location |
|------|----------|
| Dataset doc | `docs/datasets/titanic.md` |
| Loader | `R/load_titanic.R` |
| Shiny app | `shiny/titanic/app.R` |
| Fetch | `scripts/fetch-titanic.sh` |
| Deploy | `scripts/deploy-titanic-vps.sh` |
| systemd | `systemd/kaggle-titanic.service` |
| Live URL | http://82.165.167.86/titanic/ |

---

## Infrastructure (shared VPS)

| Item | Value |
|------|--------|
| IP | `82.165.167.86` |
| SSH | `ssh ionos-mastr` |
| RStudio | tunnel `http://localhost:8787` (user `rstudio`) |
| MaStR hub (separate) | http://82.165.167.86/ |
| Kaggle app path | `/ai_impact_students/` → port **3856** |

Before deploying a **second** app, list used ports:

```bash
ssh ionos-mastr 'grep -oh "127.0.0.1:38[0-9][0-9]" /etc/nginx/sites-available/mastr-hub | sort -u'
```

Use a new port, new nginx `location`, new `kaggle-*` systemd unit — do not mix with `/opt/mastr-shiny/`.

---

## Doc index

| File | When to read |
|------|----------------|
| [`WORKFLOW.md`](WORKFLOW.md) | Dataset URL → phases → when user says "go" |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Mac, VPS, Cursor, Kaggle CLI |
| [`CREDENTIALS.md`](CREDENTIALS.md) | Tokens (never in git) |
| [`SOLUTION.md`](SOLUTION.md) | AI-on-students implementation |
| [`KAGGLE_KERNEL.md`](KAGGLE_KERNEL.md) | Publish notebook to Kaggle profile |
| [`datasets/`](datasets/) | One markdown file per dataset |

---

## Known pitfalls

1. **`slice_sample(n = min(k, n()))`** — fails; use `sample_rows(df, k)` with `nrow(df)` (see `shiny/app.R`).
2. **ggplotly + column named `n`** — rename to `n_students` or similar.
3. **readr on VPS R 4.6** — use base `read.csv` in loaders (see `load_ai_students.R`).
4. **Kaggle kernel API push** — may return 403; use manual import from GitHub (`docs/KAGGLE_KERNEL.md`).
5. **Secrets** — `.gitignore` excludes `.kaggle/`, `data/`, `*.credentials.local.md`.

---

## Agent task recipes

### Deploy after code change

```bash
cd /Users/tarek-lokal/Documents/kaggle
bash scripts/deploy-vps.sh
```

### New dataset fetch (after user approval)

```bash
bash scripts/fetch-<slug>.sh   # create script from fetch-ai-impact-on-students.sh template
```

### Health check

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://82.165.167.86/ai_impact_students/
ssh ionos-mastr 'systemctl status kaggle-ai-impact-students --no-pager'
```

---

## Related handoff (different project)

MaStR Shiny hub on the **same VPS** but **different repo**:

- Local: `/Users/tarek-lokal/Documents/mastr-shiny/WORK/docs/AGENT_HANDOFF_IONOS_VPS.md`
- GitHub: [shiny-dashboard-hub](https://github.com/Tarekchehahde/shiny-dashboard-hub)

Do not conflate MaStR deploy paths with `/opt/kaggle/`.
