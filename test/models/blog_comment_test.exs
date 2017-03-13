defmodule SocialAppApi.BlogCommentTest do
  use SocialAppApi.ModelCase

  alias SocialAppApi.BlogComment

  @valid_attrs %{body: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = BlogComment.changeset(%BlogComment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = BlogComment.changeset(%BlogComment{}, @invalid_attrs)
    refute changeset.valid?
  end
end
