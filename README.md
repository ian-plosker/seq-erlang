Lazy sequences for Erlang
=========================

This library provides continuation-based lazy sequences for Erlang. A*seq* is defined as a 3-tuple containing the atom `seq`, a continuation returning the first value, and a continuation returning either a *seq* with the rest of the sequence or the atom `undefined` to signify the end of the sequence.
