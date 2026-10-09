# syntax=docker/dockerfile:1
# Official Ubuntu 24.04 image observed on 2026-10-09; no Hopper binary is bundled.
FROM ubuntu:24.04@sha256:534baea6a22c03a63003dbc8dbe78fe34bc0d7e595d9a9dc9834884ff530eb55
RUN --mount=type=secret,id=system_ca,required=true \
    apt-get -o Acquire::https::CaInfo=/run/secrets/system_ca update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::https::CaInfo=/run/secrets/system_ca \
      install -y --no-install-recommends xvfb xauth x11-utils python3 \
      libx11-6 libxtst6 libxcb-cursor0 libqt6core5compat6 libqt6svg6 \
      libqt6widgets6 libqt6xml6 libqt6network6 libqt6printsupport6 qt6-qpa-plugins \
      libpython3.12 binutils file ca-certificates && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /analysis
# Dependencies are a preflight candidate until dpkg/ldd and REA/Hopper succeed.
CMD ["bash"]
