-module(memory_maneuver).
%% Day 8
-export([process1/1]).
-record(node, {no_of_children, children, no_of_metadata, metadata, value}).

process1(Session) ->
	{ok, Body} = advent_of_code_client:get(8, Session),
	BinList = string:split(string:trim(Body), "\s", all),
	List = lists:map(fun(B) -> list_to_integer(binary_to_list(B)) end, BinList),
	{[Node], Sum} = to_trees(List, 0, []),
	{Sum, Node#node.value}.

to_trees(List, Sum, Trees) -> {Tree, S, T} = to_tree(List, #node{}, new_node, 0),
	case T of
		[] -> {[Tree|Trees], Sum + S};
		_ -> to_trees(T, Sum + S, [Tree|Trees])
	end.

to_tree([H|T], Node=#node{no_of_metadata=N, metadata=MD, children=Children}, {metadata, N}, Sum) ->
	NewNode = Node#node{metadata=[H|MD], children=lists:reverse(Children)},
	Value = get_value(NewNode#node.metadata, NewNode#node.children, 0),
	io:format("~p~n", [Value]),
	{NewNode#node{value=Value}, Sum + H, T};
to_tree([H|T], Node=#node{no_of_metadata=_, metadata=MD}, {metadata, M}, Sum) ->
	to_tree(T, Node#node{metadata=[H|MD]}, {metadata, M + 1}, Sum + H);
to_tree(List, Node=#node{no_of_children=N, children=Children}, {child, N}, Sum) ->
	{ChildNode, S, T} = to_tree(List, #node{}, new_node, 0),
	to_tree(T, Node#node{children = [ChildNode|Children]}, {metadata, 1}, Sum + S);
to_tree(List, Node=#node{no_of_children=_, children=Children}, {child, M}, Sum) ->
	{ChildNode, S, T} = to_tree(List, #node{}, new_node, 0),
	to_tree(T, Node#node{children=[ChildNode|Children]}, {child, M + 1}, Sum + S);
to_tree([N, M|T], Node, new_node, Sum) ->
	NewNode = Node#node{
		no_of_children=N,
		children=[],
		no_of_metadata=M,
		metadata=[]},
	case N of
		0 -> to_tree(T, NewNode, {metadata, 1}, Sum);
		_ -> to_tree(T, NewNode, {child, 1}, Sum)
	end.

get_value([], _, Value) -> Value;
get_value(MD, [], _) -> lists:sum(MD);
get_value([N|T], Children, Value) ->
	case N > length(Children) of
		true -> get_value(T, Children, Value);
		false -> Child = lists:nth(N, Children),
				 get_value(T, Children, Value + Child#node.value)
	end.

