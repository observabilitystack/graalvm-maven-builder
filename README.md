# 🏗 GraalVM Maven builder base image

A base image for multi-phase Docker builds targeting native Spring Boot 3.x
images running on Alpine on both `amd64` and `aarch64` architectures.

> This image is the builder image for Java applications in the
> [observabilitystack](https://github.com/observabilitystack)
> and [ping7io](https://github.com/ping7io) organization

## Using the builder

Use this builder image in your Java build stage.

```Dockerfile
# build stage
FROM ghcr.io/observabilitystack/graalvm-maven-builder:ol9-java17-22.3.0 AS builder
RUN mvn -B native:compile -P native \
    --no-transfer-progress -DskipTests=true && \
    chmod +x /build/target/application

# run stage
FROM debian:bookworm-slim
COPY --from=builder "/build/target/application" /srv/application
CMD exec /srv/application
```

### Picking a runner image

In the example above we used ` debian:bookworm-slim` as runner image.
Use any glibc distro with glibc >= `2.34` as a runner image.
Examples are:

* Oracle Linux 9
* Debian Bookworm Slim (testing)

> ☝️ Running on Alpine is not possible yet (see Limitations)

### Limitations

This image strives to give you a easy image creation experience
on both `aarch64` and `x86_64` architectures. Unfortunately,
building a static executable runnable on Alpine Linux is currently
[not supported by GraalVM](https://www.graalvm.org/latest/reference-manual/native-image/metadata/Compatibility/).

## Future work

As soon as GraalVM supports building static images using musl on arm64,
this image will add the capability. Current work can be seen in `Dockerfile.musl`.

## License

This image is licensed under [MIT License](LICENSE)
