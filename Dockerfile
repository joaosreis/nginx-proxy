FROM nginx:1.13
LABEL maintainer="Jason Wilder mail@jasonwilder.com"
ARG ARCHITECTURE=amd64

# Install wget and install/updates certificates
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
        ca-certificates \
        wget \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
    && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

ENV FOREGO_VERSION 0.16.1

# Install Forego
RUN wget https://github.com/joaosreis/forego/releases/download/v$FOREGO_VERSION/forego-linux-$ARCHITECTURE-$FOREGO_VERSION.tar.gz \
    && tar -C /usr/local/bin -xvzf forego-linux-$ARCHITECTURE-$FOREGO_VERSION.tar.gz \
    && rm /forego-linux-$ARCHITECTURE-$FOREGO_VERSION.tar.gz

ENV DOCKER_GEN_VERSION 0.7.3

RUN wget https://github.com/joaosreis/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-$ARCHITECTURE-$DOCKER_GEN_VERSION.tar.gz \
    && tar -C /usr/local/bin -xvzf docker-gen-linux-$ARCHITECTURE-$DOCKER_GEN_VERSION.tar.gz \
    && rm /docker-gen-linux-$ARCHITECTURE-$DOCKER_GEN_VERSION.tar.gz

COPY network_internal.conf /etc/nginx/

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
