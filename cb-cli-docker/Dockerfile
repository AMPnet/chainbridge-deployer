FROM golang:alpine3.15
ADD ./chainbridge-deploy/cb-sol-cli /cb-sol-cli
WORKDIR /cb-sol-cli
RUN apk add make
RUN apk add git
RUN apk add npm
RUN apk add coreutils
RUN npm install
RUN make install
