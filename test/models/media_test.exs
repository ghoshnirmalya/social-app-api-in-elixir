defmodule SocialAppApi.MediaTest do
  use SocialAppApi.ModelCase

  alias SocialAppApi.Media

  @valid_attrs %{description: "some content", name: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Media.changeset(%Media{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Media.changeset(%Media{}, @invalid_attrs)
    refute changeset.valid?
  end
end
