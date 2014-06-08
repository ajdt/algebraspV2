% basic node attributes
_side(left;right).
_type(oper;poly).
_operator(add;mul;div).

% nodes
_nodeNum(1..42). % figure out better way to express this
_node(id(Num, Side))	 		:-	_side(Side), _nodeNum(Num).

_validChildOf(Parent, Child)	:-	_nodeNum(Parent), _nodeNum(Child),
									Child > Parent*(max_terms + aux_terms),
									Child <= Parent*(max_terms + aux_terms) + (max_terms +aux_terms).

_root(_node(1, left) ; _node(1, right) ). % represent the left and right sides

% generating problems

% every root node is an active node
_active(Node) : _root(Node).

1 { _nodeType(Node, Type) : _type(Type) } 1 :- _active(Node).	% all active nodes have one type
%1 { _nodeOper(Node_active(Node), _nodeType(Node, oper) 
