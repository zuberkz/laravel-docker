# laravel-docker — local Docker images of the studio

Public repository: images `ghcr.io/zuberkz/laravel-php:<php>` and `ghcr.io/zuberkz/laravel-nginx:latest`
for the **local** development of the studio's Laravel sites. Production is ISPmanager with system PHP,
no Docker: the images mirror the server (PHP version, extensions, upload limits, HTTPS), they are not
production images. Comments and README are in Russian; this file is in English.

- `php/` — PHP-FPM on Alpine: extensions through `install-php-extensions`, configs in `php/conf`,
  processes as uid 1000 (`app`), Xdebug installed but `xdebug.mode=off`.
- `nginx/` — the Laravel front controller; the PHP service of a site is always `php-fpm`;
  `HTTPS=on` from `X-Forwarded-Proto` (OrbStack terminates https).
- `.github/workflows/build.yml` — native amd64 and arm64 runners, test then push by digest, merge
  into one tag; weekly rebuild. A new PHP version is a row in both matrices.

Rules:

- Something two or more sites need goes here; one site's need stays in that site (README,
  "Дополнить в одном проекте").
- Every change keeps existing sites working: the tags are rolling, sites pull them as is. A change
  that breaks sites (rename of the PHP service, another uid, a removed extension) is announced and
  done together with the starter (`../laravel-starter`).
- No secrets, client names or server addresses — the repository and the packages are public.
- Before pushing, build both images locally and run the starter on them (`docker build -t
  ghcr.io/zuberkz/laravel-php:8.5 php`, the same for nginx, then `docker compose up -d` in the
  starter). Commits: Conventional Commits in Russian; the user pushes.
