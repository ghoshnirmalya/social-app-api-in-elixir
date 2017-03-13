defmodule SocialAppApi.Repo.Migrations.CreateBlogComment do
  use Ecto.Migration

  def change do
    create table(:blog_comments) do
      add :body, :text
      add :author_id, references(:users, on_delete: :nothing)
      add :blog_id, references(:blogs, on_delete: :nothing)

      timestamps()
    end
    create index(:blog_comments, [:author_id])
    create index(:blog_comments, [:blog_id])

  end
end
