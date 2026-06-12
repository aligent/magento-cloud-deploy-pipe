FROM alpine:3.24.0@sha256:a2d49ea686c2adfe3c992e47dc3b5e7fa6e6b5055609400dc2acaeb241c829f4

COPY pipe /
RUN apk add wget git bash openssh jq curl php php-json php-phar php-openssl php-mbstring php-iconv php-curl php-pcntl php-posix

RUN wget -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/0.4.0/common.sh
RUN curl -sS https://accounts.magento.cloud/cli/installer | php ; cp /root/.magento-cloud/bin/magento-cloud /usr/local/bin

RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
