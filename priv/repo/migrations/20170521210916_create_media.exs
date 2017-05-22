defmodule SocialAppApi.Repo.Migrations.CreateMedia do
  use Ecto.Migration

  def change do
    create table(:media) do
      add :name, :string
      add :description, :text
      add :url, :string
      add :uploader_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:media, [:uploader_id])

  end
end
