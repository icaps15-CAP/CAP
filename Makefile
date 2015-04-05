
# it can't be 2000 (== 2GB) since sbcl malloc's the entire heap initially
small = 1900

sbcl_version = 1.2.7
platform = x86-64-linux

submodule-branch = develop

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

module_heads = $(foreach m,$(modules),src/$(m)/.git/HEAD)
$(info $(module_dirs))

git_url = git@github.com:guicho271828/$(1).git
git_command = git clone -b $(submodule-branch) --depth 5 $(call git_url,$(1));

.PHONY: clean downward-all run-test concurrent sequencial

all: concurrent

concurrent:
	$(MAKE) -j $(shell cat /proc/cpuinfo | grep processor | wc -l) sequencial

sequencial: component-planner test downward-all


clean:
	git clean -xdff -e downward
	$(MAKE) -C downward/src/preprocess clean
	$(MAKE) -C downward/src/search clean
	$(MAKE) -C downward/src/VAL clean

component-planner: $(module_heads) quicklisp/setup.lisp make-image.lisp $(shell find src -regex ".*.\(lisp\|asd\)")
	$(sbcl) --load quicklisp/setup.lisp --load make-image.lisp "$@"

%: Makefile

# submodules

src/%/.git/HEAD:
	mkdir -p src
	-cd src ; $(call git_command,$(*F))

# downward

downward-all: downward/src/preprocess/preprocess downward/src/search/search downward/src/validate

downward:
	hg clone "http://hg.fast-downward.org" downward

downward/src/preprocess/preprocess: downward
	$(MAKE) -C downward/src/preprocess

downward/src/search/search: downward
	$(MAKE) -C downward/src/search

downward/src/validate: downward
	$(MAKE) -C downward/src/VAL
	-ln -s -t downward/src downward/src/VAL/validate

# sbcl

$(sbcl_dir):
	curl -L "http://downloads.sourceforge.net/project/sbcl/sbcl/$(sbcl_version)/sbcl-$(sbcl_version)-$(platform)-binary.tar.bz2" | bunzip2 | tar xvf -

# quicklisp

quicklisp.lisp: 
	curl -L "http://beta.quicklisp.org/quicklisp.lisp" > quicklisp.lisp

quicklisp/setup.lisp: $(sbcl_dir) quicklisp.lisp local-install.lisp
	$(sbcl)	--load quicklisp.lisp \
		--load local-install.lisp
	ln -s -t quicklisp/local-projects/ ../../src

# lfp

libfixposix: install-lfp.sh
	git clone https://github.com/sionescu/libfixposix.git
	cd libfixposix ; ./install-lfp.sh

# tests

test:
	-git clone git@github.com:guicho271828/ipc2011-clean.git test

run-test: test ./test.sh concurrent
	./test.sh

# 
