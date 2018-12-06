FROM byjg/php:7.1-fpm-nginx

WORKDIR /var/www/html

ENV OPENCART_VER 3.0.2.0
ENV OPENCART_MD5 41c7e7ec49d389fc4c2204efb40289e6
ENV OPENCART_URL https://github.com/opencart/opencart/archive/${OPENCART_VER}.tar.gz
ENV OPENCART_FILE opencart.tar.gz
ENV OPENCART_DATA /data

COPY assets/default.conf /etc/nginx/conf.d
COPY assets/patch /tmp/patch
COPY assets/cmd.sh /cmd.sh

RUN set -xe \
    && apk add --no-cache wget tar rsync \
    && wget ${OPENCART_URL} -O ${OPENCART_FILE} \
    && echo "${OPENCART_MD5}  ${OPENCART_FILE}" | md5sum -c \
    && tar xzf ${OPENCART_FILE} --strip 2 --wildcards '*/upload/' \
    && patch -p1 < /tmp/patch \
    && mkdir ${OPENCART_DATA}/ \
    && touch ${OPENCART_DATA}/config.php \
    && ln -s ${OPENCART_DATA}/config.php config.php \
    && touch ${OPENCART_DATA}/admin-config.php \
    && ln -s ${OPENCART_DATA}/admin-config.php admin/config.php \
    && rm -rf install \
    && rm ${OPENCART_FILE} \
    && chown -R nobody:nobody /var/www \
    && chown -R nobody:nobody ${OPENCART_DATA} \
    && mkdir /opt \
    && mv image/ /opt/image

CMD [ "/cmd.sh" ]
