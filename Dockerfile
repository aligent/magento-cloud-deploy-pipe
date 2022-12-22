FROM alpine

COPY pipe /
RUN apk add wget git bash openssh jq curl php php-json php-phar php-openssl php-mbstring php-iconv php-curl php-pcntl php-posix

RUN wget -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/0.4.0/common.sh
RUN curl -sS https://accounts.magento.cloud/cli/installer | php ; cp /root/.magento-cloud/bin/magento-cloud /usr/local/bin

RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
