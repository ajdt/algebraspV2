% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% This file contains the constants required by eqn_generator.lp
% to create equations. These pareameters are in a separate file,
% so that user-specified parameters can be used instead.
%


% constants governing monomial values and tree depth
#const max_integer	= 5.
#const max_degree	= 2.		% going up to 3rd deg
#const max_depth 	= 2.		% shouldn't be bigger than 2
#const max_terms	= 2.		% max number of children a (3 should be large enough)
#const max_steps 	= 2. % max number of actions until a solution is reached

#const aux_terms	= 2.
#const max_polynoms = 10.

% numbers are integers and rationals
_integer(-1*max_integer..max_integer).
_coeff(X)				:-	_integer(X).
%_rational(Num, Denom)	:-	_integer(Num), _integer(Denom), Denom != 0.
%_coeff(rational(X,Y))	:-	_rational(X,Y).		% makes grounding unnecessarily large, may not support rationals


% initial number of children
_childCount(2..max_terms).

_degree(0..max_degree).
