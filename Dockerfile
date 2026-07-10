ARG ALPINE_VERSION

FROM busybox:latest AS validator
ARG ALPINE_VERSION
RUN : "${ALPINE_VERSION:?ALPINE_VERSION build argument is required}" && touch /validated

FROM alpine:${ALPINE_VERSION}
COPY --from=validator /validated /tmp/.validated

COPY pipe /
RUN apk update && apk add --no-cache \
    wget \
    git \
    bash \
    openssh \
    jq \
    curl \
    php \
    php-json \
    php-phar \
    php-openssl \
    php-mbstring \
    php-iconv \
    php-curl \
    php-pcntl \
    php-posix \
    && apk upgrade --no-cache

RUN wget -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/0.4.0/common.sh
RUN curl -sS https://accounts.magento.cloud/cli/installer | php ; cp /root/.magento-cloud/bin/magento-cloud /usr/local/bin

RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
