defmodule SocialAppApi.BlogComment do
  use SocialAppApi.Web, :model

  schema "blog_comments" do
    field :body, :string
    belongs_to :author, SocialAppApi.User
    belongs_to :blog, SocialAppApi.Blog

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body])
    |> validate_required([:body])
  end
end
