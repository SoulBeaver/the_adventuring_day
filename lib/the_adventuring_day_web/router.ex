defmodule TheAdventuringDayWeb.Router do
  use TheAdventuringDayWeb, :router

  @swagger_ui_config [
    path: "/api/openapi",
    default_model_expand_depth: 3,
    display_operation_id: true,
    oauth2_redirect_url: {:endpoint_url, "/swaggerui/oauth2-redirect.html"},
    oauth: []
  ]

  def swagger_ui_config, do: @swagger_ui_config

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TheAdventuringDayWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug OpenApiSpex.Plug.PutApiSpec, module: TheAdventuringDayWeb.ApiSpec
  end

  pipeline :auth, do: plug(AuthPlug)
  pipeline :authOptional, do: plug(AuthPlugOptional)

  pipeline :auth_api do
    plug :fetch_session
    plug(AuthPlug)
  end

  scope "/", TheAdventuringDayWeb do
    pipe_through :browser
    pipe_through :authOptional

    get "/", PageController, :home
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
  end

  scope "/" do
    pipe_through :browser

    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  # Other scopes may use custom stacks.
  scope "/api", TheAdventuringDayWeb do
    pipe_through :api

    post "/init", InitController, :init

    post "/combat/new", CombatController, :generate
    get "/combat/new/hazard", CombatController, :new_hazard
    get "/combat/new/terrain_feature", CombatController, :new_terrain_feature
  end

  scope "/api" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api", TheAdventuringDayWeb do
    pipe_through :api
    pipe_through :auth_api

    post "/combat/", CombatController, :save
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:the_adventuring_day, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TheAdventuringDayWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
