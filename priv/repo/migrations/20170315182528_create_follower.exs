defmodule SocialAppApi.Repo.Migrations.CreateFollower do
  use Ecto.Migration

  def change do
    create table(:followers) do
      add :user_id, references(:users, on_delete: :nothing)
      add :follower_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:followers, [:user_id])
    create index(:followers, [:follower_id])

  end
end
