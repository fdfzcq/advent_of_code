-module(frequency).
-behaviour(gen_server).
%% aoc day 1 - frequency
-export([count/1, start_link/0]).
-export([init/1, handle_call/3, handle_cast/2]).

start_link() ->
	gen_server:start_link({local, frequency}, frequency, [], []).

init(_) -> {ok, 0}.

count([$+|T]) -> gen_server:cast(frequency, {plus, to_intger(T)});
count([$-|T]) -> gen_server:cast(frequency, {minus, to_intger(T)});
count(_) -> ignored.

handle_cast({plus, N}, Frequency) ->
	io:format("Current frequency ~p, change of +~p; resulting Frequency ~p~n",
		[Frequency, N, N + Frequency]),
	{noreply, N + Frequency};
handle_cast({minus, N}, Frequency) ->
	io:format("Current frequency ~p, change of -~p; resulting Frequency ~p~n",
		[Frequency, N, Frequency - N]),
	{noreply, Frequency - N}.

handle_call(_, _, Frequency) -> Frequency.

to_intger(List) -> to_intger(lists:reverse(List), 0, 0).

to_intger([], _, Result) -> Result;
to_intger([N|T], P, Result) -> to_intger(T, P + 1, Result + (N - 48) * trunc(math:pow(10, P))).
