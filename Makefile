
# it can't be 2000 (== 2GB) since sbcl malloc's the entire heap initially
small = 1900

sbcl_version = 1.2.7
platform = x86-64-linux

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

git_url = git@github.com:guicho271828/$(1).git
git_command = git clone --depth 50 $(call git_url,$(1));

.PHONY: component-planner clean submodules

all: component-planner
clean:
	git clean -xf

component-planner: submodules downward/src/validate
	FD_DIR=downward/ $(sbcl) --load quicklisp/setup.lisp --load make-image.lisp "$@"

# modules

submodules: quicklisp/setup.lisp
	$(foreach module,$(modules),$(call git_command,$(module)))
	$(foreach module,$(modules),ln -s -t quicklisp/local-projects/ $(module))

# downward

downward:
	hg clone "http://hg.fast-downward.org" downward

downward/src/validate: downward
	which g++ || echo "You might have forgot installing the dependency of FD"
	cd downward/src/; ./build_all

# sbcl

$(sbcl_dir):
	curl -L "http://downloads.sourceforge.net/project/sbcl/sbcl/$(sbcl_version)/sbcl-$(sbcl_version)-$(platform)-binary.tar.bz2" | bunzip2 | tar xvf -

quicklisp.lisp: 
	curl -L "http://beta.quicklisp.org/quicklisp.lisp" > quicklisp.lisp

quicklisp/setup.lisp: $(sbcl_dir) quicklisp.lisp
	$(sbcl)	--load quicklisp.lisp \
		--load local-install.lisp



# test:
# 	tar xf test.tar.gz
# 	./test.sh
