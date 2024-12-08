FROM gcc:latest AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    libpthread-stubs0-dev

WORKDIR /app

RUN wget https://raw.githubusercontent.com/tr23malyarchuk/pa-tr23malyarchuk/branchHTTPserver/HTTP_Server.cpp \
    && wget https://raw.githubusercontent.com/tr23malyarchuk/pa-tr23malyarchuk/branchHTTPserver/Arctangent.h \
    && wget https://raw.githubusercontent.com/tr23malyarchuk/pa-tr23malyarchuk/branchHTTPserver/Arctangent.cpp

RUN g++ -o http_ser-o HTTP_Server.cpp Arctangent.cpp -lm -static

FROM alpine:latest

RUN apk add --no-cache libstdc++ libgcc

WORKDIR /app

COPY --from=builder /app/http_ser-o /app/

EXPOSE 8081

CMD ["./http_ser-o"]

