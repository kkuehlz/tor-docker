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
        >> /etc/apt/sources.list.d/tor.list

RUN curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc \
    | gpg --import \
    && gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        tor

COPY torrc /etc/tor/torrc
RUN mkdir /run/tor
RUN mkdir -p /nonexistent/.tor
RUN chown debian-tor:debian-tor /run/tor
RUN chown -R debian-tor:debian-tor /nonexistent
RUN chmod 2700 /run/tor
#USER debian-tor
EXPOSE 9001
ENTRYPOINT ["/usr/bin/tor"]
CMD ["--runasdaemon", "0", "--defaults-torrc",  "/usr/share/tor/tor-service-defaults-torrc", "-f", "/etc/tor/torrc"]