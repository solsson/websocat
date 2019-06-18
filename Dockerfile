FROM rust:1.35.0-slim-stretch@sha256:4283f6c4e0a285316f970d59d04888780db838456d4c28f13146f7431bc7e2f1

WORKDIR /usr/src/app

COPY . .

RUN set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  runDeps='curl ca-certificates socat'; \
  buildDeps='libssl-dev pkg-config'; \
  apt-get update && apt-get install -y $runDeps $buildDeps --no-install-recommends; \
  \
  export OPENSSL_LIB_DIR=/usr/include/openssl; \
  cargo build --release --features=ssl; \
  \
  apt-get purge -y --auto-remove $buildDeps; \
  rm -rf /var/lib/apt/lists/*; \
  rm -rf /var/log/dpkg.log /var/log/alternatives.log /var/log/apt /etc/ssl/certs /root/.gnupg

ENTRYPOINT [ "./target/release/websocat" ]

FROM debian:stretch-slim@sha256:9490c476443a3869e39c2897fa66c91daf5dcbbfca53c976dac7bbdc45775b28

RUN set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  runDeps='libssl1.1'; \
  apt-get update && apt-get install -y $runDeps --no-install-recommends; \
  \
  rm -rf /var/lib/apt/lists/*; \
  rm -rf /var/log/dpkg.log /var/log/alternatives.log /var/log/apt /etc/ssl/certs /root/.gnupg

COPY --from=0 /usr/src/app/target/release/websocat /usr/local/bin/websocat

ENTRYPOINT [ "websocat" ]
