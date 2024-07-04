# Base stage
FROM node:12-alpine AS base

ARG NEXTJS_DOTENV

ENV NEXTJS_DOTENV=$NEXTJS_DOTENV

# hadolint ignore=DL3018
RUN apk --no-cache add bash curl less tini vim make
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-u", "-c"]

WORKDIR /usr/local/src/app
ENV PATH=$PATH:/usr/local/src/app/node_modules/.bin

# Allow yarn/npm to create ./node_modules
RUN chown node:node .

COPY --chown=node:node ./ ./

USER node

# Install ALL dependencies. We need devDependencies for the build command.
RUN yarn install --production=false --frozen-lockfile --ignore-scripts --non-interactive --no-cache

# Install reaction CLI globally
RUN yarn global add @reactioncommerce/cli

ENV BUILD_ENV=production NODE_ENV=production

# hadolint ignore=SC2046
RUN export $(grep -v '^#' .env.${NEXTJS_DOTENV:-prod} | xargs -0) && yarn build

RUN reaction create-project admin myadmin

# Production stage
FROM node:12-alpine AS production

# hadolint ignore=DL3018
RUN apk --no-cache add bash curl less tini vim make
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-u", "-c"]

WORKDIR /usr/local/src/app
ENV PATH=$PATH:/usr/local/src/app/node_modules/.bin

# Copy built files and production dependencies from the base stage
COPY --from=base /usr/local/src/app /usr/local/src/app
COPY --from=base /usr/local/src/app/node_modules /usr/local/src/app/node_modules

USER node

# Install only prod dependencies now that we've built, to make the image smaller
RUN rm -rf node_modules/*
RUN yarn install --production=true --frozen-lockfile --ignore-scripts --non-interactive

# If any Node flags are needed, they can be set in the NODE_OPTIONS env variable.
CMD ["tini", "--", "yarn", "start"]
LABEL com.reactioncommerce.name="renewed-renaissance-storefront"
