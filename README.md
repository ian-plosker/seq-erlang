Lazy sequences for Erlang
=========================

This library provides continuation-based lazy sequences for Erlang. The
purpose of this library is provide a simple way to process sequences of
data lazily and in a compositional fashion. To achieve that goal, *seq*
have a simple definition, so that sequential data can easily be boxed
inside of a *seq*. Helper methods exist to get the **first**, the **rest**, and to **cons** onto a *seq*. Further, once boxed inside a *seq* there are many
*seq* to *seq* operations that allow for lazy, compositional processing.
These operations include **map**, **filter**, **take**, **fold**, and **zip**.
Additionally, **to_list** is defined if the sequence must be immediately
materialized. Finally, **from_list** and **series** are provided as
examples of how one might construct a *seq*.

A *seq* is defined as a 3-tuple containing the atom `seq`, a continuation
returning the first value, and a continuation returning either a *seq*
with the rest of the sequence or the atom `undefined` to signify the end
of the sequence.


It is simple to create *seq* in your application. To read a file line by
line using a *seq*, one might be the follow:

    -spec file_line_seq(iolist()) -> seq:seq() | undefined.
    %% @doc Creates a seq out of a file with each line of the file as it's elements.
    file_line_seq(IO) ->
        case file:read_line(IO) of
            { ok, Data } ->
                {
                    seq,
                    fun() -> Data end,
                    fun() -> file_line_seq(IO) end
                };
            eof -> undefined
        end.

Then the file could be consumed as so:

    process_lines(FileName) -> 
        { ok, IO } = file:open(FileName, [read, raw, { read_ahead, 512 }]),

        Seq = file_line_seq(IO),

        seq:fold(fun(Data, Count) ->
            spawn(fun() -> process_line(Data) end),
            Count + 1
        end, 0, Seq).

If one wanted to express a series as a *seq*, one would do the
following:

    -spec series(integer(), integer()) -> seq(integer()).
    series(Start, Interval) ->
        {
            seq,
            fun() -> Start end,
            fun() -> series(Start + Interval, Interval) end
        }.
