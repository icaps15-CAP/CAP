
(ql:register-local-projects)
(push :add-cost *features*)
(push :interpret-pddl *features*)
(ql:quickload :cffi)
(let ((lfp (merge-pathnames "libfixposix/build/src/lib/.libs/")))
  (print lfp)
  (push lfp cffi:*foreign-library-directories*))
(ql:quickload :pddl.component-planner.experiment)
(pddl.component-planner.experiment::save (nth 1 sb-ext:*posix-argv*))

