# Malware guard

In 2026 this repo was hit several times by self-spreading malware. It is pushed with a stolen
GitHub login, usually by rewriting the latest commit so the author, date and message look normal.
It plants code that runs on a developer's machine as soon as the project is opened or started:

- `.vscode/tasks.json` with a task that runs when the folder is opened, plus `.vscode/settings.json`
  that turns automatic tasks on and hides the terminal
- a JavaScript loader disguised as fonts, in a `public/fonts` folder inside Android source folders
- `admin/init` and `backend/init` (earlier `api.js`), started by `node init &&` in `package.json`
- obfuscated code pushed far to the right after a long run of spaces in `tailwind.config.js`
- `config.bat` added to `.gitignore`

The loader downloads its next stage from blockchain transactions and runs it with Node.

## Check a branch

```bash
bash scripts/security/scan-malware.sh                  # current commit
bash scripts/security/scan-malware.sh origin/develop   # any branch or commit
```

It reads git objects only. Nothing is checked out or run. Exit code 1 means infected.

## Protection in this repo

- `.github/workflows/malware-scan.yml` runs the scan on every push and pull request. A red check
  on a commit nobody on the team made means the account that pushed it is compromised.
- `bash scripts/security/install-hooks.sh` installs local pre-commit and pre-push checks. Run it
  once per clone.

## Rules for everyone working on this repo

1. Scan a branch before you check it out, open it in an editor, or run `npm`/`pnpm`/`flutter` on it.
   Editor plugins (ESLint, Tailwind, Prettier, Gradle) execute config files on open.
2. In your VS Code user settings set `"task.allowAutomaticTasks": "off"` and keep Workspace Trust on.
   Do not trust a fresh clone until it has been scanned.
3. Never put a GitHub token in a remote URL. Use the macOS Keychain or `gh auth login`.
4. Use fine-grained GitHub tokens limited to the repos you need, with an expiry date.
5. Never merge or pull a commit you do not recognise. Check the GitHub security log first.
