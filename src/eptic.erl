%% The contents of this file are subject to the Erlang Web Public License,
%% Version 1.0, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Web Public License along with this software. If not, it can be
%% retrieved via the world wide web at http://www.erlang-consulting.com/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% The Initial Developer of the Original Code is Erlang Training & Consulting
%% Ltd. Portions created by Erlang Training & Consulting Ltd are Copyright 2008,
%% Erlang Training & Consulting Ltd. All Rights Reserved.

%%%-------------------------------------------------------------------
%%% File    : eptic.erl
%%% @author Martin Carlson <martin@erlang-consulting.com>
%%% @doc API for all dictionary, cache and template functions.
%%% @end
%%%-------------------------------------------------------------------
-module(eptic).
-behaviour(application).
-behaviour(supervisor).

%% API
-export([start/2, stop/1, reload/0]).
-export([init/1]).

%% s_dict
-export([fget/1, fget/2, fget/3, fset/2, fset/3, finsert/3]).
%% s_cache
-export([read_file/1]).

%%====================================================================
%% API for application
%%====================================================================
%% @hidden
start(_, _) ->
    start_link().

%% @hidden
stop(_) ->
    ok.

%%
%% @spec reload() -> none()
%% @doc Reloads the configuration and compiles all the changed files.
%%
-spec(reload/0 :: () -> none()).	     
reload() ->
	make:all([load]),
	e_dispatcher:reinstall(),
        e_conf:install().

%%====================================================================
%% API for s_dict
%%====================================================================
%% @see e_dict:fget/1
fget(Key) ->
    e_dict:fget(Key).
    
%% @see e_dict:fget/2
fget(List, Key) ->
    e_dict:fget(List, Key).

%% @see e_dict:fget/3
fget(List, Key, Validator) ->
    e_dict:fget(List, Key, Validator).

%% @see e_dict:fset/2
fset(Key, Value) ->
    e_dict:fset(Key, Value).

%% @see e_dict:fset/3
fset(List, Key, Value) ->
    e_dict:fset(List, Key, Value).

%% @see e_dict:finsert/3
finsert(List, Key, Value) ->
    e_dict:finsert(List, Key, Value).

%%====================================================================
%% API for s_cache
%%====================================================================
%% @see e_cache:read_file/1
read_file(File) ->
    e_cache:read_file(File).

%%====================================================================
%% Internal functions
%%====================================================================
start_link() ->
    lists:foreach(fun(Mod) ->
			  Mod:install()
		  end, [e_dispatcher, e_conf, e_lang]),

    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%====================================================================
%% Supervisor functions
%%====================================================================
init([]) ->
    Dict = {e_dict, {e_dict, start_link, []},
	    permanent, 2000, worker, dynamic},
    Session = {e_session, {e_session, start_link, []},
	       permanent, 2000, worker, dynamic},
    {ok, {{one_for_one, 1, 10}, [Dict,Session]}}.

%%====================================================================
%% Internal functions
%%====================================================================
