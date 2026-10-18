# actions-runner-php

GitHub's [runner image](https://github.com/actions/runner/pkgs/container/actions-runner) with PHP 8.5, Composer, Node 24, PostgreSQL 18 and Playwright's Chromium already installed, for self-hosted runners such as Coolify's.

```
ghcr.io/simoneu01-org/actions-runner-php:latest
```

Each runner release also gets its own tag, such as `:2.338.0`.

## What's inside

- **PHP 8.5** from the ondrej/php PPA, with bcmath, curl, gd, intl, mbstring, mysql, pgsql, redis, sqlite3, xml and zip. Xdebug is installed but off.
- **Composer 2**
- **Node 24** with npm
- **PostgreSQL 18**, installed but stopped, with user `postgres` and password `postgres`. A runner with no Docker can't start a `services:` container, so a job starts it itself:
  ```yaml
  - run: sudo pg_ctlcluster 18 main start && sudo -u postgres createdb my_database
  ```
- **Chromium for Playwright**, its system libraries and the browser, in `/ms-playwright`

`shivammathur/setup-php` finds the installed PHP and only switches to it. Set `runner: self-hosted` in its `env`.

## Staying up to date

`.github/workflows/build.yml` checks GitHub's latest runner release every day and builds when there's a new one. GitHub stops sending jobs to a runner 30 days after a newer release. Every Monday it rebuilds anyway, for PHP and Ubuntu security updates. `RUNNER_VERSION` records the last version published. Dependabot keeps the workflow's actions current.
