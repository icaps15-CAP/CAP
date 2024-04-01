
.PHONY: submodules deps clean run-test

all: component-planner

deps:
	apt-get install -y git cgroup-bin mercurial g++ make python flex bison g++-multilib ia32-libs libtool

downward/builds/release/bin/downward:
	git submodule update --init --recursive --remote
	downward/build.py release

component-planner: $(shell find -name "*.lisp") component-planner.ros downward/builds/release/bin/downward
	ros dynamic-space-size=16000 -- -e "(setf ql:*local-project-directories* '(#p\"$(CURDIR)/\"))(ql:register-local-projects)" dump executable ./component-planner.ros

clean:
	rm component-planner

test:
	-git clone --depth=1 https://github.com/guicho271828/ipc2011-clean.git test

run-test: test ./test.sh component-planner
	./test.sh
