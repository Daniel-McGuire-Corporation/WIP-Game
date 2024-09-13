#/bin/sh
echo "Compiling..."
g++ --std=c++23 debug.cc -o test.o
echo "Compiled!"
echo ""
echo "Running:"
echo ""
./test.o