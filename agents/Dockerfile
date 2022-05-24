# The base image for this container
ARG IMAGE

FROM $IMAGE

# The target(s) that the worker will build for.
ARG TARGET

WORKDIR /buildkite

# Switch USER back to root to install common packages.
USER root

ENV BUILD_TIMESTAMP 20210929

# Target specific dependencies.
COPY install-target-deps.sh /buildkite/install-target-deps.sh
RUN sh install-target-deps.sh $TARGET

COPY baseboards/*.exp /usr/share/dejagnu/baseboards/
COPY config/*.exp /usr/share/dejagnu/config/
COPY pipeline.sh /buildkite/pipeline.sh
COPY pipeline-hooks/* /buildkite/pipeline/hooks/
RUN chmod +x /buildkite/pipeline/hooks/*

RUN chown -R buildkite-agent:buildkite-agent /buildkite
USER buildkite-agent

CMD ["/usr/bin/buildkite-agent", "start"]
