FROM ubuntu:18.04

LABEL maintainer="n.w"

HEALTHCHECK --interval=5m --timeout=20s --start-period=1m \
	CMD if test $( curl -m 10 -s https://api.nordvpn.com/vpn/check/full | jq -r '.["status"]' ) = "Protected" ; then exit 0; else nordvpn connect ${CONNECT} ; exit $?; fi

# https://support.nordvpn.com/Connectivity/Linux/1507838432/How-to-build-the-NordVPN-Docker-image.htm
# Use older stable version
ARG NORDVPN_VERSION=3.7.4

RUN addgroup --system vpn && \
	apt-get update -yqq && \
	apt-get install -yqq curl jq && \
	curl -s https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb --output /tmp/nordrepo.deb && \
    apt-get install -yqq /tmp/nordrepo.deb && \
    apt-get update -yqq && \
    apt-get install -yqq nordvpn=$NORDVPN_VERSION && \
    apt-get remove -yqq nordvpn-release && \
    apt-get autoremove -yqq && \
    apt-get autoclean -yqq && \
    rm -rf \
		/tmp/* \
		/var/cache/apt/archives/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

CMD /usr/bin/start_vpn.sh
COPY start_vpn.sh /usr/bin

# charater device (?)
# This does not create the dir in the final image - to be investigated
# RUN ["/bin/bash", "-c", "mkdir -p /dev/net && [[ -c /dev/net/tun ]] || mknod -m 0666 /dev/net/tun c 10 200"]