FROM gcc:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    libpthread-stubs0-dev

WORKDIR /app

COPY HTTP_Server.cpp /app/

RUN g++ -o http_server HTTP_Server.cpp

EXPOSE 8081

CMD ["./http_server"]

