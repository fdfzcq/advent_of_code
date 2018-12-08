-module(sum_of_parts).
%% Day 7
-export([process1/1, process2/1]).

process2(Session) ->
	{ok, Body} = advent_of_code_client:get(7, Session),
% 	Body = <<"Step C must be finished before step A can begin.
% Step C must be finished before step F can begin.
% Step A must be finished before step B can begin.
% Step A must be finished before step D can begin.
% Step B must be finished before step E can begin.
% Step D must be finished before step E can begin.
% Step F must be finished before step E can begin.">>,
	BinList = string:split(string:trim(Body), "\n", all),
	List = lists:map(fun(X) -> parse(X) end, BinList),
	Map = to_map(List, #{}),
	RMap = to_reverse_map($A, Map, #{}),
	InitState = #{
		1 => {0, nil},
		2 => {0, nil},
		3 => {0, nil},
		4 => {0, nil},
		5 => {0, nil}
	},
	process2(RMap, "", InitState, 0).

process2(RMap, Res, InitState, Time) -> process2(RMap, Res, InitState, Time, lists:flatlength(Res) == 26).

process2(_, _, _, Time, true) -> Time;
process2(RMap, Res, InitState, Time, false) ->
	AList = lists:seq($A, $Z),
	AvailableNodes = lists:filter(
		fun(X) -> [] == lists:filter(
			fun([V]) -> not lists:member(V, Res) end,
			maps:get([X], RMap, []))
			andalso not lists:member(X, Res)
			andalso not lists:member(X, all_nodes_in_state(maps:to_list(InitState), ""))
		end, AList),
	io:format("~p~n", [AvailableNodes]),
	NewState = assign_nodes(AvailableNodes, InitState),
	{FinishedState, R, T} = finish_state(NewState),
	process2(RMap, Res ++ R, FinishedState, Time + T).

assign_nodes([], WorkerState) -> WorkerState;
assign_nodes([H|T], WorkerState) ->
	%io:format("~p~n", [WorkerState]),
	case get_available_worker(WorkerState) of
		nil -> WorkerState;
		Worker -> NewState = maps:put(Worker, {H - 4, [H]}, WorkerState),
				  assign_nodes(T, NewState)
	end.

finish_state(State) ->
	io:format("~p~n", [State]),
	SList = maps:to_list(State),
	{_, {T, _}} = hd(lists:sort(fun({_, {T1, _}}, {_, {T2, _}}) -> T1 < T2 end,
		lists:filter(fun({_, {N, _}}) -> N =/= 0 end, SList))),
	io:format("~p~n", [T]),
	finish_state(SList, T, State, "").

finish_state([], V, State, Res) -> {State, Res, V};
finish_state([{W, {V, C}}|T], V, State, Res) ->
	NewState = maps:put(W, {0, nil}, State),
	NewRes = Res ++ C,
	finish_state(T, V, NewState, NewRes);
finish_state([{W, {N, C}}|T], V, State, Res) ->
	NewState = maps:put(W, new_time(N, C, V), State),
	finish_state(T, V, NewState, Res).

new_time(0, C, _) -> {0, C};
new_time(N, C, V) -> {N - V, C}.

get_available_worker([]) -> nil;
get_available_worker([{W, {0, _}}|_]) -> W;
get_available_worker([_|T]) -> get_available_worker(T);
get_available_worker(WorkerState) ->
	WList = maps:to_list(WorkerState),
	get_available_worker(WList).

all_nodes_in_state([], Res) -> Res;
all_nodes_in_state([{_, {0, _}}|T], Res) -> all_nodes_in_state(T, Res);
all_nodes_in_state([{_, {_, nil}}|T], Res) -> all_nodes_in_state(T, Res);
all_nodes_in_state([{_, {_, R}}|T], Res) -> all_nodes_in_state(T, Res ++ R).

%% part 1

process1(Session) ->
	{ok, Body} = advent_of_code_client:get(7, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	List = lists:map(fun(X) -> parse(X) end, BinList),
	Map = to_map(List, #{}),
	RMap = to_reverse_map($A, Map, #{}),
	traverse($A, RMap, "").

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
