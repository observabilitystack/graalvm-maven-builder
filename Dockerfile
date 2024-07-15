ARG GRAALVM_TAG

# Set up a default build environment for our components
FROM ghcr.io/graalvm/native-image-community:${GRAALVM_TAG}

# Versions to install here
ARG MAVEN_VERSION=3.9.8
ARG UPX_VERSION=4.2.2

# Install xz (for use with UPX) and other utilities
RUN microdnf install -y xz jq zip \
    && microdnf clean all

# ---------------------------------------------------------------------
# Maven
# ---------------------------------------------------------------------
ENV M2_HOME=/opt/maven
ENV MAVEN_HOME=${M2_HOME}
ENV PATH=${MAVEN_HOME}/bin:${PATH}

WORKDIR ${MAVEN_HOME}
RUN MAVEN_BASE_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/" \
    && MAVEN_DOWNLOAD="/tmp/apache-maven.tar.gz" \
    && curl -s -o ${MAVEN_DOWNLOAD} ${MAVEN_BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf ${MAVEN_DOWNLOAD} -C ${MAVEN_HOME} --strip-components=1

# ---------------------------------------------------------------------
# Linux compiler preparation
# ---------------------------------------------------------------------
ENV TOOLCHAIN_DIR="/opt/build"
ENV PATH="${TOOLCHAIN_DIR}/bin:${PATH}"

ADD rootfs/ /

# ---------------------------------------------------------------------
# UPX
# ---------------------------------------------------------------------
# Install UPX for optional compression of the application
WORKDIR /opt/upx
RUN UPX_DOWNLOAD="/tmp/upx.tar.xz" \
    && mkdir -p ${TOOLCHAIN_DIR}/bin \
    && UPX_BASE_URL="https://github.com/upx/upx/releases/download" \
    && curl -s -L -o ${UPX_DOWNLOAD} ${UPX_BASE_URL}/v${UPX_VERSION}/upx-${UPX_VERSION}-$(download-arch)_linux.tar.xz \
    && tar -xvf ${UPX_DOWNLOAD} --strip-components 1 \
    && mv upx ${TOOLCHAIN_DIR}/bin

# Put GraalVM's cacerts in a predictable place so they can be copied
RUN ln -s /etc/pki/java/cacerts /etc/default/cacerts

# Clean up build artifacts and set a default working directory
WORKDIR /
RUN rm -rf ${UPX_DOWNLOAD} /opt/upx ${MAVEN_DOWNLOAD}
