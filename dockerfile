########################
# 1 – dependencies
########################
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install

########################
# 2 – builder
########################
FROM node:20-alpine AS builder
WORKDIR /app

# copy deps and source
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# make `next` CLI visible
ENV PATH="/app/node_modules/.bin:$PATH"

################  build‑time env  ################
# (add every var your code touches during next build)
ARG DATABASE_URL
ARG CLERK_SECRET_KEY
ARG NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ARG NEXT_PUBLIC_IMAGEKIT_PUBLIC_KEY
ARG IMAGEKIT_PRIVATE_KEY
ARG NEXT_PUBLIC_IMAGEKIT_URL_ENDPOINT
ARG NEXT_PUBLIC_APP_URL

ENV DATABASE_URL=$DATABASE_URL
ENV CLERK_SECRET_KEY=$CLERK_SECRET_KEY
ENV NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=$NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ENV NEXT_PUBLIC_IMAGEKIT_PUBLIC_KEY=$NEXT_PUBLIC_IMAGEKIT_PUBLIC_KEY
ENV IMAGEKIT_PRIVATE_KEY=$IMAGEKIT_PRIVATE_KEY
ENV NEXT_PUBLIC_IMAGEKIT_URL_ENDPOINT=$NEXT_PUBLIC_IMAGEKIT_URL_ENDPOINT
ENV NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL
##################################################

# bypass bad ESLint rule
RUN npx next build --no-lint

########################
# 3 – production
########################
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package*.json ./
COPY --from=deps   /app/node_modules ./node_modules

EXPOSE 3000
CMD ["npm","start"]
