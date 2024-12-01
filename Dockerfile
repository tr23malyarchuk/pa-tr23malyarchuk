FROM gcc:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    libpthread-stubs0-dev

WORKDIR /app

COPY HTTP_Server.cpp Arctangent.h Arctangent.cpp /app/

RUN g++ -o http_ser-o HTTP_Server.cpp Arctangent.cpp -lm

EXPOSE 8081

CMD ["./http_ser-o"]

