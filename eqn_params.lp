% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% This file contains the constants required by eqn_generator.lp
% to create equations. These pareameters are in a separate file,
% so that user-specified parameters can be used instead.
%


% constants governing monomial values and tree depth
#const max_integer	= 5.
#const max_degree	= 3.
#const max_depth 	= 2.
#const max_terms	= 3.		% max number of children a
#const max_steps 	= 1. % max number of actions until a solution is reached

#const aux_terms	= 3.
#const max_polynoms = 10.

% numbers are integers and rationals
_integer(-1*max_integer..max_integer).
_rational(Num, Denom)	:-	_integer(Num), _integer(Denom), Denom != 0.
_number(integer(X))		:-	_integer(X).
_number(rational(X,Y))	:-	_rational(X,Y).

% every number can be a coefficient (change this to make only integers be coefficients, etc.
_coef(X)				:-	_number(X).
