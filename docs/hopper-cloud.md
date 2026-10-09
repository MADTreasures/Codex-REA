# Hopper 6.4.2 in Codex Cloud

This is a separate, additive setup. Existing REA/Ghidra setup scripts, client
registrations and the published cloud configuration are unchanged. Nothing is
pushed or published by these scripts. Hopper is used only in its free demo mode;
normal demo limits (including session duration and disabled save/export) remain.

## Historical verified reference, 2026-10-09

These results describe the original installed reference. Reusing that container
or image does not establish that a fresh build or a restoration has succeeded.

- Existing container: `hopper-rea-642-20261009`, Ubuntu 24.04, amd64.
- Docker 28.4.0, managed local socket `/var/run/docker.sock`, storage driver vfs.
- Hopper 6.4.2: `/opt/hopper/bin/Hopper`; launcher SHA-256
  `0294ced141cc373468ee22d8343e7dac41980cb05a937994ca81c9f09afe7ded`.
- Official DEB: 35,755,772 bytes; SHA-256
  `7fb92d7bc94edbbf794e348a9ab2f9606b96578529985e884dff04a63e42b2c7`;
  SHA-1 `e4f79dff602648a8ff4a88b773875b6bfac0dc65`.
- Existing REA 6.1.0 is mounted read-only at `/opt/rea`; existing Node 24.19.0
  is mounted read-only at `/usr/local/bin/node`. Neither is installed again.
- Required runtime: Xvfb/xauth, Python 3.12 **and libpython3.12t64**, libX11,
  libXtst, Qt 6.4.2 GUI/XML/PrintSupport/Network, qt6-qpa-plugins,
  libxcb-cursor0, libatomic1 and DejaVu fonts. Desktop helpers are also included.
- `REA_ANALYSIS_PROVIDER=hopper`, `HOPPER_LAUNCHER_PATH=/opt/hopper/bin/Hopper`.
  No external DISPLAY is needed: REA's verified Linux demo adapter creates its
  private Xvfb display, selects the normal demo button and launches Hopper with
  its owned Python bridge and the ELF target. Its authenticated Unix socket and
  transport token are temporary and must never be committed.
- Tested: `current_document`, procedure listing, assembly, pseudocode and REA's
  production `analyze_function`, including `main` as caller of `demo_add`.
  The bridge remained responsive after ten seconds. The original timeout did
  not recur after the Python shared library was installed.

## Verified fresh build, 2026-10-10

- `setup.sh --fresh` completed with exit code 0, creating a new Hopper image
  with `--no-cache` and a separate container while preserving existing resources.
- The 35,755,772-byte official DEB passed SHA-256 verification and was installed
  from the read-only bind mount. Hopper reported version 6.4.2, and its launcher
  passed the pinned SHA-256 check. The BuildKit secret-size error did not recur.
- APT update, dependency downloads and installation succeeded within the phase
  limits. The bounded retry recovered a failed `libproxy1v5` download.
- `smoke-test.sh` completed with exit code 0: Hopper startup, bridge access,
  `current_document`, procedure listing, `demo_add` assembly and pseudocode, and
  bridge responsiveness after ten seconds passed. Production REA
  `analyze_function` returned nine assembly entries and pseudocode for `demo_add`.
- The shared build/test run finished in under three minutes, within its
  ten-minute technical limit. Setup removed its temporary build context.

## Restore in a new cloud task

First run the existing REA/Ghidra preparation unchanged. Clone/check out this
repository, then run these **additional** commands:

```bash
cd /workspace/Codex-REA
bash scripts/hopper/setup.sh
bash scripts/hopper/smoke-test.sh
```

The setup reuses the existing named container first, then a local prepared image,
then a verified downloaded DEB. If none exists it downloads only the official
demo from `https://www.hopperapp.com:443/downloader/public/Hopper-6.4.2-Linux-demo.deb`.
Browser User-Agent `Mozilla/5.0` is required: standard curl previously received
HTTP 403. TLS verification and HTTPS redirects remain enabled. Integrity failure
stops setup instead of trusting or overwriting a corrupt existing package.

The Dockerfile installs runtime dependencies before the local DEB, avoiding the
observed APT `--no-download` local-package pathname error. After checking the
DEB's SHA-256, version and architecture, setup creates its own minimal temporary
build context outside the repository. That context contains only the Dockerfile,
its `.dockerignore` and the verified `Hopper-6.4.2-Linux-demo.deb`; the ignore rules
explicitly allow this package. The Dockerfile mounts the DEB read-only with
`RUN --mount=type=bind` during installation. The package is not a BuildKit secret,
so the 500 KiB secret limit does not apply, and the archive is not copied into an
image layer. Setup removes its own temporary context on exit.

