FROM cloudron/base:4.0.0@sha256:31b195ed0662bdb06a6e8a5ddbedb6f191ce92e8bee04c03fb02dd4e9d0286df

# Cloudron specific directories
RUN mkdir -p /app/code /app/pkg
WORKDIR /app/code

# Fetch upstream
ARG VERSION=3.0.15
RUN curl -L https://github.com/calcom/cal.com/archive/refs/tags/v${VERSION}.tar.gz | \
    tar -zxvf - --strip-components 1 -C /app/code && \
    ln -s /app/data/env /app/code/.env && \
    chown -R cloudron:cloudron /app/code

ENV NODE_ENV production
RUN yarn install

EXPOSE 3000

COPY start.sh /app/pkg

RUN chmod +x /app/pkg/start.sh

CMD [ "/app/pkg/start.sh" ]

