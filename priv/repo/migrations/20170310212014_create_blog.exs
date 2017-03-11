defmodule SocialAppApi.Repo.Migrations.CreateBlog do
  use Ecto.Migration

  def change do
    create table(:blogs) do
      add :title, :string
      add :body, :string
      add :author_id, :integer

      timestamps()
    end

  end
end
