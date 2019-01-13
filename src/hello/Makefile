CHARMDIR = [put Charm++ install directory here]
CHARMC = $(CHARMDIR)/bin/charmc $(OPTS)

default: all
all: hello

hello : main.o
  $(CHARMC) -language charm++ -o hello main.o

main.o : main.C main.h main.decl.h main.def.h
  $(CHARMC) -o main.o main.C

main.decl.h main.def.h : main.ci
  $(CHARMC) main.ci

clean:
  rm -f main.decl.h main.def.h main.o hello charmrun
Figure 1: Source code and Makefile for Basic "Hello World" Program
The Header File (main.h)