The session CA still uses a required BuildKit secret mount. Certificates and
credentials are never copied into the context or image. The installed proprietary
application exists only in a local Docker image. Do not push that image, any
download, runtime state or analysis output to GitHub.
Ubuntu runtime dependency versions follow the supported distribution updates;
the Hopper version, launcher digest, DEB digest and Ubuntu base digest are pinned.

APT update and dependency-download phases use `Acquire::Retries=2`: at most two
retries for a failed download. Each phase has a 179-second timeout and a one-second
kill grace period, bounding it to 180 seconds. Package sources, proxy settings,
TLS verification and package verification remain in effect. APT failures stop
the build; persistent HTTP 503 responses are not ignored. Report the affected
package URLs from the error with any credentials removed.

## Verify a fresh build

Use new image, container and state names to preserve existing working resources.
`--fresh` refuses an existing target image or container and passes `--no-cache`
to Docker. It does not accept reuse as proof of a rebuild. For example, from the
repository root:

```bash
export HOPPER_STATE_DIR=$(mktemp -d /tmp/hopper-restore.XXXXXX)
export HOPPER_CONTAINER_NAME="$(basename "$HOPPER_STATE_DIR")"
export HOPPER_IMAGE_NAME="codex-rea-hopper:$(basename "$HOPPER_STATE_DIR")"
timeout -k 5s 595s bash -c '
  bash scripts/hopper/setup.sh --fresh &&
  bash scripts/hopper/smoke-test.sh
'
```

The shared timeout covers setup and smoke testing, including the five-second
kill grace period, within ten minutes. The smoke test must pass against the new
container, including Hopper startup, its REA bridge and real ELF analysis of
`demo_add` with assembly and pseudocode. Retain the actual exit status and any
failure output; syntax checks alone do not confirm a successful restoration.
Temporary test files belong outside the repository. Clean up only files created
by that test run, and preserve pre-existing containers, images and files.

For subsequent operations:

```bash
bash scripts/hopper/run-rea.sh function /work/harmless.elf demo_add --provider hopper --json
```

Only files inside the host state directory are visible at `/work`. Place other
authorized targets there before analyzing them. `run-rea.sh --mcp` can expose
this Hopper-specific REA instance over stdio; it does not alter the existing
REA/Ghidra registration or set a global provider.

Optional selectors: `HOPPER_CONTAINER_NAME`, `HOPPER_IMAGE_NAME`, `HOPPER_STATE_DIR`,
`HOPPER_REA_ROOT`, `HOPPER_NODE_PATH`, `HOPPER_DEB_PATH`. Defaults match the
historical successful installation.
Keep state/downloads outside the repository. No credentials or license keys are
required. A missing REA/Node/Docker prerequisite stops setup; it is not reinstalled.

## What persists

Committed source scripts and documentation survive a repository checkout. In a
newly provisioned cloud instance, Docker containers/images, installed Ubuntu
packages, temporary bridge sockets, Xvfb/Hopper processes and local downloads are
not supplied by Git. `/workspace` reuse/caching depends on the cloud task's
lifecycle and is not guaranteed by this repository. Existing REA/Node must first
be restored by the current environment setup. Session proxy addresses and CA
files belong to the current task: Docker's existing proxy defaults and fresh
read-only CA mounts are used, without copying credentials or changing networking.

## Proposed cloud settings (not applied)

Keep the current setup and package-manager network preset. Keep `hopperapp.com`
allowed; the effective policy already includes `www.hopperapp.com`. The verified
download had no redirect or additional domain. Docker Hub and Ubuntu package
hosts are provided by the existing package-manager preset. Do not unset proxies
or weaken TLS. Append the two restore/test commands above to the existing setup
script after REA/Node initialization; do not replace that script. No global REA
provider setting or changes to the working Ghidra configuration are needed.

## Validation limits

The original installed reference and its real ELF analysis were tested. A full
fresh-image build and restoration after losing all local state is a separate
test and must not be reported as completed until actually performed with the
current scripts. Official DEB downloads and the base-image pull use 60-second
limits; APT network phases use the 180-second bounds described above. Individual
smoke-test invocations are limited to 59 seconds, and the fresh-build example
adds a shared ten-minute limit. No cloud configuration or repository publication
occurs through these scripts.
