#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
case "${1:-}" in
    ''|--reuse-only|--fresh) ;;
    *) task_error 'Usage: setup.sh [--reuse-only|--fresh]' ;;
esac
task_docker info >/dev/null || task_error 'Managed Docker daemon unavailable; recover the cloud environment. No daemon/configuration changes were made.'
[[ $(uname -m) == x86_64 ]] || task_error 'The verified Hopper package requires amd64.'
[[ -f "$task_rea/package.json" && -x "$task_node" ]] || task_error 'Existing REA/Node installation missing; this script does not install or update them.'
"$task_node" -e 'const p=JSON.parse(require("fs").readFileSync(process.argv[1])); if(p.version!=="6.1.0") throw Error("Expected existing REA 6.1.0");' "$task_rea/package.json"
# Fresh tests must never start or overwrite an existing target resource.
task_build_flags=()
if [[ "${1:-}" == --fresh ]]; then
    if task_docker container inspect "$task_container" >/dev/null 2>&1; then
        task_error 'Fresh build requires an unused HOPPER_CONTAINER_NAME; existing container was not changed.'
    fi
    if task_docker image inspect "$task_image" >/dev/null 2>&1; then
        task_error 'Fresh build requires an unused HOPPER_IMAGE_NAME; existing image was not changed.'
    fi
    task_build_flags+=(--no-cache)
fi
# Preserve and reuse an existing container, including its read-only REA mounts.
if task_docker container inspect "$task_container" >/dev/null 2>&1; then
    task_docker start "$task_container" >/dev/null
    task_docker exec "$task_container" python3 -c 'import ctypes,subprocess,json; from pathlib import Path; assert subprocess.check_output(["dpkg-query","-W","-f=${Version}","hopper"],text=True)=="6.4.2"; ctypes.CDLL("libpython3.12.so.1.0"); assert "not found" not in subprocess.check_output(["ldd","/opt/hopper/bin/Hopper"],text=True); assert json.loads(Path("/opt/rea/package.json").read_text())["version"]=="6.1.0"'
    printf 'Reused %s. Run scripts/hopper/smoke-test.sh to verify the bridge.\n' "$task_container"
    exit 0
fi
[[ "${1:-}" != --reuse-only ]] || task_error 'Existing container missing; reuse-only mode does not download, build or create anything.'
mkdir -p "$task_state"
task_deb=${HOPPER_DEB_PATH:-/workspace/work/hopper-download-check/Hopper-6.4.2-Linux-demo.deb}
task_digest=7fb92d7bc94edbbf794e348a9ab2f9606b96578529985e884dff04a63e42b2c7
task_verify_deb() {
    [[ -f "$1" ]] && [[ $(sha256sum "$1" | cut -d ' ' -f 1) == "$task_digest" ]]
}
task_temp=''
task_context=''
task_cleanup() {
    if [[ -n "$task_temp" ]]; then rm -f -- "$task_temp"; fi
    if [[ -n "$task_context" ]]; then rm -rf -- "$task_context"; fi
}
trap task_cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
if ! task_docker image inspect "$task_image" >/dev/null 2>&1; then
    if [[ -f "$task_deb" ]]; then
        task_verify_deb "$task_deb" || task_error 'Existing Hopper archive failed integrity verification; it was not overwritten.'
    else
        task_deb="$task_state/Hopper-6.4.2-Linux-demo.deb"
        if [[ -f "$task_deb" ]]; then
            task_verify_deb "$task_deb" || task_error 'Cached Hopper archive failed integrity verification.'
        else
            command -v curl >/dev/null || task_error 'curl is required to retrieve the official demo.'
            task_temp=$(mktemp "$task_state/hopper-download.XXXXXX")
            curl --proto '=https' --proto-redir '=https' --location --max-redirs 5 \
                --connect-timeout 15 --max-time 60 --max-filesize 100000000 \
                --user-agent 'Mozilla/5.0' --fail --silent --show-error \
                --output "$task_temp" \
                'https://www.hopperapp.com:443/downloader/public/Hopper-6.4.2-Linux-demo.deb'
            task_verify_deb "$task_temp" || task_error 'Official download failed the pinned SHA-256 verification.'
            mv -- "$task_temp" "$task_deb"
            task_temp=''
        fi
    fi
    [[ $(dpkg-deb --field "$task_deb" Version) == 6.4.2 ]] || task_error 'Wrong Hopper package version.'
    [[ $(dpkg-deb --field "$task_deb" Architecture) == amd64 ]] || task_error 'Wrong Hopper package architecture.'
    timeout -k 1s 59s env -u DOCKER_HOST -u DOCKER_CONTEXT -u DOCKER_TLS -u DOCKER_TLS_VERIFY -u DOCKER_CERT_PATH \
        docker --host=unix:///var/run/docker.sock pull ubuntu:24.04@sha256:534baea6a22c03a63003dbc8dbe78fe34bc0d7e595d9a9dc9834884ff530eb55
    # Copy only build inputs to our own temporary context, never certificates.
    # A DEB is too large for a BuildKit secret; the Dockerfile binds it read-only.
    task_context=$(mktemp -d /tmp/codex-hopper-build.XXXXXX)
    cp -- "$task_repo/scripts/hopper/Dockerfile" "$task_repo/scripts/hopper/.dockerignore" "$task_context/"
    cp -- "$task_deb" "$task_context/Hopper-6.4.2-Linux-demo.deb"
    task_verify_deb "$task_context/Hopper-6.4.2-Linux-demo.deb" || task_error 'Temporary build archive failed integrity verification.'
    DOCKER_BUILDKIT=1 task_docker build --pull=false "${task_build_flags[@]}" \
        --secret "id=system_ca,src=/etc/ssl/certs/ca-certificates.crt" \
        --tag "$task_image" "$task_context"
    task_cleanup
    task_context=''
fi
[[ -f "${CODEX_PROXY_CERT:-}" ]] || task_error 'Session proxy CA missing; no TLS verification bypass is permitted.'
# Match the tested Ubuntu container; REA and Node remain read-only host mounts.
task_docker run --detach --pull=never --init --name "$task_container" \
    --workdir /work \
    --mount "type=bind,src=$task_rea,dst=/opt/rea,readonly" \
    --mount "type=bind,src=$task_node,dst=/usr/local/bin/node,readonly" \
    --mount "type=bind,src=$task_state,dst=/work" \
    --mount "type=bind,src=$CODEX_PROXY_CERT,dst=/run/proxy-ca.pem,readonly" \
    --mount 'type=bind,src=/etc/ssl/certs/ca-certificates.crt,dst=/run/ca-bundle.pem,readonly' \
    -e NODE_EXTRA_CA_CERTS=/run/proxy-ca.pem "$task_image" >/dev/null
printf 'Prepared %s. Run scripts/hopper/smoke-test.sh.\n' "$task_container"
