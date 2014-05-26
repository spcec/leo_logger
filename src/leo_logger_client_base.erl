%%======================================================================
%%
%% Leo Logger
%%
%% Copyright (c) 2012-2014 Rakuten, Inc.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% ---------------------------------------------------------------------
%% Leo Logger - Client (access-log)
%% @doc
%% @end
%%======================================================================
-module(leo_logger_client_base).

-author('Yosuke Hara').

-include("leo_logger.hrl").
-include_lib("eunit/include/eunit.hrl").

-export([new/4, format/2, append/1, sync/1]).

-define(MAX_MSG_BODY_LEN, 4096).

%%--------------------------------------------------------------------
%% API
%%--------------------------------------------------------------------
%% @doc Create loggers for message logs
%%
-spec new(atom(), atom(), string(), string()) ->
             ok.
new(LogGroup, LogId, RootPath, LogFileName) ->
    AppenderMod = leo_logger_appender_file,
    ok = leo_logger_util:new(
           LogId, ?LOG_APPENDER_FILE, AppenderMod, RootPath, LogFileName),
    ok = leo_logger_util:add_appender(LogGroup, LogId),
    ok.


%% @doc Format a log message
%%
-spec format(atom(), #message_log{}) ->
             string().
format(Appender, Log) ->
    leo_logger_appender_file:format(Appender, Log).


%% @doc Append a message to a file
%%
-spec append({atom(), #message_log{}}) ->
             ok.
append({LogId, Log}) ->
    case whereis(LogId) of
        undefined ->
            ok;
        _Pid ->
            leo_logger_server:append(?LOG_APPEND_SYNC, LogId, Log, 0)
    end.


%% @doc Sync a log file
%%
-spec sync(atom|#logger_state{}) ->
             ok | {error, _}.
sync(LogId) when is_atom(LogId) ->
    leo_logger_server:sync(LogId);
sync(_L) ->
    ok.