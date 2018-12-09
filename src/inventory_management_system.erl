-module(inventory_management_system).
%% aco day 2: inventory management system
-export([checksum/1, checksum/2, process2/1]).

checksum(Session) ->
	{ok, Body} = advent_of_code_client:get(2, Session),
	BinList = string:split(Body, "\n", all),
	checksum(BinList, {0, 0}).

checksum([], Res) -> result(Res);
checksum([H|T], Res) ->
	io:format("~p ~p~n", [lists:sort(binary_to_list(H)), Res]),
	NewRes = count_dup(lists:sort(binary_to_list(H)), Res, 0, nil, {false, false}),
	checksum(T, NewRes).

count_dup([], Res, 3, _, {A, _}) -> count_dup([], Res, 0, nil, {A, true});
count_dup([], Res, 2, _, {_, B}) -> count_dup([], Res, 0, nil, {true, B});
count_dup([], Res, _, _, Stuff) -> add(Res, Stuff);
count_dup([H|T], Res, N, H, Stuff) -> count_dup(T, Res, N + 1, H, Stuff);
count_dup([H|T], Res, 0, _, Stuff) -> count_dup(T, Res, 1, H, Stuff);
count_dup([H|T], Res, 1, _, Stuff) -> count_dup(T, Res, 1, H, Stuff);
count_dup([H|T], Res, 3, _, {A, _}) -> count_dup(T, Res, 1, H, {A, true});
count_dup([H|T], Res, 2, _, {_, B}) -> count_dup(T, Res, 1, H, {true, B}).

add({A, B}, {true, true}) -> {A + 1, B + 1};
add({A, B}, {true, false}) -> {A + 1, B};
add({A, B}, {false, true}) -> {A, B + 1};
add({A, B}, _) -> {A, B}.

result({A, 0}) -> A;
result({0, B}) -> B;
result({A, B}) -> A * B.

%% part 2

process2(Session) ->
	{ok, Body} = advent_of_code_client:get(2, Session),
	[H|BinList] = string:split(string:trim(Body), "\n", all),
	process2(H, BinList, BinList).

process2(_, [], []) -> nil;
process2(_, [], [H|T]) -> process2(H, T, T);
process2(Bin, [H|T], List) ->
	Str1 = binary_to_list(Bin),
	Str2 = binary_to_list(H),
	case lists:filter(fun(N) -> N =/= 0 end, lists:zipwith(fun(A, B) -> A - B end, Str1, Str2)) of
		[_] -> merge(Str1, Str2, []);
		_ -> process2(Bin, T, List)
	end.

merge([], [], Res) -> lists:reverse(Res);
merge([S|T1], [S|T2], Res) -> merge(T1, T2, [S|Res]);
merge([_|T1], [_|T2], Res) -> merge(T1, T2, Res).
