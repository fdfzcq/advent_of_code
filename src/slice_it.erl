-module(slice_it).
%% Day 3: No matter how you slice it
-export([process/1]).

-record(rectangle, {id, l_vertex, t_vertex, r_vertex, b_vertex}).

process(Session) ->
	%Body = <<"#1 @ 1,3: 4x4\n#3 @ 1,1: 4x4">>,
	RectList = get_rects(Session),
	io:format("~p~n", [RectList]),
	SortFun = fun(R1, R2) -> R1#rectangle.t_vertex =< R2#rectangle.t_vertex end,
	{L, _} = sweep(lists:sort(SortFun, RectList), 0, 0, []),
	lists:filter(fun(R) -> not lists:member(R#rectangle.id, L) end, RectList).

get_rects(Session) ->
	{ok, Body} = advent_of_code_client:get(3, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	lists:map(fun(Bin) -> to_rectangle(Bin) end, BinList).

to_rectangle(Bin) ->
	Str = binary_to_list(Bin),
	{match, L} = re:run(Str,
		"#(?<id>\\d+) @ (?<l_vertex>\\d+),(?<t_vertex>\\d+): (?<h_edge>\\d+)x(?<v_edge>\\d+)",
		[{capture, [id, l_vertex, t_vertex, h_edge, v_edge], list}]),
	[ID, LVertex, TVertex, HEdge, VEdge] = lists:map(fun(N) -> list_to_integer(N) end, L),
	#rectangle{id = ID, l_vertex = LVertex, t_vertex = TVertex,
		r_vertex = LVertex + HEdge - 1, b_vertex = TVertex + VEdge - 1}.

sweep(_, 1000, Size, Overlapped) -> {Overlapped, Size};
sweep(List, Line, Size, Overlapped) ->
	io:format("sweeping line ~p ~n", [Line]),
	case lists:filter(fun(R) -> R#rectangle.l_vertex =< Line andalso R#rectangle.r_vertex >= Line end, List) of
		[] -> sweep(List, Line + 1, Size, Overlapped);
		L ->
			{NewOverlapped, V} = find_overlap(L, 0, 0, Overlapped),
			%find_overlap(T, H#rectangle.t_vertex, H#rectangle.b_vertex, 0),
			sweep(List, Line + 1, Size + V, NewOverlapped)
	end.

find_overlap(_, 1000, Size, Overlapped) -> {Overlapped, Size};
find_overlap(List, Row, Size, Overlapped) ->
	Filtered = lists:filter(fun(R) -> R#rectangle.t_vertex =< Row andalso R#rectangle.b_vertex >= Row end, List),
	case length(Filtered) > 1 of
		true -> NewOverlapped = update_overlapped(Overlapped, Filtered),
				find_overlap(List, Row + 1, Size + 1, NewOverlapped);
		false -> find_overlap(List, Row + 1, Size, Overlapped)
	end.

update_overlapped(Overlapped, []) -> Overlapped;
update_overlapped(Overlapped, [H|T]) ->
	case lists:member(H#rectangle.id, Overlapped) of
		true -> update_overlapped(Overlapped, T);
		false -> update_overlapped([H#rectangle.id|Overlapped], T)
	end.
