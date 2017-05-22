defmodule SocialAppApi.Media do
  use SocialAppApi.Web, :model

  schema "media" do
    field :name, :string
    field :description, :string
    field :url, :string
    belongs_to :uploader, SocialAppApi.Uploader

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :url])
    |> validate_required([:url])
  end
end
