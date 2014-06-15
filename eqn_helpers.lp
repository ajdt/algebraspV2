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
_childNum(_node(Parent, Side), _node(Child, Side), Child - Parent*(max_terms + aux_terms) )	
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
	% if only one child left, then inherit from it and delete it
_deleteNodeAndChildren(Child, S)					:-	_deleteChildNode(Parent, Child, S).
_remove(Parent, _field(activechild, Child), S) 		:-	_deleteChildNode(Parent, Child, S).
_update(Parent, _field(numchildren, Children - 1), S) 
													:-	_deleteChildNode(Parent, Child, S),
														_holds(Parent, _field(numchildren, Children), S),
														Children > 2 .
_inheritFromAndDelete(Parent, Child2, S)
													:-	_deleteChildNode(Parent, Child, S),
														_holds(Parent, _field(numchildren, 2), S),
														_holds(Parent, _field(activechild, Child2), S),
														Child != Child2.
_inheritFrom(Inheritor, Original, S)				:-	_inheritFromAndDelete(Inheritor, Original, S).
_deleteNodeAndChildren(Original, S)					:-	_inheritFromAndDelete(Inheritor, Original, S).

								% inheriting from a node
_deleteNode(ToInherit, S)	:-	_inheritFrom(ToInherit, Original, S).
_introduce(ToInherit, _field(active), S)			:-	_inheritFrom(ToInherit, Original, S). 
_introduce(ToInherit, _field(FieldName, FieldValue), S)	
													:-	_inheritFrom(ToInherit, Original, S),
														_holds(Original, _field(FieldName, FieldValue), S),
														FieldName != activechild.
% each of your children must inherit from the appropriate child of Original
_inheritFrom(InheritChild, OrigChild, S)	
													:-	_inheritFrom(_node(InheritNum, ISide), _node(OrigNum, OrigSide), S),
														_holds(_node(OrigNum, OrigSide), _field(activechild, _node(OrigChildNum, OrigSide)), S),
														_node(InheritNum, ISide), % needed to avoid infinite grounding 
														_node(OrigNum, OrigSide),
														InheritChildNum = OrigChildNum - OrigNum*(max_terms + aux_terms) + InheritNum*(max_terms + aux_terms),
														InheritChild = _node(InheritChildNum, ISide),
														OrigChild = _node(OrigChildNum, OrigSide).


%================================================================================
% SUBTREE PROPERTIES
%================================================================================
% subtree equality
_unequal(Tree1, Tree2, S)		:-	_holds(Tree1, _field(numchildren, Children1), S),
								_holds(Tree2, _field(numchildren, Children2), S),
								Children1 != Children2.
_unequal(Tree1, Tree2, S)		:-	_holds(Tree1, _field(nodeoper, Op1), S),
								_holds(Tree2, _field(nodeoper, Op2), S),
								Op1 != Op2.
_unequal(Tree1, Tree2, S)		:-	_holds(Tree1, _field(activechild, Child1), S),
								_holds(Tree2, _field(activechild, Child2), S),
								_equal(Child1, Child2, S).
_equalToChildOf(Node, Subtree, S) :-	_holds(Node, _field(active), S),
										_holds(NodeParent, _field(activechild, Node), S),
										_holds(Subtree, _field(activechild, Child), S),
										Child != Node,
										NodeParent != Subtree,
										not _unequal(Node, Child, S).

_unequal(Subtree1, Subtree2, S)		:-	_holds(Subtree1, _field(active), S),
										_holds(Subtree1, _field(activechild, Child), S),
										_holds(Subtree2, _field(active), S),
										not _equalToChildOf(Child, Subtree2, S).



%================================================================================
% multiply a subtree by another tree
%================================================================================
_addChild(Node, Multiplier, S)		:-	_multiplyWith(Node, Multiplier, S),
										_holds(Node, _field(nodeoper, mul), S).
_multiplyWith(Numer, Multiplier, S)	:-	_multiplyWith(Node, Multiplier, S),
										_holds(Node, _field(nodeoper, div), S),
										_holds(Node, _field(numer, Numer), S).

_convertToMulNode(Node, Multiplier, S)		:-	_multiplyWith(Node, Multiplier, S),
												_holds(Node, _field(nodeoper, Op), S),
												Op != div, Op != mul.
_deleteNodeAndChildren(Node, S)				:-	_convertToMulNode(Node, Multiplier, S).
_introduce(Node, _field(nodeoper, mul), S)	:-	_convertToMulNode(Node, Multiplier, S).
_activateNodeWithChildren(Node, 2, S)		:-	_convertToMulNode(Node, Multiplier, S).
_inheritFrom(Child1, Node, S)				:-	_convertToMulNode(Node, Multiplier, S),
												_childNum(Node, Child1, 1).
_inheritFrom(Child2, Multiplier, S)			:-	_convertToMulNode(Node, Multiplier, S),
												_childNum(Node, Child2, 2).

_introduce(Node, _field(active), S) 		:- _activateNodeWithChildren(Node, Kids, S).
_introduce(Node, _field(numchildren, Kids), S) :- _activateNodeWithChildren(Node, Kids, S).


% adding a new child
_inheritFrom(NewChild, ToAdd, S)	:-	_addChild(Parent, ToAdd, S),
										_holds(Parent, _field(numchildren, Kids), S),
										_childNum(Parent, NewChild, Kids + 1).
_update(Parent, _field(numchildren, Kids+1), S)	:-	_addChild(Parent, ToAdd, S),
													_holds(Parent, _field(numchildren, Kids), S).


_opSubtree(Root, Left, Right, RootOp, LeftOp, RightOp, S)	:-	_holds(Root, _field(nodeoper, RootOp), S),
																_holds(Left, _field(nodeoper, LeftOp), S),
																_holds(Root, _field(activechild, Left), S),
																_holds(Right, _field(nodeoper, RightOp), S),
																_holds(Root, _field(activechild, Right), S),
																_lessThan(Left, Right).
_remove(Frac, _field(numer, Num), S)				:-	_removeFracFields(Frac, S),
														_holds(Frac, _field(numer, Num), S).
_remove(Frac, _field(denom, Denom), S)				:-	_removeFracFields(Frac, S),
														_holds(Frac, _field(denom, Denom), S).
_inheritFrom(Node1, Node2, S)					  :- _swapNodes(Node1, Node2, S).
_inheritFrom(Node2, Node1, S)					  :- _swapNodes(Node1, Node2, S).
