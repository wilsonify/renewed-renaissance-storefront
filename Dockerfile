FROM node:18-alpine
ENV NEXTJS_DOTENV=$NEXTJS_DOTENV
RUN apk --no-cache add bash curl less tini vim make
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-u", "-c"]
WORKDIR /usr/local/src/app
ENV PATH=$PATH:/usr/local/src/app/node_modules/.bin
RUN chown node:node .
COPY --chown=node:node ./ ./
USER node
RUN yarn install --production=false --frozen-lockfile --ignore-scripts --non-interactive --no-cache
ENV BUILD_ENV=production NODE_ENV=production
RUN export $(grep -v '^#' .env.${NEXTJS_DOTENV:-prod} | xargs -0)
RUN yarn build
RUN rm -rf node_modules/*
RUN yarn install --production=true --frozen-lockfile --ignore-scripts --non-interactive
CMD ["tini", "--", "yarn", "start"]
LABEL com.reactioncommerce.name="renewed-renaissance-storefront"
