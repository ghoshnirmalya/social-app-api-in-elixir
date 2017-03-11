defmodule SocialAppApi.Blog do
  use SocialAppApi.Web, :model

  schema "blogs" do
    field :title, :string
    field :body, :string
    field :author_id, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body, :author_id])
    |> validate_required([:title, :body, :author_id])
  end
end
