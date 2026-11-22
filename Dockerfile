FROM alpine:3.24

# Work directory
WORKDIR /app
VOLUME [ "/app" ]

# Declare environment
ENV TZ=UTC
ENV MAGPIE_RUN_BACKGROUND=1

# User and prompt setup
RUN adduser -D magpie
RUN set -xe \
  && echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /root/.bashrc \
  && echo "alias ll='ls -alF'" >> /root/.bashrc \
  && echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /home/magpie/.bashrc \
  && echo "alias ll='ls -alF'" >> /home/magpie/.bashrc

# Set the build stamp
ADD .touch /etc/BUILT

# Install necessary packages
RUN apk update \
  && apk add --no-cache \
    php85 \
    php85-fpm \
    php85-ctype \
    php85-curl \
    php85-dom \
    php85-fileinfo \
    php85-gd \
    php85-iconv \
    php85-mbstring \
    php85-openssl \
    php85-pcntl \
    php85-pdo \
    php85-pdo_mysql \
    php85-pdo_sqlite \
    php85-pecl-redis \
    php85-phar \
    php85-simplexml \
    php85-tokenizer \
    php85-xml \
    php85-xmlreader \
    php85-xmlwriter \
    php85-zip \
    bash \
    nginx \
    openrc \
    supervisor \
    tzdata

RUN ln -sf /usr/bin/php85 /usr/bin/php

# Harden the PHP installation
RUN echo "expose_php = Off" >> /etc/php85/php.ini

# Mitigation for CVE-2026-109619 / CVE-2026-115560
RUN echo "session.upload_progress.enabled = 0" >> /etc/php85/php.ini

# Make composer available
ADD https://getcomposer.org/download/latest-stable/composer.phar /usr/local/bin/composer.phar
RUN chmod +x /usr/local/bin/composer.phar
RUN ln -s /usr/local/bin/composer.phar /usr/bin/composer

# Use dumb-init
ADD res/dumb-init /bin/dumb-init
RUN chmod +x /bin/dumb-init
ENTRYPOINT [ "/bin/dumb-init", "--" ]

# Install the entrypoint
ADD res/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
CMD [ "/docker-entrypoint.sh" ]

# Forward the logs
RUN set -xe \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log \
  && ln -sf /dev/stderr /var/log/php85/error.log

# Setup web entrance
ADD res/nginx/default.conf /etc/nginx/http.d/default.conf

# Setup background services (supervisord and cron/queue)
ADD res/supervisord.conf /etc/supervisord.conf
ADD res/supervisor/cron.conf /etc/supervisor/conf.d/cron.conf
ADD res/supervisor/magpie-queue.conf /etc/supervisor/conf.d/magpie-queue.conf
ADD res/crontabs/root /etc/crontabs/root

# Other
STOPSIGNAL SIGTERM
EXPOSE 80

