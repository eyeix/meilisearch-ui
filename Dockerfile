FROM node:22

# Setting working directory.
WORKDIR /opt/meilisearch-ui

# Pin pnpm major version to keep docker builds reproducible
RUN npm install -g pnpm@10

# Copying source files
COPY . .

# Installing dependencies
RUN pnpm install

EXPOSE 24900

ENV NODE_ENV=prod

RUN ["chmod", "+x", "./scripts/cmd.sh"]
ENTRYPOINT ["./scripts/cmd.sh"]

