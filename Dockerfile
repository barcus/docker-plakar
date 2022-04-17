FROM alpine:3.15 as builder

LABEL maintainer="barcus@tou.nu"

ARG BUILD_DATE
ARG NAME
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$NAME \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/barcus/docker-plakar" \
      org.label-schema.version=$VERSION

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Install go and upx
RUN apk add --no-cache go upx

# Configure Go
ENV GOOS linux
ENV GOARCH amd64
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

WORKDIR /app
COPY . /app
RUN go install -ldflags="-w -s" -v github.com/poolpOrg/plakar/cmd/plakar@6fd56c6
RUN upx /go/bin/plakar

FROM alpine:3.8
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
