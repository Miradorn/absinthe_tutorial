defmodule BlogWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation
  alias BlogWeb.Resolvers

  @desc "A blog post"
  object :post do
    field(:id, :id)

    field :title, :string do
      resolve(&Resolvers.Content.format_title/3)
    end

    field(:body, :string)
    field(:author, :user)
    field(:published_at, :naive_datetime)
  end
end
