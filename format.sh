#!/bin/bash

# Directory containing this bash script.
readonly DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo "Formatting C++ code..."
find "$DIR/src" -type f \( -name "*.cpp" -o -name "*.hpp" \) -exec clang-format -i {} +
find "$DIR/include" -type f \( -name "*.cpp" -o -name "*.hpp" \) -exec clang-format -i {} +
echo "Formatted C++ code."

echo "Formatting CMake code..."
find "$DIR" -type f \( -name "CMakeLists.txt" \) -not \( -path "*external*" -o -path "*build*" \) -exec cmake-format -i {} +
echo "Formatted CMake code."

echo "Done. Exiting format.sh."

exit 0

