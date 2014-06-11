% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% This file contains helpers to manipulate expression trees
% and helpers that describe the state of an expression tree
%
%

%================================================================================
% NODE PROPERTIES
%================================================================================
_lessThan(_node(Num1, Side), _node(Num2, Side))		:-	_node(Num1, Side), 
														_node(Num2, Side), 
														Num1 < Num2.

_validChildOf(_node(Parent, Side), _node(Child, Side))	
							:-	_node(Parent, Side), _node(Child, Side),
								Child > Parent*(max_terms + aux_terms),
								Child <= Parent*(max_terms + aux_terms) + (max_terms +aux_terms).
%================================================================================
% POLYNOMIAL PROPERTIES
%================================================================================
% node and integer properties
_notZero(Poly, S)									:-	_holds(Poly, _field(monomof, MonomID), S), not _zeroMonom(MonomID). 
_isZero(Poly, S)									:-	_holds(Poly, _field(nodetype, poly), S),
														not _notZero(Poly,S).
_unequal(Poly1, Poly2, S)							:-	_holds(Poly1, _field(monomof, MonomID), S),
														_holds(Poly2, _field(active), S),
														not _holds(Poly2, _field(monomof, MonomID), S),
														Poly1 != Poly2.
_unequal(Poly2, Poly1, S)							:-	_unequal(Poly1, Poly2, S).


%================================================================================
% MONOMIAL OPERATIONS
%================================================================================
%_monoSum(Mono1, Mono2, Sum)		:-	_monoData(Mono1, Coef1, Deg), _monoData(Mono2, Coef2, Deg),
%									Sum = (Coef1+Coef2)*10 + Deg.
_sameDeg(Mono1, Mono2)			:-	_monoData(Mono1, Coef1, Deg), _monoData(Mono2, Coef2, Deg).
_monoSum(Mono1, Mono2, Sum)		:-	_monoData(Mono1, Coef1, Deg), _monoData(Mono2, Coef2, Deg),
									_monoID(Sum),
									Sum = (Coef1+Coef2)*10 + Deg.
%================================================================================
% MANIPULATING NODES
%================================================================================
_deleteNode(Node, S)								:-	_deleteNodeAndChildren(Node, S).
_deleteNodeAndChildren(Child, S)					:-	_deleteNodeAndChildren(Node, S),
														_holds(Node, _field(activechild, Child), S).
_remove(Node, Field, S)								:-	_deleteNode(Node, S),
														_holds(Node, Field, S).

													% inheriting from 1
_introduce(Frac, _field(nodetype, poly), S) 		:-	_inheritFromOne(Frac, S).
_introduce(Frac, _field(monomof, 10), S) 			:-	_inheritFromOne(Frac, S).
_introduce(Frac, _field(numterms, 1), S)			:-	_inheritFromOne(Frac, S).
_introduce(Frac, _field(active), S)					:-	_inheritFromOne(Frac, S).

% deleteChildNode -- delete subtree rooted at child position
_deleteNodeAndChildren(Child, S)					:-	_deleteChildNode(Parent, Child, S).
_remove(Parent, _field(activechild, Child), S) 		:-	_deleteChildNode(Parent, Child, S).
_update(Parent, _field(numchildren, Children - 1), S) 
													:-	_deleteChildNode(Parent, Child, S),
														_holds(Parent, _field(numchildren, Children), S).