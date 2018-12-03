-module(slice_it).
%% Day 3: No matter how you slice it
-export([process/1]).

-record(rectangle, {l_vertex, t_vertex, r_vertex, b_vertex}).

process(Session) ->
	Body = <<"#1 @ 1,3: 4x4\n#2 @ 3,1: 4x4\n#3 @ 4,4: 4x4">>,
	%{ok, Body} = advent_of_code_client:get(3, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	RectList = lists:map(fun(Bin) -> to_rectangle(Bin) end, BinList),
	SortFun = fun(R1, R2) -> R1#rectangle.t_vertex < R2#rectangle.t_vertex end,
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

sweep(_, 1010, Size) -> Size;
sweep(List, Line, Size) ->
	case lists:filter(fun(R) -> R#rectangle.l_vertex =< Line andalso R#rectangle.r_vertex >= Line end, List) of
		[] -> sweep(List, Line + 1, Size);
		[H|T] ->
			V = find_overlap(T, H#rectangle.t_vertex, H#rectangle.b_vertex, 0),
			sweep(List, Line + 1, Size + V)
	end.

find_overlap([], _, _, Size) -> Size;
find_overlap([H|T], Top, Bottom, Size) when Top > Bottom ->
	find_overlap(T, H#rectangle.t_vertex, H#rectangle.b_vertex, Size);
find_overlap([#rectangle{t_vertex=TV, b_vertex=BV}|T], Top, Bottom, Size) ->
	V = min(Bottom, BV) - max(Top, TV) + 1,
	case V > 0 of
		true -> find_overlap(T, min(Bottom, BV) + 1, max(Bottom, BV), Size + V);
		false -> find_overlap(T, TV, BV, Size)
	end.
