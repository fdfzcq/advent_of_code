%%%-------------------------------------------------------------------
%% @doc advent_of_code top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(advent_of_code_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
	SupFlags = #{strategy => one_for_one},
	ChildSpecs =
		[#{id => chronal_calibration,
		   start => {chronal_calibration, start_link, []},
		   modules => [chronal_calibration]}],
    {ok, {SupFlags, ChildSpecs} }.

%%====================================================================
%% Internal functions
%%====================================================================
