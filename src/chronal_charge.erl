-module(chronal_charge).
%% day 11: chronal charge
-export([process1/1, calculate_size/5, process2/1]).

process2(GSN) ->
	process2(GSN, 299, {nil, -45, 0}, #{}).

process2(_, 0, {P, _, Size}, _) -> {P, Size};
process2(GSN, L, {P, Power, Size}, Map) ->
	case (L + 1) * (L + 1) * 4 < Power of
		true -> {P, Size};
		false -> {NewMap, {NewP, NewPower}} = process1(GSN, {1, 1}, Map, {P, Power}, L),
				 case NewPower > Power of
				 	true -> process2(GSN, L - 1, {NewP, NewPower, (L + 1) * (L + 1)}, NewMap);
				 	false -> process2(GSN, L - 1, {P, Power, Size}, NewMap)
				 end
	end.

process1(GridSerialNumber) ->
	process1(GridSerialNumber, {1, 1}, #{}, {nil, -45}, 2).

process1(_, {X, Y}, Map, Res, L) when L + X > 300, L + Y > 300 -> {Map, Res};
process1(GSN, {X, Y}, Map, Res, L) when L + X > 300 -> process1(GSN, {1, Y + 1}, Map, Res, L);
process1(GSN, {X, Y}, Map, {P, Power}, L) ->
	{NewPower, NewMap} = calculate_size({X, Y}, {X + L, Y + L}, 0, Map, GSN, L),
	case NewPower > Power of
		true -> process1(GSN, {X + 1, Y}, NewMap, {{X, Y}, NewPower}, L);
		false -> process1(GSN, {X + 1, Y}, NewMap, {P, Power}, L)
	end.

calculate_size({_, _}, {M, N}, Power, Map, _, _) when M > 299; N > 299 -> {Power, Map};
calculate_size({_, Y}, {_, N}, Power, Map, _, _) when Y > N -> {Power, Map};
calculate_size({X, Y}, {M, N}, Power, Map, V, L) when X > M -> calculate_size({M - L, Y + 1}, {M, N}, Power, Map, V);
calculate_size({X, Y}, {M, N}, Power, Map, V, L) ->
	case maps:get({X, Y}, Map, nil) of
		nil -> P = calculate_power({X, Y}, V),
			   calculate_size({X + 1, Y}, {M, N}, Power + P, maps:put({X, Y}, P, Map), V, L);
		S -> calculate_size({X + 1, Y}, {M, N}, Power + S, Map, V, L)
	end.

calculate_power({X, Y}, GSN) ->
	RackID = 10 + X,
	Value = (RackID * Y + GSN) * RackID,
	Res = (Value rem 1000) div 100 - 5,
	io:format("~p => ~p~n", [{X, Y}, Res]),
	Res.
