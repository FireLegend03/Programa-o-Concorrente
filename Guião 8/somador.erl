-module(somador).
-export([start/1, stop/1]).

start(Port) -> spawn(fun() -> server(Port) end).

stop(Server) -> Server ! stop.

server(Port) ->
    {ok, LSock} = gen_tcp:listen(Port, [{packet, line}, {reuseaddr, true}]),
    spawn(fun() -> acceptor(LSock) end),
    receive stop -> ok end.

acceptor(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    spawn(fun() -> acceptor(LSock) end),
    user(Sock, 0).

user(Sock, Sum) ->
    receive
        {tcp, _, Data} ->
            {N, _} = string:to_integer(Data),
            NewSum = Sum + N,
            %gen_tcp:send(Sock, [integer_to_list(NewSum), "\n"]),
            gen_tcp:send(Sock, io_lib:format("~p~n", [NewSum])),
            user(Sock, NewSum);
        {tcp_closed, _} ->
            ok;
        {tcp_error, _, Reason} ->
            ok
    end.