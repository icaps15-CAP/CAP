
.PHONY: submodules deps clean run-test

all: component-planner

deps:
	apt-get install -y git cgroup-bin mercurial g++ make python flex bison g++-multilib ia32-libs libtool

submodules:
	git submodule update --init --recursive --remote

component-planner: $(shell find -name "*.lisp") submodules
	ros dynamic-space-size=16000 -- -e "(setf ql:*local-project-directories* '(#p\"$(CURDIR)/\"))(ql:register-local-projects)" dump executable ./cap.ros
# make-image.lisp

clean:
	rm component-planner

test:
	-git clone --depth=1 https://github.com/guicho271828/ipc2011-clean.git test

run-test: test ./test.sh component-planner
	./test.sh
