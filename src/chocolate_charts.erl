-module(chocolate_charts).
%% Day 14
-export([process/1]).

process(N) -> process1(N, [7,3], 1, 2, 0).

process1(N, List, Elf1, Elf2, Receipts) ->
	if length(List) > N + 10 ->
		lists:sublist(lists:reverse(List), N + 1, 10);
	true ->

		io:format("Elf1: ~p, ELf2: ~p~n", [Elf1, Elf2]),
		Elf1Value = get_value(length(List) - Elf1, List),
		Elf2Value = get_value(length(List) - Elf2, List),
		case Elf1Value + Elf2Value < 10 of
			true ->
				NewList = [Elf1Value + Elf2Value|List],
				process1(N, NewList,
					new_elf_index(Elf1Value, Elf1, NewList),
					new_elf_index(Elf2Value, Elf2, NewList),
					Receipts + 1);
			false ->
				NewList = [(Elf1Value + Elf2Value) rem 10, (Elf1Value + Elf2Value) div 10|List],
				process1(N,
					NewList,
					new_elf_index(Elf1Value, Elf1, NewList),
					new_elf_index(Elf2Value, Elf2, NewList),
					Receipts + 1)
		end
	end.

get_value(0, [H|_]) -> H;
get_value(N, [_|T]) -> get_value(N - 1, T).

new_elf_index(ElfValue, Elf, List) ->
	Value = (ElfValue + 1) rem length(List) + Elf,
	case Value > length(List) of
		true -> Value rem length(List);
		false -> Value
	end.
