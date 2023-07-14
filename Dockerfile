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
ARG MAX_OLD_SPACE_SIZE=4096

# Prefill the environment for building
ENV NODE_ENV production \
    NODE_OPTIONS=--max-old-space-size=${MAX_OLD_SPACE_SIZE}

RUN cp /app/code/.env.example /app/code/.env && \
    sed -i 's|NEXTAUTH_SECRET=.*|NEXTAUTH_SECRET='"$(openssl rand -base64 32)"'|g' /app/code/.env && \
    sed -i 's|CALENDSO_ENCRYPTION_KEY=.*|CALENDSO_ENCRYPTION_KEY='"$(openssl rand -base64 32)"'|g' /app/code/.env

RUN yarn config set httpTimeout 1200000 && \
    npx turbo prune --scope=@calcom/web --docker && \
    yarn install

RUN yarn build

# Cleanup
RUN rm -rf /app/code/.env

# Configuration
RUN ln -s /app/data/env /app/code/.env && \
    chown -R cloudron:cloudron /app/code

EXPOSE 3000

COPY start.sh /app/pkg
RUN chmod +x /app/pkg/start.sh

CMD [ "/app/pkg/start.sh" ]

