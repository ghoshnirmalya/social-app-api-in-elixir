defmodule SocialAppApi.Blog do
  use SocialAppApi.Web, :model

  schema "blogs" do
    field :title, :string
    field :body, :string
    belongs_to :author, SocialAppApi.Author

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
  end
end
