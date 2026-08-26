FROM node:24.19.0-alpine AS dependencies
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

FROM dependencies AS build
COPY . .
RUN npm run build

FROM nginx:1.30.4-alpine AS runtime
ENV BACKEND_UPSTREAM=backend:3000 \
    NGINX_ENVSUBST_FILTER=BACKEND_UPSTREAM
RUN rm /etc/nginx/conf.d/default.conf \
    && sed -i 's#/run/nginx.pid#/tmp/nginx.pid#' /etc/nginx/nginx.conf \
    && sed -i '/^user  nginx;/d' /etc/nginx/nginx.conf \
    && chown -R nginx:nginx /etc/nginx/conf.d /var/cache/nginx
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
USER nginx
