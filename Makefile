CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17 -O2
SRC = main.cpp Arctangent.cpp
OBJ = $(SRC:.cpp=.o)
TARGET = program

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(TARGET)

.PHONY: all clean

