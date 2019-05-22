defmodule BareChannelWeb.Router do
  use BareChannelWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BareChannelWeb do
    pipe_through :api
  end
end
