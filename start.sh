#!/bin/bash

set -eu

echo "=> Starting application"

APP_PATH=/app/data/calcom

NEXT_PUBLIC_WEBAPP_URL=${CLOUDRON_APP_ORIGIN}

if [[ ! -f /app/data/env ]]; then
    echo "=> First initialization, setting up application..."

    cp /app/code/.env.example /app/data/env

    mkdir -p /app/data/calcom

    cp /app/code/package.json /app/data/calcom/
    cp /app/code/yarn.lock /app/data/calcom/
    cp /app/code/turbo.json /app/data/calcom/

    # Environment variables
    NEXTAUTH_SECRET="$(openssl rand -base64 32)"
    CALENDSO_ENCRYPTION_KEY="$(openssl rand -base64 32)"
    DATABASE_URL=postgres://${CLOUDRON_POSTGRESQL_USERNAME}:${CLOUDRON_POSTGRESQL_PASSWORD}@${CLOUDRON_POSTGRESQL_HOST}:${CLOUDRON_POSTGRESQL_PORT}/${CLOUDRON_POSTGRESQL_DATABASE}

    sed -e "s,NEXT_PUBLIC_LICENSE_CONSENT=.*,NEXT_PUBLIC_LICENSE_CONSENT=true," \
		-e "s,LICENSE=.*,LICENSE=," \
		-e "s,NEXT_PUBLIC_WEBAPP_URL=.*,NEXT_PUBLIC_WEBAPP_URL=${NEXT_PUBLIC_WEBAPP_URL}," \
		-e "s,NEXTAUTH_SECRET=.*,NEXTAUTH_SECRET=${NEXTAUTH_SECRET}," \
		-e "s,CALENDSO_ENCRYPTION_KEY=.*,CALENDSO_ENCRYPTION_KEY=${CALENDSO_ENCRYPTION_KEY}," \
		-e "s,POSTGRES_USER=.*,POSTGRES_USER=${CLOUDRON_POSTGRESQL_USERNAME}," \
		-e "s,POSTGRES_PASSWORD=.*,POSTGRES_PASSWORD=${CLOUDRON_POSTGRESQL_PASSWORD}," \
		-e "s,POSTGRES_DB=.*,POSTGRES_DB=${CLOUDRON_POSTGRESQL_DATABASE}," \
		-e "s,DATABASE_HOST=.*,DATABASE_HOST=${CLOUDRON_POSTGRESQL_HOST}," \
		-e "s,DATABASE_URL=.*,DATABASE_URL=\"postgres://${CLOUDRON_POSTGRESQL_USERNAME}:${CLOUDRON_POSTGRESQL_PASSWORD}@${CLOUDRON_POSTGRESQL_HOST}:${CLOUDRON_POSTGRESQL_PORT}/${CLOUDRON_POSTGRESQL_DATABASE}\"," \
		-e "s,CALCOM_TELEMETRY_DISABLED=.*,CALCOM_TELEMETRY_DISABLED=true," \
		-e "s,MS_GRAPH_CLIENT_ID=.*,#MS_GRAPH_CLIENT_ID=," \
		-e "s,MS_GRAPH_CLIENT_SECRET=.*,#MS_GRAPH_CLIENT_SECRET=," \
		-e "s,ZOOM_CLIENT_ID=.*,#ZOOM_CLIENT_ID=," \
		-e "s,ZOOM_CLIENT_SECRET=.*,#ZOOM_CLIENT_SECRET=," \
		-e "s,EMAIL_FROM=.*,EMAIL_FROM=${CLOUDRON_MAIL_FROM}," \
		-e "s,EMAIL_SERVER_HOST=.*,EMAIL_SERVER_HOST=${CLOUDRON_MAIL_SMTP_SERVER}," \
		-e "s,EMAIL_SERVER_PORT=.*,EMAIL_SERVER_PORT=${CLOUDRON_MAIL_SMTP_PORT}," \
		-e "s,EMAIL_SERVER_USER=.*,EMAIL_SERVER_USER=${CLOUDRON_MAIL_SMTP_USERNAME}," \
		-e "s,EMAIL_SERVER_PASSWORD=.*,EMAIL_SERVER_PASSWORD=${CLOUDRON_MAIL_SMTP_PASSWORD},"
	-i /app/data/env
fi

echo "=> Updating environment"

sed -e "s,NEXT_PUBLIC_WEBAPP_URL=.*,NEXT_PUBLIC_WEBAPP_URL=${NEXT_PUBLIC_WEBAPP_URL}," \
	-e "s,POSTGRES_USER=.*,POSTGRES_USER=${CLOUDRON_POSTGRESQL_USERNAME}," \
	-e "s,POSTGRES_PASSWORD=.*,POSTGRES_PASSWORD=${CLOUDRON_POSTGRESQL_PASSWORD}," \
	-e "s,POSTGRES_DB=.*,POSTGRES_DB=${CLOUDRON_POSTGRESQL_DATABASE}," \
	-e "s,DATABASE_HOST=.*,DATABASE_HOST=${CLOUDRON_POSTGRESQL_HOST}," \
	-e "s,DATABASE_URL=.*,DATABASE_URL=\"postgres://${CLOUDRON_POSTGRESQL_USERNAME}:${CLOUDRON_POSTGRESQL_PASSWORD}@${CLOUDRON_POSTGRESQL_HOST}:${CLOUDRON_POSTGRESQL_PORT}/${CLOUDRON_POSTGRESQL_DATABASE}\"," \
	-e "s,EMAIL_FROM=.*,EMAIL_FROM=${CLOUDRON_MAIL_FROM}," \
	-e "s,EMAIL_SERVER_HOST=.*,EMAIL_SERVER_HOST=${CLOUDRON_MAIL_SMTP_SERVER}," \
	-e "s,EMAIL_SERVER_PORT=.*,EMAIL_SERVER_PORT=${CLOUDRON_MAIL_SMTP_PORT}," \
	-e "s,EMAIL_SERVER_USER=.*,EMAIL_SERVER_USER=${CLOUDRON_MAIL_SMTP_USERNAME}," \
	-e "s,EMAIL_SERVER_PASSWORD=.*,EMAIL_SERVER_PASSWORD=${CLOUDRON_MAIL_SMTP_PASSWORD},"
-i /app/data/env

echo "==> Starting Cal.com"
exec npx prisma migrate deploy --schema /app/code/prisma/schema.prisma && \
	 npx ts-node --transpile-only /app/code/packages/prisma/seed-app-store.ts
exec yarn start
