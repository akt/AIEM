FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY src ./src
COPY tsconfig.json ./
COPY knexfile.ts ./

RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
