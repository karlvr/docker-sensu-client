#!/bin/bash -eu

configured_rabbitmq=0
configured_client=0

if [ ! -f /etc/sensu/conf.d/rabbitmq.json ]; then
	if [ ! -z "${RABBITMQ_PASSWORD_FILE:-}" ]; then
		echo "--> Reading RABBITMQ_PASSWORD from $RABBITMQ_PASSWORD_FILE" >&2
		RABBITMQ_PASSWORD=$(cat $RABBITMQ_PASSWORD_FILE)
	fi

	configured_rabbitmq=1
	echo "--> Creating RabbitMQ configuration in /etc/sensu/conf.d/rabbitmq.json" >&2

	cat <<EOF > /etc/sensu/conf.d/rabbitmq.json
{
  "rabbitmq": {
    "host": "$RABBITMQ_HOST",
    "port": $RABBITMQ_PORT,
    "vhost": "$RABBITMQ_VHOST",
    "user": "$RABBITMQ_USER",
    "password": "$RABBITMQ_PASSWORD"
  }
}
EOF
else
	echo "--> Using existing RabbitMQ configuration in /etc/sensu/conf.d/rabbitmq.json" >&2
fi

if [ ! -z "$RABBITMQ_SSL_CERT_CHAIN_FILE" ]; then
	echo "--> Creating RabbitMQ SSL configuration in /etc/sensu/conf.d/rabbitmq-ssl.json" >&2
	cat <<EOF > /etc/sensu/conf.d/rabbitmq-ssl.json
{
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "$RABBITMQ_SSL_CERT_CHAIN_FILE",
      "private_key_file": "$RABBITMQ_SSL_PRIVATE_KEY_FILE"
    }
  }
}
EOF
fi

if [ ! -f /etc/sensu/conf.d/client.json ]; then
	echo "--> Creating Sensu Client configuration in /etc/sensu/conf.d/client.json" >&2
	configured_client=1

	subs=
	for sub in ${SENSU_CLIENT_SUBSCRIPTIONS:-}
	do
		if [ -z "$subs" ]; then
			subs="\"$sub\""
		else
			subs="$subs, \"$sub\""
		fi
	done
	cat <<EOF > /etc/sensu/conf.d/client.json
{
  "client": {
    "name": "$SENSU_CLIENT_NAME",
    "address": "$SENSU_CLIENT_ADDRESS",
    "subscriptions": [ $subs ]
  }
}
EOF
else
	echo "--> Using existing Sensu Client configuration in /etc/sensu/conf.d/client.json" >&2
fi

if [ "$*" == "sensu-client" ]; then
	if [ "$configured_rabbitmq" == "1" ]; then
		if [ -z "$RABBITMQ_HOST" ]; then
			echo "RABBITMQ_HOST environment variable is missing" >&2
			exit 1
		fi
		if [ -z "$RABBITMQ_PASSWORD" ]; then
			echo "RABBITMQ_PASSWORD environment variable is missing" >&2
			exit 1
		fi
	fi
	if [ "$configured_client" == "1" ]; then
		if [ -z "$SENSU_CLIENT_NAME" ]; then
			echo "SENSU_CLIENT_NAME environment variable is missing" >&2
			exit 1
		fi
	fi

	/opt/sensu/bin/sensu-client
else
	exec "$@"
fi
