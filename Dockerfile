## stage0
## Build the Riak release.
FROM ubuntu:xenial AS stage0

# Add wget and build packages early so they're cached before sources or
# arguments change. Git is required so that rebar can fetch
# depdendencies.
RUN apt-get update -yq
RUN apt-get install -yqq \
    build-essential \
    ca-certificates \
    git \
    libc-dev \
    libkrb5-dev \
    libncurses-dev \
    libpam-dev \
    libssl-dev \
    wget

# Add with-evm to PATH.
ENV PATH=/build/bin:$PATH

# Set Erlang version.
ARG erlang_version=R16B03

# Fetch Erlang via ADD instead of evm so that it can live in a cache
# layer.
ADD https://www.erlang.org/download/otp_src_${erlang_version}.tar.gz /root/.evm/erlang_tars/

# Copy riak, evm, and bin directories.
WORKDIR /build
COPY evm evm
COPY riak riak
COPY bin bin

# Install evm.
RUN cd evm && ./install

# Install the configured Erlang version.
RUN in-evm evm install "$erlang_version" -y --with-ssl=/usr
RUN in-evm evm default "$erlang_version"

# Build the riak release.
WORKDIR /build/riak
RUN in-evm make rel


## stage1
## Build a final image containing just the Riak release (including the
## Erlang runtime).
FROM ubuntu:xenial AS stage1

# Install runtime dependencies.
RUN apt-get update -yq && \
    apt-get install -yqq --no-install-recommends \
        ca-certificates \
        curl \
        libkrb5-3 \
        runit \
    && \
    apt-get clean -yq

# Set service directory.
ENV SVDIR=/var/service

# Create Riak data and log directories.
RUN mkdir -p /var/lib/riak /var/log/riak

# Copy Riak release, runit service, config files, and entrypoint.
COPY --from=stage0 /build/riak/rel/riak /usr/local/riak
COPY riak/LICENSE /usr/local/riak/LICENSE
COPY service /var/service
COPY riak.conf /usr/local/riak/etc/
COPY advanced.config /usr/local/riak/etc/
COPY riak.conf.vars /usr/local/riak/
COPY docker-entrypoint.sh /

# Add Riak release's bin directory to PATH.
ENV PATH=/usr/local/riak/bin:$PATH

# Expose HTTP, Protobuf, epmd, and handoff ports.
# Erlang distribution ports are not exposed here since the ports won't
# necessarily match up when publishing ports.
EXPOSE 9080/tcp 8098/tcp 8087/tcp 4369/tcp 8099/tcp

# Set working directory to the release.
WORKDIR /usr/local/riak

# Set stop signal and entrypoint.
STOPSIGNAL TERM
ENTRYPOINT ["/docker-entrypoint.sh"]
