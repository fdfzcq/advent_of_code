-module(inventory_management_system).
%% aco day 2: inventory management system
-export([checksum/1, checksum/2]).

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
