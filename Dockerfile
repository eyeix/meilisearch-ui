FROM node:22

# Setting working directory.
WORKDIR /opt/meilisearch-ui

RUN npm install -g pnpm

# Copying source files
COPY . .

# Installing dependencies
RUN pnpm install

EXPOSE 24900

ENV NODE_ENV=prod

# Bake the bundle ONCE at image build time using sentinel placeholders.
# The runtime entrypoint (`scripts/cmd.sh`) replaces these with the
# actual SINGLETON_* env values via `sed` on the prebuilt `dist/`.
# Boot time drops from 2-5 min (build at start) to seconds. Pod restarts
# on secret rotation become viable in production clusters.
#
# Non-Docker deployments (e.g. Vercel) still build at deploy time with
# concrete env values; this RUN only affects this image's `dist/`.
ENV VITE_SINGLETON_MODE=__MEILI_UI_REPLACE_SINGLETON_MODE__ \
    VITE_SINGLETON_HOST=__MEILI_UI_REPLACE_SINGLETON_HOST__ \
    VITE_SINGLETON_API_KEY=__MEILI_UI_REPLACE_SINGLETON_API_KEY__
RUN pnpm run build:docker

RUN ["chmod", "+x", "./scripts/cmd.sh"]
ENTRYPOINT ["./scripts/cmd.sh"]
