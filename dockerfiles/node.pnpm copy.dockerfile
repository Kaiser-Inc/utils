FROM node:lts-alpine AS base

# ---------

FROM base AS deps

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

COPY package.json ./

RUN pnpm install

# ---------

FROM base AS runner
WORKDIR /app

ENV NOVE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 api

RUN chown api:nodejs .

COPY --chown=api:nodejs . .
COPY --from=deps /app/node_modules ./node_modules

USER api

EXPOSE 3333

ENV PORT=3333
ENV hostname="0.0.0.0"

RUN pnpm prisma migrate deploy

CMD [ "pnpm", "start" ]
# ENTRYPOINT ["./entrypoint.sh"]
