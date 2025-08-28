# docker/Dockerfile
FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl unzip xz-utils wget git dos2unix \
    openjdk-17-jdk openjdk-17-jre-headless \
    libgl1 libx11-6 libxcursor1 libxcomposite1 libxrandr2 libxi6 \
    libxtst6 libnss3 libxdamage1 libxfixes3 libxrender1 \
    libasound2 libdbus-1-3 libglu1-mesa \
    e2fsprogs util-linux \
 && rm -rf /var/lib/apt/lists/*


ENV ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_HOME=/opt/android-sdk
ENV PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

RUN mkdir -p ${ANDROID_SDK_ROOT} /root/.android && touch /root/.android/repositories.cfg

RUN cd /opt \
 && curl -sSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o clt.zip \
 && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
 && unzip -q clt.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
 && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/ \
 && rmdir ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools \
 && rm -f /opt/clt.zip

RUN yes | sdkmanager --licenses >/dev/null || true \
 && sdkmanager --install \
      "platform-tools" \
      "emulator" \
      "platforms;android-35" \
      "system-images;android-35;google_apis_playstore;x86_64"

WORKDIR /work
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
