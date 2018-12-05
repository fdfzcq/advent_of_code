-module(alchemical_reduction).
%% alchemical reduction
-export([process1/1, process2/1]).

%% part 1
process1(Session) ->
	{ok, Body} = advent_of_code_client:get(5, Session),
	reaction1(binary_to_list(string:trim(Body))).

reaction1([H|T]) -> lists:flatlength(reaction1(T, [H])).

reaction1([], L2) -> L2;
reaction1([H|T], []) -> reaction1(T, [H]);
reaction1([H1|T1], [H2|T2] = L2) ->
	case abs(H1 - H2) == 32 of
		true -> reaction1(T1, T2);
		false -> reaction1(T1, [H1|L2])
	end.

%% part 2
process2(Session) ->
	{ok, Body} = advent_of_code_client:get(5, Session),
	reaction2(binary_to_list(string:trim(Body))).

reaction2(List) -> reaction2(List, $A, lists:flatlength(List)).

reaction2(_, 91, Min) -> Min;
reaction2(List, Char, Min) ->
	Filtered = lists:filter(fun(C) -> C =/= Char andalso C =/= Char + 32 end, List),
	V = reaction1(Filtered),
	case V < Min of
		true -> reaction2(List, Char + 1, V);
		false -> reaction2(List, Char + 1, Min)
	end.
