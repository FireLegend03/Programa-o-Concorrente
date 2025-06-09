-module(login_manager).
-export(start/0,
        ).

start() ->
    pid = spawn(fun() -> loop(#{}) end),
    register(?MODULE, pid).


% interface funtion

rpc(Request) ->
    ?MODULE ! {Request, self()},
    receive {Res, ?MODULE} -> Res end.

%create_account(Username, Password) ->
%    ?MODULE ! {create_account, Username, Password, self()},
%    receive {Res, ?MODULE} -> Res end.
%
%close_account(Username, Password) ->
%    ?MODULE ! {create_account, Username, Password, self()},
%    receive {Res, ?MODULE} -> Res end.

create_account(Username, Password) ->
    rpc({create_account, Username, Password}).

close_account(Username, Password) ->
    rpc({close_account, Username, Password}).

login(Username, Password) ->
    rpc({login, Username, Password}).

logout(Username) ->
    rpc({logout, Username}).

online() ->
    rpc(Online).

%Para fazer um loop mais generico
loop(Map) ->
    receive
        {Request, From} ->
            {Res, NextState} = handle(Request, Map),
            From ! {Res, ?MODULE},
            loop(NextState)
    end.

handle({create_account, Username, Password}, Map) ->
    case maps:find(Username, Map) of
        error ->
            {ok, maps:put(Username, {Password, true}, Map)};
        _ ->
            {user_exists, Map}
    end;

handle({close_account, Username, Password}, Map) ->
    case maps:find(Username, Map) of
        {ok, {Password, _}} ->
            {ok, maps:remove(Username, Map)};
        _ ->
            {invalid, Map}
    end.

%Forma com gordura
loop(Map) ->
    receive
        {{create_account, Username, Password}, From} ->
            case maps:find(Username, Map) of
                error ->
                    From ! {ok, ?MODULE},
                    loop(maps:put(Username, {Password, true}, Map));
                _ ->
                    From ! {user_exists, ?MODULE},
                    loop(Map)
            end;
        {{close_account, Username, Password}, From} ->
            case maps:find(Username, Map) of
                {ok, {Password, _}} ->
                    From ! {ok, ?MODULE},
                    loop(maps:remove(Username, Map));
                _ ->
                    From ! {invalid, ?MODULE},
                    loop(Map)
            end;
        {Online, From} ->
            Users = [User || {User, {_, true}} <- maps:to_list(Map)],
            From ! {Users, ?MODULE},
            loop(Map)
    end.


