-module(the_stars_align).
%% Day 10
-export([process/1, plot/1]).

process(Session) ->
	{ok, Body} = advent_of_code_client:get(10, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	List = lists:map(fun(Bin) -> parse(Bin) end, BinList),
	start(List, 10239, 10241).

start(_, Second, Second) -> ok;
start(List, Second, LastSecond) ->
	plot(calculate_velocity(List, Second, [])),
	io:format("second: ~p ~n", [Second]),
	start(List, Second + 1, LastSecond).

calculate_velocity([], _, List) -> List;
calculate_velocity([{XP, YP, XV, YV}|T], Second, List) ->
	calculate_velocity(T, Second, [{XP + XV * Second, YP + YV * Second}|List]).

parse(Bin) ->
	Str = binary_to_list(Bin),
	{match, L} =
		re:run(Str, ".*<(?<xp>[\\s-0-9]+),(?<yp>[\\s-\\d]+)>.*<(?<xv>[\\s-\\d]+),(?<yv>[\\s-\\d]+)>", [{capture, [xp, yp, xv, yv], list}]),
	[XP, YP, XV, YV] = lists:map(fun(S) -> list_to_integer(string:trim(S)) end, L),
	{XP, YP, XV, YV}.

plot(List) ->
	%io:format("~p ~n", [List]),
	ListX = lists:map(fun({X, _}) -> X end, List),
	ListY = lists:map(fun({_, Y}) -> Y end, List),
	X_MIN = lists:min(ListX),
	X_MAX = lists:max(ListX),
	Y_MIN = lists:min(ListY),
	Y_MAX = lists:max(ListY),
	SortedList = lists:sort(fun({X1, Y1}, {X2, Y2}) ->
		case Y1 == Y2 of
			true -> X1 < X2;
			false -> Y1 < Y2
		end
	end, List),
	plot(SortedList, X_MIN, Y_MIN, {X_MIN, X_MAX}, {Y_MIN, Y_MAX}, "").

plot(_, _, Y, _, {_, Y_MAX}, _) when Y > Y_MAX -> ok;
plot(List, X, Y, {X_MIN, X_MAX}, {Y_MIN, Y_MAX}, Res) when X > X_MAX ->
	io:format("~p~n", [lists:reverse(Res)]),
	%io:format("~p~n", [Res]),
	% case length(lists:filter(fun(P) -> P == $# end, Res)) > 1 of
	% 	true -> io:format("~p~n", [lists:reverse(Res)]);
	% 	false -> ok
	% end,
	plot(List, X_MIN, Y + 1, {X_MIN, X_MAX}, {Y_MIN, Y_MAX}, "");
plot(List, X, Y, {X_MIN, X_MAX}, {Y_MIN, Y_MAX}, Res) ->
	case lists:member({X, Y}, List) of
		true -> plot(List, X + 1, Y, {X_MIN, X_MAX}, {Y_MIN, Y_MAX}, [$#|Res]);
		false -> plot(List, X + 1, Y, {X_MIN, X_MAX}, {Y_MIN, Y_MAX}, [$.|Res])
	end.
