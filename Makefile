CXX = clang++
CXXFLAGS = -std=c++17 -Wall
LDFLAGS = -framework Cocoa

TARGET = MacOSNativeApp
SRC = src/main.mm

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(TARGET) $(SRC)

clean:
	rm -f $(TARGET)
