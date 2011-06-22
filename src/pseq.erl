-module(pseq).
-export([run/1]).

-import(seq, [create/2, first/1, rest/1]).

%-spec run(seq(T)) -> seq(T).
%% @doc Runs through the sequence in parallel
run(Seq) ->
    Pid = self(),
    spawn_link(fun() -> run_helper(Seq, Pid, 0) end),
    collect(-1, 0).

collect(OutCount, InCount) ->
    case OutCount =:= InCount of
        true  -> undefined;
        false ->
            receive
                { count, Count } -> collect(Count, InCount);
                { Val } ->
                    seq:create(
                        fun() -> Val end,
                        fun() -> collect(OutCount, InCount + 1) end
                    )
            end
    end.

run_helper(undefined, ReturnPid, Count) -> 
    ReturnPid ! { count, Count };
run_helper({seq, First, Rest}, ReturnPid, Count) ->
    spawn_link(fun() -> run_helper(Rest(), ReturnPid, Count + 1) end),
    ReturnPid ! { First() }.
