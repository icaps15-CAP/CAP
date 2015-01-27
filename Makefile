
# it can't be 2000 (== 2GB) since sbcl malloc's the entire heap initially
small = 1900

sbcl_version = 1.2.7
platform = x86-64-linux

sbcl_dir = sbcl-$(sbcl_version)-$(platform)
sbcl = $(sbcl_dir)/run-sbcl.sh

.PHONY: copy refresh clean component-planner

all: component-planner
clean:
	git clean -xf

upgrade:
	git submodule foreach --recursive "git checkout master; git pull"

.git/modules:
	git submodule init
	git submodule update --depth 1

$(sbcl_dir)/run-sbcl.sh:
	curl -L "http://downloads.sourceforge.net/project/sbcl/sbcl/$(sbcl_version)/sbcl-$(sbcl_version)-$(platform)-binary.tar.bz2" | bunzip2 | tar xvf -


quicklisp.lisp: 
	curl -L "http://beta.quicklisp.org/quicklisp.lisp" > quicklisp.lisp










component-planner: .git/modules $(sbcl) quicklisp.lisp
	$(sbcl) --dynamic-space-size $(small) --non-interactive \
	  	--load quicklisp.lisp \
	  	--load local-install.lisp
		# --load make-image.lisp "$@"
