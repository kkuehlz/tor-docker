FROM debian:stretch
Maintainer Kevin Kuehler <keur@ocf.berkeley.edu>

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        libcurl3-gnutls \
        curl \
        gnupg2

# https://2019.www.torproject.org/docs/debian.html.en
RUN echo "deb https://deb.torproject.org/torproject.org stretch main" \
        >> /etc/apt/sources.list.d/tor.list \
    && echo "deb-src https://deb.torproject.org/torproject.org stretch main" \
        >> /etc/apt/sources.list.d/tor.list \
    && curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc \
    | gpg --import \
    && gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        tor

COPY torrc /etc/tor/torrc
COPY data /data/tor

RUN mkdir -p /run/tor /data/tor \
    && chown -R debian-tor:debian-tor /run/tor \
    && mkdir -p /nonexistent/.tor \
    && chown -R debian-tor:debian-tor /nonexistent \
    && chown -R debian-tor:debian-tor /var/lib/tor \
    && chmod 2700 /run/tor \
    && chown -R debian-tor:debian-tor /data/tor \
    && chmod 700 /data/tor

USER debian-tor
EXPOSE 9001
ENTRYPOINT ["/usr/bin/tor"]
CMD ["--runasdaemon", "0", "-f", "/etc/tor/torrc"]
