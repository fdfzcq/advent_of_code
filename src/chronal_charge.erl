-module(chronal_charge).
%% day 11: chronal charge
-export([process1/1, calculate_size/5, process2/1]).

process2(GSN) ->
	List = process2(GSN, {1, 1}, [[]]),
	find_max(List, {1,1}, 0, 0, {-100, nil, 0}).

process2(_, {301, 301}, List) -> lists:reverse(List);
process2(GSN, {301, Y}, [H|T]) -> process2(GSN, {1, Y + 1}, [[], lists:reverse(H)|T]);
process2(GSN, {X, Y}, [Row|T]) ->
	process2(GSN, {X + 1, Y}, [[calculate_power({X, Y}, GSN)|Row]|T]).


find_max(_, {301, 301}, _, _, {MaxPower, P, Size}) ->
	{MaxPower, P, Size};
find_max(List, {301, Y}, L, Sum, {MaxPower, P, Size}) -> find_max(List, {1, Y + 1}, L, Sum, {MaxPower, P, Size});
find_max(List, {X, Y}, L, Sum, {MaxPower, P, Size}) when X + L > 300; Y + L > 300 ->
	find_max(List, {X + 1, Y}, 0, Sum, {MaxPower, P, Size});
find_max(List, {X, Y}, L, Sum, {MaxPower, P, Size}) ->
	Cols = lists:sublist(lists:nth(Y + L, List), X, L + 1),
	Lines = lists:sublist(lists:map(fun(LL) -> lists:nth(X + L, LL) end, List), Y, L + 1),
	io:format("STATE: ~p~n", [{Cols, Lines, {X, Y}, L}]),
	NewSum = Sum + get_sum(Cols, Lines, 0),
	case NewSum > MaxPower of
		true -> find_max(List, {X, Y}, L + 1, NewSum, {NewSum, {X, Y}, (L + 1) * (L + 1)});
		false -> find_max(List, {X, Y}, L + 1, NewSum, {MaxPower, P, Size})
	end.

get_sum([H], [H], Sum) -> Sum + H;
get_sum([Hc|Tc], [Hl|Tl], Sum) -> get_sum(Tc, Tl, Sum + Hc + Hl).

%% part 1

process1(GridSerialNumber) ->
	process1(GridSerialNumber, {1, 1}, #{}, {nil, -45}).

process1(_, {299, 299}, _, Res) -> Res;
process1(GSN, {299, Y}, Map, Res) -> process1(GSN, {1, Y + 1}, Map, Res);
process1(GSN, {X, Y}, Map, {P, Power}) ->
	{NewPower, NewMap} = calculate_size({X, Y}, {X + 2, Y + 2}, 0, Map, GSN),
	case NewPower > Power of
		true -> process1(GSN, {X + 1, Y}, NewMap, {{X, Y}, NewPower});
		false -> process1(GSN, {X + 1, Y}, NewMap, {P, Power})
	end.

calculate_size({_, Y}, {_, N}, Power, Map, _) when Y > N -> {Power, Map};
calculate_size({X, Y}, {M, N}, Power, Map, V) when X > M -> calculate_size({M - 2, Y + 1}, {M, N}, Power, Map, V);
calculate_size({X, Y}, {M, N}, Power, Map, V) ->
	case maps:get({X, Y}, Map, nil) of
		nil -> P = calculate_power({X, Y}, V),
			   calculate_size({X + 1, Y}, {M, N}, Power + P, maps:put({X, Y}, P, Map), V);
		S -> calculate_size({X + 1, Y}, {M, N}, Power + S, Map, V)
	end.

calculate_power({X, Y}, GSN) ->
	RackID = 10 + X,
	Value = (RackID * Y + GSN) * RackID,
	Res = (Value rem 1000) div 100 - 5,
	io:format("~p => ~p~n", [{X, Y}, Res]),
	Res.
