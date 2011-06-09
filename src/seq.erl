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

-spec nth(integer(), seq(T)) -> T.
nth(1, Seq) -> first(Seq);
nth(N, Seq) -> nth(N - 1, rest(Seq)).

-spec nthrest(integer(), seq(T)) -> seq(T).
nthrest(1, Seq) -> rest(Seq);
nthrest(N, Seq) -> nth(N - 1, rest(Seq)).

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

-spec random_integers(integer(), integer()) -> seq(integer()).
random_integers(Minimum, Maximum) ->
    RandomInteger = random:uniform(Maximum - Minimum + 1),
    {
        seq,
        fun() -> RandomInteger + Minimum - 1 end,
        fun() -> random_integers(Minimum, Maximum) end
    }.

-spec to_list(seq(T) | [] | T) -> [T].
to_list({ seq, First, Rest }) -> [ First() | to_list(Rest()) ];
to_list(undefined) -> [].

-spec map(fun((T) -> U), seq(T)) -> seq(U).
map(_, undefined) -> undefined;
map(Mapper, { seq, Head, Rest }) ->
    {
        seq,
        fun() -> Mapper(Head()) end,
        fun() -> map(Mapper, Rest()) end
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
        fun() -> First() end,
        fun() -> take(C - 1, Rest()) end
    }.

-spec zip(fun((T, U) -> V), seq(T), seq(U)) -> seq(V).
zip(_Zipper, _Seq1, undefined) -> undefined;
zip(_Zipper, undefined, _Seq2) -> undefined;
zip(Zipper, Seq1, Seq2) ->
    {
        seq,
        fun() -> Zipper(first(Seq1), first(Seq2)) end,
        fun() -> zip(Zipper, rest(Seq1), rest(Seq2)) end
    }.

-spec zip3(fun((T, U, V) -> W), seq(T), seq(U), seq(V)) -> seq(W).
zip3(_Zipper, _Seq1, _Seq2, undefined) -> undefined;
zip3(_Zipper, _Seq1, undefined, _Seq3) -> undefined;
zip3(_Zipper, undefined, _Seq2, _Seq3) -> undefined;
zip3(Zipper, Seq1, Seq2, Seq3) ->
    {
        seq,
        fun() -> Zipper(first(Seq1), first(Seq2), first(Seq3)) end,
        fun() -> zip3(Zipper, rest(Seq1), rest(Seq2), rest(Seq3)) end
    }.
