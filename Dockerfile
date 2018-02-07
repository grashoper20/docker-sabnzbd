FROM alpine:latest
MAINTAINER Cameron Meindl <cmeindl@gmail.com>
ARG GITTAG=2.3.3
ARG PAR2TAG=v0.7.4

COPY requirements.txt /requirements.txt
COPY start.sh /start.sh
RUN buildDeps="gcc g++ git mercurial make automake autoconf python-dev openssl-dev libffi-dev musl-dev" \
  && apk --update add $buildDeps \
  && apk add \
    python \
    py2-pip py2-openssl \
    ffmpeg-libs \
    ffmpeg \
    unrar \
    openssl \
    ca-certificates \
    p7zip \
    libgomp \
&& pip install --upgrade pip --no-cache-dir \
&& pip install -r /requirements.txt --no-cache-dir \
&& chmod +x /start.sh \
&& git clone --depth 1 --branch ${PAR2TAG} https://github.com/Parchive/par2cmdline.git \
  && cd /par2cmdline \
  && sh automake.sh \
  && ./configure \
  && make \
  && make install \
  && cd / \
  && rm -rf par2cmdline \
&& hg clone https://bitbucket.org/dual75/yenc \
  && cd /yenc \
  && python setup.py build \
  && python setup.py install \
  && cd / \
  && rm -rf /yenc \
&& git clone --depth 1 --branch ${GITTAG} https://github.com/sabnzbd/sabnzbd.git \
&& apk del $buildDeps \
&& rm -rf \
    /var/cache/apk/* \
    /sabnzbd/.git \
    /tmp/*

EXPOSE 8080 9090

VOLUME ["/config", "/data"]

WORKDIR /sabnzbd

CMD ["/start.sh"]
