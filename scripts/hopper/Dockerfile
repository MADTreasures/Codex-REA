# Official Ubuntu image used by the successful reference installation.
FROM ubuntu:24.04@sha256:534baea6a22c03a63003dbc8dbe78fe34bc0d7e595d9a9dc9834884ff530eb55
ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=secret,id=system_ca,required=true \
    --mount=type=secret,id=hopper_deb,required=true \
    set -eu; \
    packages='xvfb xauth python3 libpython3.12t64 libx11-6 libxtst6 qt6-qpa-plugins libxcb-cursor0 libatomic1 fonts-dejavu-core xdg-utils desktop-file-utils libbsd0 libqt6gui6t64 libqt6xml6t64 libqt6printsupport6t64 libqt6network6t64 libgcrypt20 libselinux1'; \
    timeout -k 1s 60s apt-get -o Acquire::Retries=0 -o Acquire::http::Timeout=20 -o Acquire::https::Timeout=20 -o Acquire::https::CaInfo=/run/secrets/system_ca update; \
    timeout -k 1s 60s apt-get -o Acquire::Retries=0 -o Acquire::http::Timeout=20 -o Acquire::https::Timeout=20 -o Acquire::https::CaInfo=/run/secrets/system_ca --download-only --no-install-recommends install -y $packages; \
    apt-get --no-download --no-install-recommends install -y $packages; \
    dpkg -i /run/secrets/hopper_deb; \
    test "$(dpkg-query -W -f='${Version}' hopper)" = 6.4.2; \
    printf '%s  %s\n' 0294ced141cc373468ee22d8343e7dac41980cb05a937994ca81c9f09afe7ded /opt/hopper/bin/Hopper | sha256sum -c -; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb
ENV REA_ANALYSIS_PROVIDER=hopper HOPPER_LAUNCHER_PATH=/opt/hopper/bin/Hopper
WORKDIR /work
CMD ["sleep", "infinity"]
