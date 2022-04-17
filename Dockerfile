FROM golang:1.18.1-alpine3.15 as builder

LABEL maintainer="barcus@tou.nu"

ARG BUILD_DATE NAME VCS_REF VERSION
ARG TARGETOS TARGETARCH
ARG UPX_VERSION=3.96
ARG UPX_URL=https://github.com/upx/upx/releases/download
ARG PLAKAR_VERSION=6fd56c6

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$NAME \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/barcus/docker-plakar" \
      org.label-schema.version=$VERSION

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Install go and upx
RUN apk add --no-cache  build-base
RUN wget ${UPX_URL}/v${UPX_VERSION}/upx-${UPX_VERSION}-${TARGETARCH}_${TARGETOS}.tar.xz \
    -O /tmp/upx.tar.xz \
 && tar -xf /tmp/upx.tar.xz -C /usr/local/bin

# Configure Go
#ENV GOROOT /usr/lib/go
#ENV GOPATH /go
#ENV PATH /go/bin:$PATH
#RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# Build and install plakar
WORKDIR /app
COPY . /app
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH \
 go install -ldflags="-w -s" -v github.com/poolpOrg/plakar/cmd/plakar@${PLAKAR_VERSION}

# Run upx on plakar
RUN /usr/local/bin/upx-${UPX_VERSION}-${TARGETARCH}_${TARGETOS}/upx /go/bin/plakar

# Build final image
FROM alpine:3.15
ARG USER=plakar
ENV HOME /home/$USER

COPY --from=builder /go/bin/plakar /usr/bin/
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN adduser -D $USER
RUN chown $USER /usr/bin/plakar /docker-entrypoint.sh \
 && chmod +x /docker-entrypoint.sh

USER $USER

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["plakar"]
