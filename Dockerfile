FROM node:16-alpine AS build

WORKDIR /app
# Ensure native deps (mozjpeg) can build and devDeps are installed for Gatsby build.
ENV NODE_ENV=development
ENV YARN_PRODUCTION=false

RUN apk add --no-cache \
  autoconf \
  automake \
  g++ \
  libtool \
  make \
  nasm \
  pkgconfig \
  python3

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN yarn build

FROM nginx:1.25-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/public /usr/share/nginx/html

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
