#!/bin/bash -eu

#
# RabbitMQ configuration
#

if [ ! -z "${RABBITMQ_PASSWORD_FILE:-}" ]; then
	echo "--> Reading RABBITMQ_PASSWORD from $RABBITMQ_PASSWORD_FILE" >&2
	RABBITMQ_PASSWORD=$(cat $RABBITMQ_PASSWORD_FILE)
fi

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

if [ ! -z "${RABBITMQ_SSL_CERT_CHAIN_FILE:-}" ]; then
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

#
# Client configuration
#

echo "--> Creating Sensu Client configuration in /etc/sensu/conf.d/client.json" >&2

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

if [ "$*" == "sensu-client" ]; then
	if [ -z "$RABBITMQ_HOST" ]; then
		echo "RABBITMQ_HOST environment variable is missing" >&2
		exit 1
	fi
	if [ -z "$RABBITMQ_PASSWORD" ]; then
		echo "RABBITMQ_PASSWORD environment variable is missing" >&2
		exit 1
	fi
	if [ -z "$SENSU_CLIENT_NAME" ]; then
		echo "SENSU_CLIENT_NAME environment variable is missing" >&2
		exit 1
	fi

	/opt/sensu/bin/sensu-client
else
	exec "$@"
fi
