include .env

DOCKER_COMPOSE := docker compose -f compose.yaml
PHP_USER := -u www-data

.PHONY: build start stop restart down ssh logs ssh-nginx composer-install exec-bash

build:
	$(DOCKER_COMPOSE) build

start:
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) stop

restart: stop start

down:
	$(DOCKER_COMPOSE) down

ssh:
	$(DOCKER_COMPOSE) exec $(PHP_USER) symfony bash

logs:
	$(DOCKER_COMPOSE) logs -f

ssh-nginx:
	$(DOCKER_COMPOSE) exec nginx /bin/sh

composer-install: start
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader"

exec-bash:
	$(DOCKER_COMPOSE) exec $(PHP_USER) symfony bash -c "$(cmd)"