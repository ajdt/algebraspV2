% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% This file generates equations using the given
% definitions for the left/right side, operator nodes, and
% polynomials.
% The file eqn_params.lp contains parameters used by this
% file.
%

% basic node attributes
_side(left;right;aux).
_type(oper;poly).
_operator(add;mul;div).

% nodes
_nodeNum(0..42). % figure out better way to express this
_node(Num, Side)	 		:-	_side(Side), _nodeNum(Num), Side != aux.

% auxillary nodes used to form temporary expressions
#const aux_nodes=21.
_auxNum(0..aux_nodes).
_node(Num, aux)				:-	_auxNum(Num).


_root(_node(0, left) ; _node(0, right) ). % represent the left and right sides

% node depth
_nodeDepth(Root, 0)			:-	_root(Root).
_nodeDepth(Child, Depth+1)	:-	_validChildOf(Parent, Child), _nodeDepth(Parent, Depth).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GENERATING PROBLEMS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
_active(Node) :- _root(Node).

% node type
1 { _nodeType(Node, Type) : _type(Type) } 1			:- _active(Node), _nodeDepth(Node, Depth), Depth < max_depth.
 _nodeType(Node, poly)								:- _active(Node), _nodeDepth(Node, Depth), Depth >= max_depth.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OPERATOR NODES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
1 { _nodeOper(Node, Op) : _operator(Op) } 1			:-	_active(Node), _nodeType(Node, oper).
% division nodes must have exactly two children, others can have any number of children
1 { _numChildren(Node, Num) : _childCount(Num) } 1	:-	_active(Node), _nodeType(Node, oper), _nodeOper(Node, Op), Op != div.
_numChildren(Node, 2)								:-	_active(Node), _nodeOper(Node, div).

% activating children for operators
_activeChild( _node(Parent, Side), _node(ChildID, Side) )	:-	_active(_node(Parent, Side)),
														_numChildren(_node(Parent, Side), Num),
														_node(Parent, Side),
														_node(ChildID, Side),
														ChildCount = 1..Num,
														ChildID = Parent*(max_terms + aux_terms) + ChildCount .
_active(Child)	:-	_activeChild(Parent, Child).

% add numerator and denominator predicates for div nodes
_numDenom(Parent, Num, Denom)						:-	_nodeOper(Parent, div),
														_activeChild(Parent, Num),
														_activeChild(Parent, Denom),
														_lessThan(Num, Denom). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% POLYNOMIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defining monomials
_zeroMonom(0..max_degree).		% these numbers are assigned to monomial with zero coeff
_basicMonoID(Coef*10 + Deg)		:-	_coeff(Coef), _degree(Deg).
_monoData(MonoID, Coef, Deg)	:-	_coeff(Coef), _degree(Deg), MonoID = Coef*10 + Deg.
_monoID(MonoID)					:-	_basicMonoID(MonoID).

% overflow monomials, not used during testing

%_overflowCoef(Coef1+Coef2)		:-	_coeff(Coef1), _coeff(Coef2).
%_overflowCoef(Coef1*Coef2)		:-	_coeff(Coef1), _coeff(Coef2).
%_monoID(Coef*10 + Deg)			:-	_overflowCoef(Coef), _degree(Deg).
%_monoData(MonoID, Coef, Deg)	:-	_overflowCoef(Coef), _degree(Deg), MonoID = Coef*10 + Deg.

_termNum(1..max_degree+1).

% decide how many terms polynomial has, then what degree terms are present, 
% then what coefficients these terms have
1 { _numTerms(Node, Num) : _termNum(Num) } 1		:-	_nodeType(Node, poly).
%NumTerms { _hasMonoWithDegree(Node, Deg) : _degree(Deg) } NumTerms	:-	_numTerms(Node, NumTerms).
%1 { _monomOf(Node, Coeff, Deg) : _coeff(Coeff) } 1	:-	_hasMonoWithDegree(Node, Deg).

NumTerms { _monomOf(Node, MonoID) : _basicMonoID(MonoID) } NumTerms	
													:-	_numTerms(Node, NumTerms).
%1 { _monomOf(Node, Coeff, Deg) : _coeff(Coeff) } 1	:-	_active(Node), _nodeType(Node, poly), _degree(Deg).


