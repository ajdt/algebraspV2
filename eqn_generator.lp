% Armando Diaz Tolentino <ajdt@cs.washington.edu> 
% 
% This file generates equations using the given
% definitions for the left/right side, operator nodes, and
% polynomials.
% The file eqn_params.lp contains parameters used by this
% file.
%

% basic node attributes
_side(left;right).
_type(oper;poly).
_operator(add;mul;div).

% nodes
_nodeNum(0..42). % figure out better way to express this
_node(Num, Side)	 		:-	_side(Side), _nodeNum(Num).

_validChildOf(_node(Parent, Side), _node(Child, Side))	
							:-	_node(Parent, Side), _node(Child, Side),
								Child > Parent*(max_terms + aux_terms),
								Child <= Parent*(max_terms + aux_terms) + (max_terms +aux_terms).

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
														ChildCount = 1..Num,
														ChildID = Parent*(max_terms + aux_terms) + ChildCount .
_active(Child)	:-	_activeChild(Parent, Child).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MONOMIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: try optimization, where only 10 or so polynom exist
1 { _monomOf(Node, Coeff, Deg) : _coeff(Coeff) } 1	:- _active(Node), _nodeType(Node, poly), _degree(Deg).

% TODO: delete later, only for debugging
#show _active/1.
%#show _numChildren/2.
%#show _root/1.

% needed for visualizer
#show _activeChild/2.
#show _nodeType/2.
#show _monomOf/3.
#show _nodeOper/2.
