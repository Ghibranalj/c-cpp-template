#!/usr/bin/env bash

PACKAGES="fmt"

# package=("git url"
#          "commit hash"
#          "build command"
#          "libpackage.a"
#          "include dirs")

# raylib=("https://github.com/raysan5/raylib"
#     "fec96137e8d10ee6c88914fbe5e5429c13ee1dac"
#     "mkdir build; cd build; cmake -DCMAKE_BUILD_TYPE=Release ..; make"
#     "libraylib.a"
#     "build/raylib/include")

fmt=("https://github.com/fmtlib/fmt"
    "f8c9fabd948e4b3caea30d3c281018b0308491bf"
    "mkdir build; cd build; cmake -DCMAKE_BUILD_TYPE=Release ..; make"
    "libfmt.a"
    "include")
