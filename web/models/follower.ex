defmodule SocialAppApi.Follower do
  use SocialAppApi.Web, :model

  schema "followers" do
    belongs_to :user, SocialAppApi.User
    belongs_to :follower, SocialAppApi.Follower

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
