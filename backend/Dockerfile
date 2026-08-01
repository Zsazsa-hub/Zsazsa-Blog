FROM node:18-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
# Use legacy-peer-deps to avoid peer dependency resolution failures in CI
RUN npm install --production --legacy-peer-deps
COPY . .
EXPOSE 4000
CMD ["node", "index.js"]
