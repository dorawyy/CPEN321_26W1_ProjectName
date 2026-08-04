# Dev:   docker compose up --build
# Prod:  docker compose --profile prod up --build
#
# Pin Node to the same major version as .nvmrc / package.json engines.

FROM node:22-alpine AS base
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Hot-reload development server (tsx watch).
FROM base AS dev
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Compile TypeScript for production image.
FROM base AS build
COPY . .
RUN npm run build

# Minimal runtime — no devDependencies, no source.
FROM node:22-alpine AS production
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/index.js"]
