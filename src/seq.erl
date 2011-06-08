-module(seq).
-compile(export_all).

-type seq(T) :: { seq, fun(() -> T), fun(() -> seq(T)) }.

-spec first(seq(T)) -> T.
first({ seq, First, _ }) -> First().

-spec rest(seq(T)) -> seq(T) | T.
rest({ seq, _, Rest }) -> Rest().

-spec cons(T, seq(T)) -> seq(T).
cons(N, Seq) ->
    {
        seq,
        fun() -> N end,
        fun() -> Seq end
    }.

-spec from_list([T,...]) -> seq(T).
from_list([H | T]) -> 
    {
        seq,
        fun() -> H end,
        case T of
            [] -> fun() -> undefined end;
            _  -> fun() -> from_list(T) end
        end
    }.

-spec series(integer(), integer()) -> seq(integer()).
series(Start, Interval) ->
    {
        seq,
        fun() -> Start end,
        fun() -> series(Start + Interval, Interval) end
    }.

-spec to_list(seq(T) | [] | T) -> [T].
to_list({ seq, First, Rest }) -> [ First() | to_list(Rest()) ];
to_list(undefined) -> [].

-spec map(fun((T) -> U), seq(T)) -> seq(U).
map(_, undefined) -> undefined;
map(Map, { seq, Head, Rest }) ->
    {
        seq,
        fun() -> Map(Head()) end,
        fun() -> map(Map, Rest()) end
    }.

-spec fold(fun((T, any()) -> any()), any(), seq(T)) -> any().
fold(_, Acc, undefined) -> Acc;
fold(Fn, Acc, { seq, Head, Rest }) -> fold(Fn, Fn(Head(), Acc), Rest()).


-spec filter(fun((T) -> boolean()), seq(T)) -> seq(T).
filter(_, undefined) -> undefined;
filter(Filter, { seq, First, Rest }) ->
    {
        seq,
        fun() ->
            case Filter(First()) of
                true -> First();
                false -> 
                    case (FRest = filter(Filter, Rest())) /= undefined of
                        true -> first(FRest);
                        false -> undefined
                    end
            end
        end,
        fun() ->
            case Filter(First()) of
                true -> filter(Filter, Rest());
                false ->
                    case (FRest = filter(Filter, Rest())) /= undefined of
                        true -> rest(FRest);
                        false -> undefined
                    end
            end
        end
    }.

-spec take(pos_integer(), seq(T)) -> seq(T) | T.
take(_, undefined) -> undefined;
take(0, _) -> undefined;
take(C, {seq, First, Rest }) ->
    {
        seq,
        fun()  -> First() end,
        fun()  -> take(C - 1, Rest()) end
    }.
