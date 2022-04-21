# Build plakar from golang image
FROM --platform=$BUILDPLATFORM golang:1.18.1-alpine as builder

ARG PLAKAR_VERSION=main
ARG TARGETOS TARGETARCH

# Install build base and upx
RUN apk add --no-cache build-base upx

# Install linux musl cross for arm64 compil 
RUN if [ "$TARGETARCH" = "arm64" ]; then \
 wget https://musl.cc/aarch64-linux-musl-cross.tgz \
 -O /tmp/linux-musl-cross.tgz \
 && cd /usr/bin && tar -xzf /tmp/linux-musl-cross.tgz ; fi

# Build plakar
RUN if [ "$TARGETARCH" = "arm64" ]; then \
 CC=/usr/bin/aarch64-linux-musl-cross/bin/aarch64-linux-musl-gcc; fi \
 && CGO_ENABLED=1 GOOS=$TARGETOS GOARCH=$TARGETARCH CC=$CC \
 go install -v -ldflags='-w -s' \
 github.com/poolpOrg/plakar/cmd/plakar@${PLAKAR_VERSION}

RUN PLAKAR=$(find /go -type f -name plakar) \
 && mv ${PLAKAR} /usr/local/bin/plakar

# Compress plakar
RUN upx /usr/local/bin/plakar

# Build final image
FROM alpine:3.15

ARG PLAKAR_SHA
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="barcus/plakar" \
      org.label-schema.description="Docker image for Plakar" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/barcus/docker-plakar" \
      org.label-schema.url="https://plakar.io" \
      org.label-schema.version=$PLAKAR_SHA \
      org.label-schema.image.authors="barcus@tou.nu"

ARG USER=plakar
ENV HOME /home/$USER

# Copy plakar from builder
COPY --from=builder /usr/local/bin/plakar /usr/bin/

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Add $USER
RUN adduser -D $USER
RUN chown $USER /usr/bin/plakar /docker-entrypoint.sh \
 && chmod +x /docker-entrypoint.sh

USER $USER
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["plakar", "-help"]
