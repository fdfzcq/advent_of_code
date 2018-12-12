-module(subterranean_sustainability).
%% Day 12 game of plants
-export([process1/1]).

process1(Session) ->
	{ok, Body}  = advent_of_code_client:get(Session),
	BinList = string:split(string:trim(Body), "\n", all),
	StateStr = binary_to_list(hd(BinList)),
	{match, [State]} = re:run(StateStr, "initial state: (?<state>.*)", [{capture, [state], list}]),
	Rules = lists:map(fun(B) ->
		{match, [Pattern, Result]} =
			re:run(binary_to_list(B), "(?<pattern>[.#]+) => (?<result>[.#])", [{capture, [pattern, result], list}]),
		{Pattern, Result}	 
	end, tl(tl(BinList))),
	process1("....." ++ State ++ ".....", Rules, 0).

process1(State, Rules, 0) ->
	process1(State, Rules, 0, [], -3).

process1(State, _, 500, _, _) -> 
   get_res(State, -5, 0);
process1(State = [_|TS], Rules, N, List, Index) ->
	case length(State) > 4 of
		true -> {A, _} = lists:split(5, State),
				Res = find_res(A, Rules),
				case Res == $# of
					true ->
						process1(TS, Rules, N, [Res|List], Index + 1);
					_ -> process1(TS, Rules, N, [Res|List], Index + 1)
				end;
		false ->
			NewState = ".." ++ lists:reverse(List) ++ State,
			io:format("~p: ~p~n", [N, get_res(NewState, -5, 0)]),
			process1(NewState, Rules, N + 1, [], -3)
	end.

find_res(_, []) -> $.;
find_res(P, [{P, [R]}|_]) -> R;
find_res(P, [_|T]) -> find_res(P, T).

get_res([], _, Sum) -> Sum;
get_res([$#|T], N, Sum) -> get_res(T, N + 1, Sum + N);
get_res([_|T], N, Sum) -> get_res(T, N + 1, Sum).
