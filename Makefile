
small = 1900

.PHONY: copy refresh clean component-planner

all: component-planner

component-planner:
	sbcl --dynamic-space-size $(small) --non-interactive --load make-image.lisp "$@"
	chmod +x $@

clean:
	rm -fv component-planner
