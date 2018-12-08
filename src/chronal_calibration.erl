-module(chronal_calibration).
-behaviour(gen_server).
%% aoc day 1 - frequency
-export([count/1, start_link/0, count_all/1, duplicate_freq/1]).
-export([init/1, handle_call/3, handle_cast/2]).

duplicate_freq(Session) ->
	{ok, Body} = advent_of_code_client:get(1, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	List = lists:map(fun(Bin) -> binary_to_list(Bin) end, BinList),
	find_freq(List, [0], List).

find_freq([], Freqs, List) -> find_freq(List, Freqs, List);
find_freq([H|T], Freqs, List) ->
	Res = count(H, hd(Freqs)),
	case lists:member(Res, Freqs) of
		false -> find_freq(T, [Res|Freqs], List);
		true -> Res
	end.

% noserver mode	
count([$+|T], Res) -> Res + to_integer(T);
count([$-|T], Res) -> Res - to_integer(T).

%% part 1

start_link() ->
	gen_server:start_link({local, chronal_calibration}, chronal_calibration, [], []).

init(_) -> {ok, [0]}.

count_all(Session) ->
	{ok, Body} = advent_of_code_client:get(1, Session),
	BinList = string:split(Body, "\n", all),
	process(BinList).

process(BinList) ->
	Fun = fun(Bin) ->
		Input = binary_to_list(Bin),
		count(Input) end,
	lists:map(Fun, BinList).

count([$+|T]) -> gen_server:cast(chronal_calibration, {plus, to_integer(T)});
count([$-|T]) -> gen_server:cast(chronal_calibration, {minus, to_integer(T)});
count(_) -> ignored.

handle_cast({plus, N}, Frequencies) ->
	Frequency = hd(Frequencies),
	%io:format("Current frequency ~p, change of +~p; resulting Frequency ~p~n",
	%	[Frequency, N, N + Frequency]),
	{noreply, [N + Frequency|Frequencies]};
handle_cast({minus, N}, Frequencies) ->
	Frequency = hd(Frequencies),
	%io:format("Current frequency ~p, change of -~p; resulting Frequency ~p~n",
	%	[Frequency, N, Frequency - N]),
	{noreply, [Frequency - N|Frequencies]}.

handle_call(get_state, _, Frequencies) -> {reply, Frequencies, Frequencies};
handle_call(_, _, Frequency) -> Frequency.

to_integer(List) -> to_integer(lists:reverse(List), 0, 0).

to_integer([], _, Result) -> Result;
to_integer([N|T], P, Result) ->
	to_integer(T, P + 1, Result + (N - 48) * trunc(math:pow(10, P))).
