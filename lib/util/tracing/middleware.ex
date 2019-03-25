defmodule Util.Tracing.Middleware do
  @moduledoc false

  @behaviour Absinthe.Middleware

  alias Util.Tracing

  def call(resolution, :before) do
    resolution
    |> Absinthe.Resolution.path()
    |> Enum.join(".")
    |> Tracing.start_span()

    resolution
  end

  def call(resolution, :after) do
    Tracing.finish_span()

    resolution
  end
end
