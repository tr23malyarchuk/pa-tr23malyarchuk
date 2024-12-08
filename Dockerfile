FROM gcc:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    libpthread-stubs0-dev

WORKDIR /app

RUN wget https://raw.githubusercontent.com/tr23malyarchuk/pa-tr23malyarchuk/branchHTTPserver/HTTP_Server.cpp \
    && wget https://raw.githubusercontent.com/tr23malyarchuk/pa-tr23malyarchuk/branchHTTPserver/Arctangent.h \
    && wget https://raw.githubusercontent.com/tr23malyarchuk/pa-tr23malyarchuk/branchHTTPserver/Arctangent.cpp

RUN g++ -o http_ser-o HTTP_Server.cpp Arctangent.cpp -lm

EXPOSE 8081

CMD ["./http_ser-o"]

