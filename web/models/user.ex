defmodule SocialAppApi.User do
  use SocialAppApi.Web, :model

  schema "users" do
    field :email, :string
    field :auth_provider, :string
    field :first_name, :string
    field :last_name, :string
    field :avatar, :string
    field :access_token, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :auth_provider, :first_name, :last_name, :avatar, :access_token])
    |> validate_required([:email, :auth_provider, :first_name, :last_name, :avatar, :access_token])
  end
end
