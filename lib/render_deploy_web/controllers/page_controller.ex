defmodule RenderDeployWeb.PageController do
  use RenderDeployWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
