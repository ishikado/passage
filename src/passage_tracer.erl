-module(passage_tracer).

-export([start/2, start/3]).
-export([get_sampler/1]).
-export([make_span_context_state/2]).

-export_type([start_option/0]).

-type start_option() :: {sampler, passage_sampler:sampler()}
                      | {reporters, [passage_reporter:reporter()]}.

-spec make_span_context_state(passage_span:span(), passage:baggage_items()) ->
                                     passage_span_context:state().
make_span_context_state(Span, BaggageItems) ->
    Tracer = passage_span:get_tracer(Span),
    Module = passage_registry:get_tracer_module(Tracer),
    Module:make_span_context_state(Span, BaggageItems).

-spec get_sampler(passage:tracer_id()) -> passage_sampler:sampler().
get_sampler(Tracer) ->
    passage_registry:get_sampler(Tracer).

-spec start(passage:tracer_id(), module()) -> ok | {error, Reason :: term()}.
start(TracerId, Module) ->
    start(TracerId, Module, []).

-spec start(passage:tracer_id(), module(), [start_option()]) ->
                   ok | {error, Reason :: term()}.
start(TracerId, Module, Options) ->
    Sampler = proplists:get_value(sampler, Options, passage_sampler_all:new()),
    Reporters = proplists:get_value(reporters, Options, []),

    %% TODO: s/passage_registry/passage_tracer_registry/
    passage_registry:register_tracer(TracerId, Module, Sampler, Reporters).
