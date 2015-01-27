
# it can't be 2000 (== 2GB) since sbcl malloc's the entire heap initially
small = 1900

sbcl_version = 1.2.7
platform = x86-64-linux

sbcl_dir = sbcl-$(sbcl_version)-$(platform)
sbcl = $(sbcl_dir)/run-sbcl.sh --dynamic-space-size $(small) --non-interactive --no-userinit

submodules = $(shell git submodule status | awk '{printf "quicklisp/local-projects/%s\n",$$2}')

.PHONY: component-planner update upgrade

all: component-planner
clean:
	git clean -df
	git submodule deinit -f */
	rm -rf .git/modules

upgrade: update
	git pull
	git submodule foreach --recursive "git checkout master; git pull"

update:
	git submodule init
	git submodule update
	git submodule foreach "git submodule init; git submodule update"

downward:
	hg clone "http://hg.fast-downward.org" downward
	cd downward/src/; ./build_all

# for initialization
.git/modules: update

quicklisp/local-projects/%: % .git/modules
	-ln -s ../../$< quicklisp/local-projects/

$(sbcl_dir):
	curl -L "http://downloads.sourceforge.net/project/sbcl/sbcl/$(sbcl_version)/sbcl-$(sbcl_version)-$(platform)-binary.tar.bz2" | bunzip2 | tar xvf -

quicklisp.lisp: 
	curl -L "http://beta.quicklisp.org/quicklisp.lisp" > quicklisp.lisp

quicklisp/setup.lisp: quicklisp.lisp
	$(sbcl)	--load quicklisp.lisp \
		--load local-install.lisp

component-planner: .git/modules $(sbcl_dir) quicklisp/setup.lisp $(submodules) downward
	$(sbcl) --load quicklisp/setup.lisp \
		--load make-image.lisp "$@"
