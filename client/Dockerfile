# --- Stage 1 : build Vite (fichiers statiques dans dist/) ---
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

# --- Stage 2 : Nginx sert les fichiers statiques et proxifie /api vers le serveur ---
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
