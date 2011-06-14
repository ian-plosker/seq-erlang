-module(seq).
-compile(export_all).

-type seq(T) :: { seq, fun(() -> T), fun(() -> seq(T)) }.
-record(seq, {
    first :: fun(() -> T),
    rest :: fun(() -> seq(T))
}).

-record(seq, {
    first :: fun(() -> T),
    rest :: fun(() -> T)
}).

-spec first(seq(T)) -> T.
first(Seq) -> (Seq#seq.first)().

-spec rest(seq(T)) -> seq(T) | T.
rest(Seq) -> (Seq#seq.rest)().

-spec cons(T, seq(T)) -> seq(T).
cons(N, Seq) ->
    #seq{
        first = fun() -> N end,
        rest = fun() -> Seq end
    }.

-spec nth(integer(), seq(T)) -> T.
nth(1, Seq) -> first(Seq);
nth(N, Seq) when N > 1 -> nth(N - 1, rest(Seq)).

-spec nthrest(integer(), seq(T)) -> seq(T).
nthrest(1, Seq) -> rest(Seq);
nthrest(N, Seq) when N > 1 -> nth(N - 1, rest(Seq)).

-spec from_list([T,...]) -> seq(T).
from_list([H | T]) -> 
    #seq{
        first = fun() -> H end,
        rest = case T of
            [] -> fun() -> undefined end;
            _  -> fun() -> from_list(T) end
        end
    }.

-spec series(integer(), integer()) -> seq(integer()).
series(Start, Interval) ->
    #seq{
        first = fun() -> Start end,
        rest = fun() -> series(Start + Interval, Interval) end
    }.

-spec random_integers(integer(), integer()) -> seq(integer()).
random_integers(Minimum, Maximum) when Minimum < Maximum ->
    RandomInteger = random:uniform(Maximum - Minimum + 1),
    #seq{
        first = fun() -> RandomInteger + Minimum - 1 end,
        rest = fun() -> random_integers(Minimum, Maximum) end
    }.

-spec to_list(seq(T) | [] | T) -> [T].
to_list(undefined) -> [];
to_list(Seq) -> [ first(Seq) | to_list(rest(Seq)) ].

-spec map(fun((T) -> U), seq(T)) -> seq(U).
map(_, undefined) -> undefined;
map(Mapper, Seq) ->
    #seq{
        first = fun() -> Mapper(first(Seq)) end,
        rest = fun() -> map(Mapper, rest(Seq)) end
    }.

-spec fold(fun((T, any()) -> any()), any(), seq(T)) -> any().
fold(_, Acc, undefined) -> Acc;
fold(Fn, Acc, Seq) -> fold(Fn, Fn(first(Seq), Acc), rest(Seq)).


-spec filter(fun((T) -> boolean()), seq(T)) -> seq(T).
filter(_, undefined) -> undefined;
filter(Filter, Seq) ->
    #seq{
        first = fun() ->
            case Filter(first(Seq)) of
                true -> first(Seq);
                false -> 
                    case (FRest = filter(Filter, rest(Seq))) /= undefined of
                        true -> first(FRest);
                        false -> undefined
                    end
            end
        end,
        rest = fun() ->
            case Filter(first(Seq)) of
                true -> filter(Filter, rest(Seq));
                false ->
                    case (FRest = filter(Filter, rest(Seq))) /= undefined of
                        true -> rest(FRest);
                        false -> undefined
                    end
            end
        end
    }.

-spec take(pos_integer(), seq(T)) -> seq(T) | T.
take(_, undefined) -> undefined;
take(0, _) -> undefined;
take(C, Seq) ->
    #seq{
        first = fun() -> first(Seq) end,
        rest = fun() -> take(C - 1, rest(Seq)) end
    }.

-spec zip(fun((T, U) -> V), seq(T), seq(U)) -> seq(V).
zip(_Zipper, _Seq1, undefined) -> undefined;
zip(_Zipper, undefined, _Seq2) -> undefined;
zip(Zipper, Seq1, Seq2) ->
    #seq{
        first = fun() -> Zipper(first(Seq1), first(Seq2)) end,
        rest = fun() -> zip(Zipper, rest(Seq1), rest(Seq2)) end
    }.

-spec zip3(fun((T, U, V) -> W), seq(T), seq(U), seq(V)) -> seq(W).
zip3(_Zipper, _Seq1, _Seq2, undefined) -> undefined;
zip3(_Zipper, _Seq1, undefined, _Seq3) -> undefined;
zip3(_Zipper, undefined, _Seq2, _Seq3) -> undefined;
zip3(Zipper, Seq1, Seq2, Seq3) ->
    #seq{
        first = fun() -> Zipper(first(Seq1), first(Seq2), first(Seq3)) end,
        rest = fun() -> zip3(Zipper, rest(Seq1), rest(Seq2), rest(Seq3)) end
    }.
