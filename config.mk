### PROJECT CONFIG ###
PROJ_NAME = $(shell basename $(CURDIR))
VERSION = 0.0.1
SRC_DIR = src
BUILD_DIR = build
# RES_DIR = res
INC_DIR = src

### COMPILER CONFIG ###
CC=gcc -std=c17
CPP=g++ -std=c++17
CFLAGS= -Wall -Wextra -pedantic -O0 -g
LDFLAG=
LIBS=  # your libs here
