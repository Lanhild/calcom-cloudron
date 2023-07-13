FROM cloudron/base:4.0.0@sha256:31b195ed0662bdb06a6e8a5ddbedb6f191ce92e8bee04c03fb02dd4e9d0286df

# Cloudron specific directories
RUN mkdir -p /app/code /app/pkg
WORKDIR /app/code

# Fetch upstream
ARG VERSION=3.0.15
RUN curl -L https://github.com/calcom/cal.com/archive/refs/tags/v${VERSION}.tar.gz | \
    tar -zxvf - --strip-components 1 -C /app/code 

ARG NEXTAUTH_SECRET=secret
ARG CALENDSO_ENCRYPTION_KEY=secret

ARG CLOUDRON_POSTGRESQL_USERNAME
ARG CLOUDRON_POSTGRESQL_PASSWORD
ARG CLOUDRON_POSTGRESQL_HOST
ARG CLOUDRON_POSTGRESQL_PORT
ARG CLOUDRON_POSTGRESQL_DATABASE
ARG CLOUDRON_MAIL_SMTP_HOST
ARG CLOUDRON_MAIL_SMTP_PORT
ARG CLOUDRON_MAIL_SMTP_USERNAME
ARG CLOUDRON_MAIL_SMTP_PASSWORD
ARG CLOUDRON_MAIL_FROM

# Prefill the environment for building
ENV NODE_ENV production \
    NEXT_PUBLIC_WEBAPP_URL=http://NEXT_PUBLIC_WEBAPP_URL_PLACEHOLDER \
    NEXTAUTH_SECRET=secret \
    CALENDSO_ENCRYPTION_KEY=secret \
    DATABASE_URL="postgres://${CLOUDRON_POSTGRESQL_USERNAME}:${CLOUDRON_POSTGRESQL_PASSWORD}@${CLOUDRON_POSTGRESQL_HOST}:${CLOUDRON_POSTGRESQL_PORT}/${CLOUDRON_POSTGRESQL_DATABASE}" \
    EMAIL_FROM=${CLOUDRON_MAIL_FROM} \
    EMAIL_SERVER_HOST=${CLOUDRON_MAIL_SMTP_HOST} \
    EMAIL_SERVER_PORT=${CLOUDRON_MAIL_SMTP_PORT} \
    EMAIL_SERVER_USER=${CLOUDRON_MAIL_SMTP_USERNAME} \
    EMAIL_SERVER_PASSWORD=${CLOUDRON_MAIL_SMTP_PASSWORD}

RUN yarn install && \
    yarn build

# Configuration
RUN ln -s /app/data/env /app/code/.env && \
    chown -R cloudron:cloudron /app/code

EXPOSE 3000

COPY start.sh /app/pkg

RUN chmod +x /app/pkg/start.sh

CMD [ "/app/pkg/start.sh" ]

