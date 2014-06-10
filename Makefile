PARAMS=eqn_params.lp 
GEN=eqn_generator.lp 
SOLVER=eqn_solver.lp
GRINGOFILES=$(PARAMS) $(GEN) $(SOLVER)
VIZ=tr -d '_' | python eqn_viz.py

GROUNDFILE = grounding.log
PROFILE=profile.log



run:
	clingo  $(GRINGOFILES) --outf=2 | $(VIZ)
ground:
	clingo $(GRINGOFILES) --text  > $(GROUNDFILE)
prof: 
	cat $(GROUNDFILE) | cut -c 1-10 | sort | uniq -c | sort -nr > $(PROFILE)

