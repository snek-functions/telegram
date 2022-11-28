FROM node:18.8.0

LABEL description="This container serves as an entry point for our future Snek Function projects."
LABEL org.opencontainers.image.source="https://github.com/snek-functions/bestconnect"
LABEL maintainer="opensource@snek.at"

# Add custom environment variables needed by TelegramCLI or your settings file here:
ENV BOTTOKEN=token \
    BOTPASSWORD=password \
    API_ID=apiid \
    API_HASH=hash \
    PHONE=phone

# The SNEK Functions configuration (customize as needed):
ENV LAMBDA_TASK_ROOT=/var/task \
    SNEK_FUNCTIONS_BUILD_DIR=/tmp/snek-functions \
    SNEK_FUNCTIONS_PORT=4000 \
    HOME=/var/task

WORKDIR ${LAMBDA_TASK_ROOT}

COPY --from=amazon/aws-lambda-nodejs:latest /usr/local/bin/aws-lambda-rie /usr/local/bin/aws-lambda-rie
COPY --from=amazon/aws-lambda-nodejs:latest /var/runtime /var/runtime
COPY --from=amazon/aws-lambda-nodejs:latest /var/lang /var/lang
COPY --from=amazon/aws-lambda-nodejs:latest lambda-entrypoint.sh .
COPY --from=amazon/aws-lambda-nodejs:latest /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt
# Override /bin/sh because some scripts are only compatible with the amazon version
COPY --from=amazon/aws-lambda-nodejs:latest /bin/sh /bin/sh

# Add static files from . to task root
COPY package.json entrypoint.sh ${LAMBDA_TASK_ROOT}/
# Copy all files form the . to the build dir
COPY ./ ${SNEK_FUNCTIONS_BUILD_DIR}/

RUN chmod +x entrypoint.sh

WORKDIR ${SNEK_FUNCTIONS_BUILD_DIR}

# Update, install and cleaning:
RUN set -ex \
    && wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && BUILD_DEPS=" \
    dotnet-sdk-6.0 \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
    && dotnet build src/dotnet/ \
    #&& ln -s /usr/local/bin/node /var/lang/bin/node \
    && npm install \
    && npx snek-functions build --functions-path . \
    # Copy the built functions to the lambda function
    && cp -r dist node_modules ${LAMBDA_TASK_ROOT} \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS \
    && rm -rf /var/lib/apt/lists

# Install packages needed to run your application (not build deps):
# We need to recreate the /usr/share/man/man{1..8} directories first because
# they were clobbered by a parent image.
RUN set -ex \
    && RUN_DEPS=" \
    dotnet-runtime-6.0 \
    " \
    && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
    && apt-get update && apt-get install -y --no-install-recommends $RUN_DEPS \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${LAMBDA_TASK_ROOT}

ENTRYPOINT [ "./entrypoint.sh" ]

# Start in serverless mode
#CMD [ "app.handler" ]

# SPDX-License-Identifier: (EUPL-1.2)
# Copyright © 2022 snek.at
