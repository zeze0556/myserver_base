FROM debian

MAINTAINER "--==RIX==--" <zeze0556.duckdns.org@gmail.com>

ADD ./install.sh /install.sh

RUN /install.sh
