FROM php:8.4-fpm

# set arguments and environment variables
ARG BUILD_ENV=dev
ARG HOST_UID=1000
ARG HOST_GID=1000
ARG XDEBUG_VERSION=3.4.5

ENV PHP_ENV=$BUILD_ENV
ENV APP_HOME=/var/www/html
ENV USERNAME=www-data
ENV INSIDE_DOCKER_CONTAINER=1
ENV PHP_CS_FIXER_IGNORE_ENV=1
ENV COMPOSER_ALLOW_SUPERUSER 1

# install all the dependencies and enable PHP modules
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
      bash-completion \
      fish \
      procps \
      nano \
      git \
      unzip \
      libicu-dev \
      zlib1g-dev \
      libxml2 \
      libxml2-dev \
      libreadline-dev \
      supervisor \
      cron \
      sudo \
      libzip-dev \
      wget \
      librabbitmq-dev \
      debsecan \
      xalan \
    && pecl install amqp \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure intl \
    && yes '' | pecl install -o -f redis && docker-php-ext-enable redis \
    && docker-php-ext-install \
      pdo_mysql \
      sockets \
      intl \
      opcache \
      zip \
    && docker-php-ext-enable amqp \
    && apt-get install --no-install-recommends -y \
        $(debsecan --suite bookworm --format packages --only-fixed) \
    && rm -rf /tmp/* \
    && rm -rf /var/list/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# prepare application folder and set permissions
RUN mkdir -p $APP_HOME/public && \
    mkdir -p /home/$USERNAME && chown $USERNAME:$USERNAME /home/$USERNAME \
    && usermod -o -u $HOST_UID $USERNAME -d /home/$USERNAME \
    && groupmod -o -g $HOST_GID $USERNAME \
    && chown -R ${USERNAME}:${USERNAME} $APP_HOME

# copy configuration files
COPY ./docker/config/$BUILD_ENV/www.conf /usr/local/etc/php-fpm.d/www.conf

# xdebug installation for dev/test environment
COPY ./docker/config/$BUILD_ENV/xdebug.ini /tmp/xdebug.ini
RUN set -eux; \
  if [ "$BUILD_ENV" = "dev" ] || [ "$BUILD_ENV" = "test" ]; then \
    pecl install xdebug-"$XDEBUG_VERSION"; \
    mv /tmp/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini; \
  else \
    rm -f /tmp/xdebug.ini; \
  fi

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# set working directory
WORKDIR $APP_HOME

# switch to non-root user
USER ${USERNAME}

#copy application files
COPY --chown=${USERNAME}:${USERNAME} . $APP_HOME/

# install PHP dependencies with Composer
RUN if [ "$BUILD_ENV" = "dev" ] || [ "$BUILD_ENV" = "test" ]; then \
      COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader --no-interaction --no-progress; \
    else \
      export APP_ENV=$BUILD_ENV && COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader --no-interaction --no-progress --no-dev; \
    fi

USER ${USERNAME}