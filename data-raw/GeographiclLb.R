cd data-raw
git clone https://github.com/geographiclib/geographiclib
cp geographiclib/src/*.cpp geographiclib/src/*.hh ../src/
cp geographiclib/include/GeographicLib -R ../src/
