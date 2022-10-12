FROM ubuntu:22.04

MAINTAINER guig <gg@chaochuang.com.cn>

ENV JAVA_HOME /opt/java/openjdk
ENV PATH $JAVA_HOME/bin:$PATH

# Default to UTF-8 file.encoding
ENV LANG='zh_CN.UTF-8' LANGUAGE='zh_CN:zh' LC_ALL='zh_CN.UTF-8'

RUN sed -i -e 's#archive.ubuntu.com#repo.huaweicloud.com#g' -e 's#security.ubuntu.com#repo.huaweicloud.com#g' -e 's#ports.ubuntu.com#repo.huaweicloud.com#g' /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata wget ca-certificates fontconfig locales fonts-wqy-zenhei \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && sed -i -e 's|^#.*en_US.UTF-8|en_US.UTF-8|g' -e 's|^#.*zh_CN.GB18030|zh_CN.GB18030|g' -e 's|^#.*zh_CN.GBK|zh_CN.GBK|g' -e 's|^#.*zh_CN.UTF-8|zh_CN.UTF-8|g' -e 's|^#.*zh_CN GB2312|zh_CN GB2312|g' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk8u345-b01

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='b368b47f771be507b96e435b1a5fc41cb133762cdc86a7801150f25bf1e58421'; \
         BINARY_URL='http://dragonwell.oss-cn-shanghai.aliyuncs.com/8.12.13/Alibaba_Dragonwell_Standard_8.12.13_aarch64_linux.tar.gz'; \
         ;; \
       amd64|i386:x86-64) \
         ESUM='64c00ba16e2eb4bf5f867f6a0604d8f82e0627c61d45d7edddc87cec641d9dd7'; \
         BINARY_URL='http://dragonwell.oss-cn-shanghai.aliyuncs.com/8.12.13/Alibaba_Dragonwell_Standard_8.12.13_x64_linux.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
	  wget -O /tmp/openjdk.tar.gz ${BINARY_URL}; \
	  echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
	  mkdir -p "$JAVA_HOME"; \
	  tar --extract \
	      --file /tmp/openjdk.tar.gz \
	      --directory "$JAVA_HOME" \
	      --strip-components 1 \
	      --no-same-owner \
	  ; \
    rm /tmp/openjdk.tar.gz; \
    rm -rf $JAVA_HOME/src.zip $JAVA_HOME/javafx-src.zip $JAVA_HOME/sample $JAVA_HOME/man; \
# https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
    find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
    ldconfig;

RUN echo Verifying install ... \
    && echo javac -version && javac -version \
    && echo java -version && java -version \
    && echo Complete.
