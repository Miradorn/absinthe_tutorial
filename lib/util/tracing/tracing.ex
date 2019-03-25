defmodule Util.Tracing do
  @moduledoc """
  Module to work with tracing.

  When starting a Trace, when no trace information is received from an HTTP request or a parent process, use `start_trace/2`.
  If Trace informationt is received use `join/6`.

  Then to start spans use `start_span/2`.
  """

  @doc """
  Starts a root trace.
  This should probable never be used in a HTTP request, since the trace information should be extracted from the request.
  See `Shared.Tracing/join/5` for this use case.
  """
  @spec start_trace(String.t(), Keyword.t()) :: Tapper.Id.t()
  def start_trace(name, tags \\ []) do
    Tapper.Ctx.start(name: name, annotations: to_annotations(tags))
  end

  @doc """
  Finishes the current Trace.
  """
  @spec finish_trace(Keyword.t()) :: :ok
  def finish_trace(tags \\ []) do
    Tapper.Ctx.finish(annotations: to_annotations(tags))
  end

  @doc """
  Joins with a received Trace, originating e.g. from an HTTP request to this Service or from a calling Process.
  """
  @spec join(String.t(), non_neg_integer, non_neg_integer, boolean, Keyword.t()) :: Tapper.Id.t()
  def join(name, trace_id, parent_span_id, sample, tags \\ [], debug \\ false) do
    span_id = Tapper.SpanId.generate()
    {:ok, trace_id} = Tapper.TraceId.parse(trace_id)
    {:ok, parent_span_id} = Tapper.SpanId.parse(parent_span_id)

    Tapper.Ctx.join(trace_id, span_id, parent_span_id, sample, debug,
      name: name,
      annotations: to_annotations(tags)
    )
  end

  @doc """
  Adds a new Child span to the currently running Span.
  """
  @spec start_span(String.t(), Keyword.t()) :: Tapper.Id.t()
  def start_span(name, tags \\ [], component \\ "Tracing") do
    Tapper.Ctx.start_span(name: name, local: component, annotations: to_annotations(tags))
  end

  @doc """
  Finishes the current span.
  """
  @spec finish_span(Keyword.t()) :: Tapper.Id.t()
  def finish_span(tags \\ []) do
    Tapper.Ctx.finish_span(annotations: to_annotations(tags))
  end

  defp to_annotations(tags), do: Enum.map(tags, fn {name, value} -> Tapper.tag(name, value) end)
end
