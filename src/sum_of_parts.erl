-module(sum_of_parts).
%% Day 7
-export([process1/1]).

process1(Session) ->
	{ok, Body} = advent_of_code_client:get(7, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	List = lists:map(fun(X) -> parse(X) end, BinList),
	Map = to_map(List, #{}),
	RMap = to_reverse_map($A, Map, #{}),
	traverse($A, RMap, "").
	% WList = lists:map(fun(X) -> {[X], 0} end, lists:seq($A, $Z)),
	% WMap = to_weight_map($A, Map, maps:from_list(WList)),
	% SortFun = fun({[X1], N1}, {[X2], N2}) ->
	% 	case N1 == N2 of
	% 		true -> X1 < X2;
	% 		false -> N1 < N2
	% 	end
	% end,
	% ResList = lists:sort(SortFun, maps:to_list(WMap)),
	% {R, _} = hd(ResList),
	% to_res(R, maps:from_list(ResList), Map, "", []).

to_reverse_map(91, _, RMap) -> RMap;
to_reverse_map(N, Map, RMap) ->
	NRMap = add_to_reverse_map([N], Map, RMap),
	to_reverse_map(N + 1, Map, NRMap).

add_to_reverse_map(C, Map, RMap) ->
	ToList = maps:get(C, Map, []),
	add_to_r_map(ToList, C, Map, RMap).

add_to_r_map([], _, _, RMap) -> RMap;
add_to_r_map([H|T], C, Map, RMap) ->
	NRMap = maps:put(H, add_to_list(C, maps:get(H, RMap, [])), RMap),
	ToList = maps:get(H, Map, []),
	NewRMap = add_to_r_map(ToList, C, Map, NRMap),
	add_to_r_map(T, C, Map, NewRMap).

add_to_list(C, List) ->
	case lists:member(C, List) of
		true -> List;
		false -> [C|List]
	end.

traverse(91, RMap, Res) ->
	case lists:flatlength(Res) < 26 of
		true -> traverse($A, RMap, Res);
		false -> Res
	end;
traverse(N, RMap, Res) ->
	FilterFun = fun([X]) -> not lists:member(X, Res) end,
	case lists:filter(FilterFun, maps:get([N], RMap, [])) of
		[] ->
			case lists:member(N, Res) of
				true -> traverse(N + 1, RMap, Res);
				false -> NewRes = Res ++ [N],
					 traverse($A, RMap, NewRes)
			end;
		_ -> traverse(N + 1, RMap, Res)
	end.

to_map([], Map) -> Map;
to_map([[From, To]|T], Map) ->
	to_map(T, maps:put(From, [To|maps:get(From, Map, [])], Map)).

parse(Bin) ->
	Str = binary_to_list(Bin),
	{match, L} = re:run(Str, ".*\s(?<from>[A-Z])\s.*\s(?<to>[A-Z])\s.*", [{capture, [from, to], list}]),
	L.
