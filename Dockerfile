
# Stage 1: Install dependencies
FROM node:24-alpine AS deps
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

# Stage 2: Build the Next.js application
FROM node:24-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Stage 3: Run the production application
FROM node:24-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME="0.0.0.0"
ENV PORT=3000

RUN addgroup -S nextjs && adduser -S nextjs -G nextjs

COPY --from=builder --chown=nextjs:nextjs /app/public ./public
COPY --from=builder --chown=nextjs:nextjs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nextjs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
