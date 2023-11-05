FROM node:latest

WORKDIR /usr/src/app

COPY *.json ./
COPY img ./img
COPY views ./views
COPY *.js ./

RUN npm install
RUN apt-get update && apt-get install -y default-mysql-client

COPY migrations ./migrations
COPY entrypoint.sh entrypoint.sh

EXPOSE 3000

ENTRYPOINT [ "./entrypoint.sh" ]
