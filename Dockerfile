# Build plakar from golang image
FROM --platform=$BUILDPLATFORM golang:1.18.1-alpine as builder

LABEL maintainer="barcus@tou.nu"

ARG PLAKAR_VERSION=6fd56c6
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
CMD ["plakar"]
