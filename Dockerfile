FROM alpine:3.22.1@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1

COPY pipe /
RUN apk add wget git bash openssh jq curl php php-json php-phar php-openssl php-mbstring php-iconv php-curl php-pcntl php-posix

RUN wget -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/0.4.0/common.sh
RUN curl -sS https://accounts.magento.cloud/cli/installer | php ; cp /root/.magento-cloud/bin/magento-cloud /usr/local/bin

RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
