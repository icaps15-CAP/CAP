
# it can't be 2000 (== 2GB) since sbcl malloc's the entire heap initially
small = 1900

sbcl_version = 1.2.7
platform = x86-64-linux

submodule-branch = master

################################################################

sbcl_dir = sbcl-$(sbcl_version)-$(platform)
sbcl = $(sbcl_dir)/run-sbcl.sh --dynamic-space-size $(small) --non-interactive --no-userinit

modules = \
	guicho-utilities \
	pddl.component-abstraction \
	pddl.component-planner \
	pddl.macro-action \
	pddl \
	planner-scripts

module_heads = $(foreach m,$(modules),src/$(m))

git_url = git@github.com:guicho271828/$(1).git
# git_url = https://github.com/guicho271828/$(1).git
git_command = git clone -b $(submodule-branch) --depth 5 $(call git_url,$(1));

.PHONY: clean run-test concurrent sequencial deps src/%

all: concurrent

deps:
	apt-get install -y git cgroup-bin mercurial g++ make python flex bison g++-multilib ia32-libs libtool

concurrent:
	$(MAKE) -j $(shell cat /proc/cpuinfo | grep processor | wc -l) sequencial

sequencial: component-planner test downward

clean:
	git clean -xdff -e downward
	$(MAKE) -C downward/src/preprocess clean
	$(MAKE) -C downward/src/search clean
	$(MAKE) -C downward/src/VAL clean

LFP=$(shell readlink -ef libfixposix/)

export CPATH = $(LFP)/src/include:$(LFP)/src/lib:$(LFP)/build/src/include
$(info CPATH = $(CPATH))

component-planner: $(module_heads) libfixposix quicklisp/setup.lisp make-image.lisp $(shell find src -regex ".*.\(lisp\|asd\)")
	$(sbcl) --load quicklisp/setup.lisp --load make-image.lisp "$@"

%: Makefile

# submodules

src/%:
	mkdir -p src
	-cd src ; $(call git_command,$(*F))
	-cd src/$(*F) ; git pull

# downward

downward:
	git clone git@github.com:guicho271828/downward-fixed-build.git downward

# sbcl

$(sbcl_dir):
	curl -L "http://downloads.sourceforge.net/project/sbcl/sbcl/$(sbcl_version)/sbcl-$(sbcl_version)-$(platform)-binary.tar.bz2" | bunzip2 | tar xvf -

# quicklisp

quicklisp.lisp: 
	curl -L "http://beta.quicklisp.org/quicklisp.lisp" > quicklisp.lisp

quicklisp/setup.lisp: $(sbcl_dir) quicklisp.lisp local-install.lisp
	-$(sbcl) --load quicklisp.lisp --load local-install.lisp
	-ln -s -t quicklisp/local-projects/ ../../src

# lfp

libfixposix: install-lfp.sh
	git clone https://github.com/sionescu/libfixposix.git
	./install-lfp.sh libfixposix

# tests

test:
	-git clone --depth=1 https://github.com/guicho271828/ipc2011-clean.git test

run-test: test ./test.sh concurrent
	./test.sh

# 
