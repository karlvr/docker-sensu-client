# Sensu Client for Docker

Run Sensu Client in Docker in order to run checks that can only be run from within your Docker network.

## Configuration

The `docker-compose.yml` file shows an example of configuring this image as a service, including the environment
variables that are available and creating Docker secrets for the RabbitMQ certificate and private key (which you must provide).

### Environment variables

| Name | Default | Description |
| ---- | ------- | ----------- |
| SENSU_CLIENT_NAME | - | The name of the Sensu client. This is the name that the client appears as in the Sensu reports |
| SENSU_CLIENT_ADDRESS | `unknown` | The address of the client. Defaults to `unknown` as the Sensu client running in Docker is generally unaccessible from the outside world. |
| SENSU_CLIENT_SUBSCRIPTIONS | - | A space-separated list of subscriptions that you'd like the Sensu client to subscribe to. |
| RABBITMQ_HOST | - | The hostname or address of the RabbitMQ server. |
| RABBITMQ_PORT | `5671` | The port to connect to the RabbitMQ server. |
| RABBITMQ_VHOST | `/sensu` | The vhost to use on the RabbitMQ server. |
| RABBITMQ_USER | `sensu` | The username to use to connect to the RabbitMQ server. |
| RABBITMQ_PASSWORD | - | The password to use to connect to the RabbitMQ server. |
| RABBITMQ_PASSWORD_FILE | - | The file to read the password for the RabbitMQ server from. Useful if you'd like to use Docker secrets to store the password. |
| RABBITMQ_SSL_CERT_CHAIN_FILE | - | The file path to the RabbitMQ SSL certificate chain file. Must be accessible inside the Docker container. Suggest using Docker secrets to provide this file—see the `docker-compose.yml` example. |
| RABBITMQ_SSL_PRIVATE_KEY_FILE | - | The file path to the RabbitMQ SSL certificate private key file. Must be accessible inside the Docker container. Suggest using Docker secrets to provide this file—see the `docker-compose.yml` example. |

## Building

```
docker-compose build
```

## Running

```
docker-compose up
```

## Running in Swarm

Either create the service definition in your own stack file, or launch as a separate stack:

```
docker stack deploy -c docker-compose.yml monitoring
```
