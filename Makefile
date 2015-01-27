
# it can't be 2000 (== 2GB) since sbcl malloc's the entire heap initially
small = 1900

sbcl_version = 1.2.7
platform = x86-64-linux

sbcl_dir = sbcl-$(sbcl_version)-$(platform)

.PHONY: copy refresh clean component-planner

all: component-planner
clean:
	git clean -xf

update:
	git submodule foreach "git checkout master; git pull"

init:
	git submodule init
	git submodule update

sbcl:
	mkdir -p sbcl

$(sbcl_dir)/run-sbcl.sh:
	curl -L "http://downloads.sourceforge.net/project/sbcl/sbcl/$(sbcl_version)/sbcl-$(sbcl_version)-$(platform)-binary.tar.bz2" | bunzip2 | tar xvf -

component-planner: init $(sbcl_dir)/run-sbcl.sh
	$(sbcl_dir)/run-sbcl.sh --dynamic-space-size $(small) --non-interactive --load make-image.lisp "$@"
