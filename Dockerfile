FROM ubuntu:xenial AS stage0

ARG erlang_version=R16B03

WORKDIR /build
COPY evm evm
COPY riak riak

ENV PATH=/build/bin:$PATH

RUN apt-get update -yq
RUN apt-get install -yqq wget build-essential

ADD https://www.erlang.org/download/otp_src_${erlang_version}.tar.gz /root/.evm/erlang_tars/

RUN cd evm && ./install

RUN apt-get install -yqq --no-install-recommends \
        libc-dev \
        libkrb5-dev \
        libncurses-dev \
        libpam-dev \
        libssl-dev

COPY bin bin
RUN in-evm evm install "$erlang_version" -y --with-ssl=/usr
RUN in-evm evm default "$erlang_version"

RUN apt-get install -yqq git ca-certificates

WORKDIR /build/riak
RUN in-evm make rel

FROM ubuntu:xenial AS stage1

RUN apt-get update -yq && \
    apt-get install -yqq --no-install-recommends \
        ca-certificates \
        curl \
        libkrb5-3 \
        runit \
    && \
    apt-get clean -yq

ENV SVDIR=/var/service

RUN mkdir -p /var/lib/riak
COPY --from=stage0 /build/riak/rel/riak /usr/local/riak
COPY service /var/service
COPY riak.conf /usr/local/riak/etc/
COPY riak.conf.vars /usr/local/riak/
COPY docker-entrypoint.sh /

ENV PATH=/usr/local/riak/bin:$PATH

EXPOSE 8098/tcp 8087/tcp

WORKDIR /usr/local/riak
STOPSIGNAL TERM
ENTRYPOINT ["/docker-entrypoint.sh"]

