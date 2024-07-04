FROM node:12-buster-slim
ENV PORT=4000
ENV CANONICAL_URL=http://web:4000
ENV BUILD_GRAPHQL_URL=http://localhost:3000/graphql
ENV EXTERNAL_GRAPHQL_URL=http://localhost:3000/graphql
ENV INTERNAL_GRAPHQL_URL=http://localhost:3000/graphql
ENV SEGMENT_ANALYTICS_SKIP_MINIMIZE=true
ENV SEGMENT_ANALYTICS_WRITE_KEY=ENTER_KEY_HERE
ENV SESSION_MAX_AGE_MS=2592000000
ENV SESSION_SECRET=CHANGEME
ENV STRIPE_PUBLIC_API_KEY=ENTER_STRIPE_PUBLIC_KEY_HERE

RUN apt-get update && apt-get install -y curl tini vim make
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-u", "-c"]

WORKDIR /usr/local/src/app
ENV PATH=$PATH:/usr/local/src/app/node_modules/.bin

# Allow yarn/npm to create ./node_modules
RUN chown node:node .

# Copy specific things so that we can keep the image as small as possible
# without relying on each repo to include a .dockerignore file.
COPY --chown=node:node ./ ./

USER node

# Install ALL dependencies. We need devDependencies for the build command.
RUN yarn install --production=false --frozen-lockfile --ignore-scripts --non-interactive --no-cache

ENV BUILD_ENV=production NODE_ENV=production

RUN yarn build

# Install only prod dependencies now that we've built, to make the image smaller
#RUN rm -rf node_modules/*
#RUN yarn install --production=true --frozen-lockfile --ignore-scripts --non-interactive

# If any Node flags are needed, they can be set in the NODE_OPTIONS env variable.
CMD ["tini", "--", "yarn", "start"]
LABEL com.reactioncommerce.name="renewed-renaissance-storefront"
