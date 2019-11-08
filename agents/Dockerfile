# The base image for this container
ARG IMAGE

FROM $IMAGE:18.04

# The target(s) that the worker will build for.
ARG TARGET

WORKDIR /buildkite

# Switch USER back to root to install common packages.
USER root

ENV BUILD_TIMESTAMP 20191108

# Target specific dependencies.
COPY install-target-deps.sh /buildkite/install-target-deps.sh
RUN bash install-target-deps.sh $TARGET

COPY baseboards/*.exp /usr/share/dejagnu/baseboards/
COPY config/*.exp /usr/share/dejagnu/config/
COPY pipeline.sh /buildkite/pipeline.sh

RUN chown -R buildkite-agent:buildkite-agent /buildkite
USER buildkite-agent

CMD ["/usr/bin/buildkite-agent", "start"]
