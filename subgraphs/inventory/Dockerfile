from --platform=linux/amd64 node:16-alpine

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY inventory.js .
COPY inventory.graphql .

CMD [ "node", "inventory.js" ]
