FROM golang:alpine3.15
ADD ./chainbridge-deploy/cb-sol-cli /cb-sol-cli
WORKDIR /cb-sol-cli
RUN apk add make
RUN apk add git
RUN apk add npm
RUN make install
RUN npm install
