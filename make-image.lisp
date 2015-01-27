

(push :add-cost *features*)
(push :interpret-pddl *features*)
(ql:quickload :pddl.component-planner.experiment)
(pddl.component-planner.experiment::save (nth 1 sb-ext:*posix-argv*))

