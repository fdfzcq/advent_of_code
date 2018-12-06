-module(chronal_coordinates).
%% Day 6
-export([process/1, process2/1]).

process(Session) ->
	{ok, Body} = advent_of_code_client:get(6, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	Coordinates = lists:map(fun(Str) -> to_coordinate(Str) end, BinList),
	Map = cluster(Coordinates),
	Infinite = maps:get(infinite, Map, []),
	MList = maps:to_list(Map),
	FilterFun = fun({P, _}) -> not lists:member(P, Infinite) end,
	Filtered = lists:filter(FilterFun, MList),
	SortFun = fun({_, L1}, {_, L2}) -> lists:flatlength(L1) > lists:flatlength(L2) end,
	{_, ResList} = hd(lists:sort(SortFun, Filtered)),
	%io:format("~p~n", [maps:get(nocluster, Map, nil)]),
	lists:flatlength(ResList).

to_coordinate(BinStr) ->
	StrList = string:split(binary_to_list(BinStr), ", "),
	X = list_to_integer(hd(StrList)),
	Y = list_to_integer(lists:nth(2, StrList)),
	{X, Y}.

cluster(Coordinates) -> cluster(Coordinates, init_data_set(Coordinates), #{}).

cluster(_, {_, []}, Map) -> Map;
cluster(Coordinates, {Max, [P|T]}, Map) ->
	SortFun = fun(P1, P2) ->
		man_dis(P, P1) =< man_dis(P, P2)
	end,
	[H|Sorted] = lists:sort(SortFun, Coordinates),
	NewMap = assign(H, Sorted, P, Map, Max),
	cluster(Coordinates, {Max, T}, NewMap).

assign(H, _, {0, _}, Map, _) -> assign(infinite, H, Map);
assign(H, _, {_, 0}, Map, _) -> assign(infinite, H, Map);
assign(H, _, {Max, _}, Map, Max) -> assign(infinite, H, Map);
assign(H, _, {_, Max}, Map, Max) -> assign(infinite, H, Map);
assign(H1, [H2|_], P, NewMap, _) ->
	case man_dis(P, H1) == man_dis(P, H2) of
		true -> assign(nocluster, P, NewMap);
		false -> assign(H1, P, NewMap)
	end;
assign(H, _, P, NewMap, _) -> assign(H, P, NewMap).

assign(C, P, Map) ->
	case maps:get(C, Map, nil) of
		nil -> maps:put(C, [P], Map);
		List -> maps:put(C, [P|List], Map)
	end.

man_dis({X1, Y1}, {X2, Y2}) -> abs(X2 - X1) + abs(Y2 - Y1).

init_data_set(Coordinates) ->
	Max_X = lists:max(lists:map(fun({X, _}) -> X end, Coordinates)),
	Max_Y = lists:max(lists:map(fun({_, Y}) -> Y end, Coordinates)),
	Max = max(Max_X, Max_Y),
	io:format("~p~n", [Max]),
	init_data_set(Max, {0, 0}, []).

init_data_set(Max, {Max, Max}, List) -> {Max, [{Max, Max}|List]};
init_data_set(Max, {Max, Y}, List) ->
	init_data_set(Max, {0, Y + 1}, [{Max, Y}|List]);
init_data_set(Max, {X, Y}, List) ->
	init_data_set(Max, {X + 1, Y}, [{X, Y}|List]).

%% part 2

process2(Session) ->
	{ok, Body} = advent_of_code_client:get(6, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	Coordinates = lists:map(fun(Str) -> to_coordinate(Str) end, BinList),
	{_, DataSet} = init_data_set(Coordinates),
	process2(DataSet, Coordinates, []).

process2([], _, List) -> lists:flatlength(List);
process2([H|T], Coordinates, List) ->
	case total_dist(Coordinates, H, 0) < 10000 of
		true -> process2(T, Coordinates, [H|List]);
		false -> process2(T, Coordinates, List)
	end.

total_dist([], _, V) -> V;
total_dist([H|T], P, V) -> total_dist(T, P, man_dis(H, P) + V).
