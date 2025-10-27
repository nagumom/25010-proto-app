FROM node:18-alpine

WORKDIR /usr/src/app

COPY package*.json ./

ENV http_proxy=http://proxy4-kanri.cats.tosho.co.jp:8080
ENV https_proxy=http://proxy4-kanri.cats.tosho.co.jp:8080
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
