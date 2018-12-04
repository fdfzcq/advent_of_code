-module(repose_record).
%% Day 4: repose record
-export([process/1]).

-record(record, {date, time, guard_id, is_awake}).

process(Session) ->
	{ok, Body} = advent_of_code_client:get(4, Session),
	BinList = string:split(string:trim(Body), "\n", all),
	RecordList = lists:map(fun(Bin) -> to_record(Bin) end, BinList),
	SortFun = fun(R1, R2) ->
		case R1#record.date == R2#record.date of
			true -> R1#record.time < R2#record.time;
			_ -> R1#record.date =< R2#record.date
		end
	end,
	SortedList = lists:sort(SortFun, RecordList),
	List = add_guard_id(SortedList),
	GuardList = maps:to_list(to_guards(List)),
	SortFun2 = fun({_, T1}, {_, T2}) -> lists:sum(T1) > lists:sum(T2) end,
	SortedGuards = lists:sort(SortFun2, GuardList),
	{Guard, TList} = hd(SortedGuards),
	Guard*get_index(TList, lists:max(TList), 0).

get_index([H|_], H, I) -> I;
get_index([_|T], N, I) -> get_index(T, N, I + 1).

to_guards([H|T]) -> to_guards(T, H, #{}).

to_guards([], _, Map) -> Map;
to_guards([R = #record{guard_id=Gid, is_awake=true, time=Time2, date=Date}|T],
	#record{guard_id=Gid, is_awake=false, time=Time1, date=Date}, Map) ->
	MinList = maps:get(Gid, Map, lists:duplicate(60, 0)),
	NewMinList = incr(MinList, Time1, Time2),
	to_guards(T, R, maps:put(Gid, NewMinList, Map));
to_guards([R|T], #record{guard_id=Gid, is_awake=false, time=Time}, Map) ->
	MinList = maps:get(Gid, Map, lists:duplicate(60, 0)),
	NewMinList = incr(MinList, Time, 59),
	to_guards(T, R, maps:put(Gid, NewMinList, Map));
to_guards([H|T], _R, Map) -> to_guards(T, H, Map).

incr(MinList, _Time, _Time) -> MinList;
incr(MinList, Time1, Time2) ->
	NewList = incr(MinList, Time1, 0, []),
	incr(NewList, Time1 + 1, Time2).

incr([], _, _, List) -> lists:reverse(List);
incr([H|T], Time, Time, List) -> incr(T, Time, Time + 1, [H + 1|List]);
incr([H|T], Time, N, List) -> incr(T, Time, N + 1, [H|List]).

add_guard_id([R|T]) -> add_guard_id(T, R#record.guard_id, []).

add_guard_id([], H, List) -> lists:reverse(List);
add_guard_id([H = #record{guard_id=undefined}|T], R, List) ->
	NewRecord = H#record{guard_id=R#record.guard_id},
	add_guard_id(T, NewRecord, [NewRecord|List]);
add_guard_id([H|T], _, List) ->
	add_guard_id(T, H, [H|List]).

to_record(Bin) ->
	Str = binary_to_list(Bin),
	StrList = string:split(string:strip(Str, left, $[), "]"),
	DateTimeList = string:split(hd(StrList), "\s"),
	Date = hd(DateTimeList),
	Time = to_time(lists:nth(2, DateTimeList)),
	Msg = lists:nth(2, StrList),
	to_record(Msg, #record{date=Date, time=Time}).

to_record(" falls asleep", Record) -> Record#record{is_awake=false};
to_record(" wakes up", Record) -> Record#record{is_awake=true};
to_record(Str, Record) ->
	StrList = string:split(Str, "\s", all),
	Id = list_to_integer(string:strip(lists:nth(3, StrList), left, $#)),
	Record#record{is_awake=true, guard_id=Id}.

to_time(TimeStr) ->
	TimeList = string:split(TimeStr, ":"),
	Hour = list_to_integer(hd(TimeList)),
	Minute = list_to_integer(lists:nth(2, TimeList)),
	case Hour of
		0 -> Minute;
		_ -> 0
	end.
