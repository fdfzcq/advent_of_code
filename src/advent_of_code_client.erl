-module(advent_of_code_client).
%% simple client to communicate with aoc
-export([start_link/0]).
-export([get/2]).

start_link() -> ok.

get(Day,Session) ->
    Method = get,
    DayBin = list_to_binary(integer_to_list(Day)),
    SessionBin = list_to_binary(Session),
	URL = <<"https://adventofcode.com/2018/day/",DayBin/binary,"/input">>,
    Headers = [{<<"Cookie">>, <<"session=",SessionBin/binary>>}],
    Payload = <<>>,
    Options = [],
    {ok, _, _, ClientRef} =
    	hackney:request(Method, URL,Headers, Payload,Options),
    hackney:body(ClientRef).
