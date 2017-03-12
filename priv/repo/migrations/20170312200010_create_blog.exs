defmodule SocialAppApi.Repo.Migrations.CreateBlog do
  use Ecto.Migration

  def change do
    create table(:blogs) do
      add :title, :string
      add :body, :text
      add :author_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
    create index(:blogs, [:author_id])

  end
end
