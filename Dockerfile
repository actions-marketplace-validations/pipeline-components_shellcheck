FROM alpine:3.8 as build

RUN apk --no-cache add curl=7.61.1-r1 cabal=2.2.0.0-r0 ghc=8.4.3-r0 build-base=0.5-r1 upx=3.94-r0
RUN mkdir -p /app/shellcheck
WORKDIR /app/shellcheck
RUN curl --location  -o ../shellcheck.tar.gz https://github.com/koalaman/shellcheck/archive/v0.6.0.tar.gz
RUN tar --strip=1 -zxvf ../shellcheck.tar.gz
RUN cabal update 
RUN cabal install --jobs  --enable-executable-stripping --enable-optimization=2 --enable-shared --enable-split-sections  --disable-debug-info 

RUN upx -9 /root/.cabal/bin/shellcheck

FROM alpine:3.8
RUN apk --no-cache add libffi=3.2.1-r4 libgmpxx=6.1.2-r1 parallel=20180622-r0
COPY --from=build /root/.cabal/bin/shellcheck /usr/local/bin/shellcheck

WORKDIR /code/
# Build arguments
ARG BUILD_DATE
ARG BUILD_REF

# Labels
LABEL \
    maintainer="Robbert Müller <spam.me@grols.ch>" \
    org.label-schema.description="Shellcheck in a container for gitlab-ci" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Shellcheck" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://pipeline-components.gitlab.io/" \
    org.label-schema.usage="https://gitlab.com/pipeline-components/shellcheck/blob/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://gitlab.com/pipeline-components/shellcheck/" \
    org.label-schema.vendor="Pipeline Components"
