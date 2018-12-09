-module(marble_mania).
%% Day 9
-export([process1/2]).
-record(state, {player, current_marble, counter_list, list, no_of_players, last_marble, player_score}).

process1(NoOfPlayers, LastMarble) ->
	FinalState = get_winner_score(#state{
		player = 1,
		current_marble = 0,
		no_of_players = NoOfPlayers,
		last_marble = LastMarble,
		counter_list = [],
		list = [],
		player_score = #{}
	}),
	PlayerScoreList = maps:to_list(FinalState#state.player_score),
	{_, S} = hd(lists:sort(fun({_, S1}, {_, S2}) -> S1 > S2 end, PlayerScoreList)),
	S.

get_winner_score(#state{current_marble = N, last_marble = M} = State) when N > M -> State;
get_winner_score(State) ->
	get_winner_score(State, State#state.current_marble rem 23).

get_winner_score(State = #state{
	player = P, player_score = PS, counter_list = CL, list = L, current_marble = M
	}, 0) when M =/= 0 ->
	{N_CL, N_L} = place_marble(M, CL, L),
	%io:format("old cl: ~p, old l: ~p~n", [N_CL, N_L]),
	{{NewCL, NewL}, Bonus} = get_bonus_score(N_CL, N_L),
	%io:format("new cl: ~p, new l: ~p, bonus: ~p~n", [NewCL, NewL, Bonus]),
	NewPlayerScore = maps:put(P, maps:get(P, PS, 0) + M + Bonus, PS),
	NextPlayer = next_player(P, State#state.no_of_players),
	NextMarble = M + 1,
	get_winner_score(State#state{
		player = NextPlayer,
		current_marble = NextMarble,
		player_score = NewPlayerScore,
		counter_list = NewCL,
		list = NewL
	});
get_winner_score(State = #state{player = P, current_marble = M, counter_list = CL, list = L}, _) ->
	{NewCL, NewL} = place_marble(M, CL, L),
	NextPlayer = next_player(P, State#state.no_of_players),
	NextMarble = M + 1,
	get_winner_score(State#state{
		player = NextPlayer,
		current_marble = NextMarble,
		counter_list = NewCL,
		list = NewL
	}).

place_marble(M, CL, L) -> place_marble(M, CL, L, 1).

place_marble(0, [], [], _) -> {[0], []};
place_marble(M, CL, L, 0) ->
	NewCL = lists:reverse([M|lists:reverse(CL)]),
	{NewCL, L};
place_marble(M, [H|T], [], N) ->
	place_marble(M, [H], T, N - 1);
place_marble(M, CL, [H|T], N) ->
	NewCL = lists:reverse([H|lists:reverse(CL)]),
	place_marble(M, NewCL, T, N - 1).

get_bonus_score(CL, L) -> get_bonus_score(tl(lists:reverse(CL)), lists:reverse(L), 8, []).

get_bonus_score([], L, N, R) ->
	get_bonus_score(append(L,lists:reverse(R)), [], N, []);
get_bonus_score([H|T], List, 0, [HR|TR]) ->
	{{lists:reverse([HR|T]), append(TR, lists:reverse(List))}, H};
get_bonus_score([H|T], List, N, R) ->
	get_bonus_score(T, List, N - 1, [H|R]).

next_player(N, N) -> 1;
next_player(P, _) -> P + 1.

append(L1, L2) -> do_append(lists:reverse(L1), L2).

do_append(L, []) -> lists:reverse(L);
do_append(L1, [H|T]) -> do_append([H|L1], T).
