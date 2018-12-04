-module(slice_it).
%% Day 3: No matter how you slice it
-export([process/1]).

-record(rectangle, {l_vertex, t_vertex, r_vertex, b_vertex}).

process(Session) ->
	%Body = <<"#1 @ 1,3: 4x4\n#3 @ 1,1: 4x4">>,
	{ok, Body} = advent_of_code_client:get(3, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	RectList = lists:map(fun(Bin) -> to_rectangle(Bin) end, BinList),
	SortFun = fun(R1, R2) -> R1#rectangle.t_vertex =< R2#rectangle.t_vertex end,
	sweep(lists:sort(SortFun, RectList), 0, 0).

to_rectangle(Bin) ->
	StrList = string:split(Bin, "\s", all),
	Str1 = binary_to_list(lists:nth(3, StrList)),
	Str2 = binary_to_list(lists:nth(4, StrList)),
	VertexList = string:split(string:strip(Str1, right, $:), ","),
	EdgeList = string:split(Str2, "x"),
	LVertex = list_to_integer(hd(VertexList)),
	TVertex = list_to_integer(lists:nth(2, VertexList)),
	HEdge = list_to_integer(hd(EdgeList)),
	VEdge = list_to_integer(lists:nth(2, EdgeList)),
	#rectangle{l_vertex = LVertex, t_vertex = TVertex,
		r_vertex = LVertex + HEdge - 1, b_vertex = TVertex + VEdge - 1}.

sweep(_, 1000, Size) -> Size;
sweep(List, Line, Size) ->
	case lists:filter(fun(R) -> R#rectangle.l_vertex =< Line andalso R#rectangle.r_vertex >= Line end, List) of
		[] -> sweep(List, Line + 1, Size);
		L ->
			V = find_overlap(L, 0, 0),
			%find_overlap(T, H#rectangle.t_vertex, H#rectangle.b_vertex, 0),
			sweep(List, Line + 1, Size + V)
	end.

find_overlap(_, 1000, Size) -> Size;
find_overlap(List, Row, Size) ->
	Filtered = lists:filter(fun(R) -> R#rectangle.t_vertex =< Row andalso R#rectangle.b_vertex >= Row end, List),
	case lists:flatlength(Filtered) > 1 of
		true -> find_overlap(List, Row + 1, Size + 1);
		false -> find_overlap(List, Row + 1, Size)
	end.
