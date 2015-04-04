
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

module_dirs = $(foreach m,$(modules),src/$(m))
$(info $(module_dirs))

git_url = git@github.com:guicho271828/$(1).git
git_command = git clone -b $(submodule-branch) --depth 1 $(call git_url,$(1));

.PHONY: component-planner clean submodules downward-all

all: component-planner
clean:
	git clean -xdff

component-planner: submodules downward-all quicklisp/setup.lisp make-image.lisp
	FD_DIR=downward/ $(sbcl) --load quicklisp/setup.lisp --load make-image.lisp "$@"

# modules

submodules: $(module_dirs) quicklisp/local-projects/src

src:
	mkdir -p src

src/%: src
	-cd src ; $(call git_command,$(@F))

quicklisp/local-projects/src: quicklisp/setup.lisp
	ln -s -t quicklisp/local-projects/ ../../src

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
	ln -s -t downward/src downward/src/VAL/validate

# sbcl

$(sbcl_dir):
	curl -L "http://downloads.sourceforge.net/project/sbcl/sbcl/$(sbcl_version)/sbcl-$(sbcl_version)-$(platform)-binary.tar.bz2" | bunzip2 | tar xvf -

# quicklisp

quicklisp.lisp: 
	curl -L "http://beta.quicklisp.org/quicklisp.lisp" > quicklisp.lisp

quicklisp/setup.lisp: $(sbcl_dir) quicklisp.lisp
	$(sbcl)	--load quicklisp.lisp \
		--load local-install.lisp

# test:
# 	tar xf test.tar.gz
# 	./test.sh
