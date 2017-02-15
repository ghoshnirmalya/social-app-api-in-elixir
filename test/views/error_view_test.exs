defmodule SocialAppApi.ErrorViewTest do
  use SocialAppApi.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 401.json-api" do
    assert render(SocialAppApi.ErrorView, "401.json-api", []) ==
           %{"errors" => [%{code: 401, title: "Unauthorized"}], "jsonapi" => %{"version" => "1.0"}}
  end

  test "renders 403.json-api" do
    assert render(SocialAppApi.ErrorView, "403.json-api", []) ==
           %{"errors" => [%{code: 403, title: "Forbidden"}], "jsonapi" => %{"version" => "1.0"}}
  end

  test "renders 404.json-api" do
    assert render(SocialAppApi.ErrorView, "404.json-api", []) ==
           %{"errors" => [%{code: 404, title: "Page not found"}], "jsonapi" => %{"version" => "1.0"}}
  end

  test "renders 422.json-api" do
    assert render(SocialAppApi.ErrorView, "422.json-api", []) ==
           %{"errors" => [%{code: 422, title: "Unprocessable entity"}], "jsonapi" => %{"version" => "1.0"}}
  end

  test "render 500.json-api" do
    assert render(SocialAppApi.ErrorView, "500.json-api", []) ==
           %{"errors" => [%{code: 500, title: "Internal Server Error"}], "jsonapi" => %{"version" => "1.0"}}
  end

  test "render any other" do
    assert render(SocialAppApi.ErrorView, "505.json-api", []) ==
           %{"errors" => [%{code: 500, title: "Internal Server Error"}], "jsonapi" => %{"version" => "1.0"}}
  end
end
