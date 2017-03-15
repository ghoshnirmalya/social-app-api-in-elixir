defmodule SocialAppApi.FollowerTest do
  use SocialAppApi.ModelCase

  alias SocialAppApi.Follower

  @valid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Follower.changeset(%Follower{}, @valid_attrs)
    assert changeset.valid?
  end
end
