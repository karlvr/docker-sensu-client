FROM ubuntu:18.04

RUN groupadd --gid 3030 sensu && useradd --home-dir /var/run/sensu --no-create-home --shell /usr/sbin/nologin --uid 3030 --gid 3030 sensu && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		apt-transport-https \
		ca-certificates \
		curl \
		gpg-agent \
		software-properties-common \
	&& \
	curl -fsSL https://sensu.global.ssl.fastly.net/apt/pubkey.gpg | apt-key add - && \
	echo "deb https://sensu.global.ssl.fastly.net/apt $(lsb_release -cs) main" > /etc/apt/sources.list.d/sensu.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		sensu \
	&& \
	apt-get clean

ENV SENSU_CLIENT_NAME ""
ENV SENSU_CLIENT_ADDRESS "unknown"
ENV SENSU_CLIENT_SUBSCRIPTIONS ""
ENV RABBITMQ_HOST ""
ENV RABBITMQ_PORT "5671"
ENV RABBITMQ_VHOST "/sensu"
ENV RABBITMQ_USER "sensu"
ENV RABBITMQ_PASSWORD ""
ENV RABBITMQ_PASSWORD_FILE ""
ENV RABBITMQ_SSL_CERT_CHAIN_FILE ""
ENV RABBITMQ_SSL_PRIVATE_KEY_FILE ""

COPY ./docker-entrypoint.sh /
USER 3030
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sensu-client"]
