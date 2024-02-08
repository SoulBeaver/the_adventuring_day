defmodule TheAdventuringDayWeb.CombatControllerTest do
  use TheAdventuringDayWeb.ConnCase

  alias AuthPlug.Token

  alias TheAdventuringDay.Infrastructure.Persistence.HazardFeaturesRepo
  alias TheAdventuringDay.Infrastructure.Persistence.TerrainFeaturesRepo
  alias TheAdventuringDay.Repo

  @encounter_request %{
    "enemies" => %{
      "available_budget" => 5.0,
      "budget_used" => 1.0,
      "template" => [
          %{
              "amount" => 1,
              "level" => "same_level",
              "role" => "troop",
              "type" => "standard"
          }
      ]
  },
  "hazards" => [
      %{
          "description" => "This room appears much smaller than it actually is. Anyone thrown against the wall instead flies through, dispelling the illusion and revealing a much larger arena behind it.\r\n",
          "hazard_type" => "trap",
          "name" => "Illusory wall"
      }
  ],
  "terrain_features" => [
      %{
          "description" => "Cover terrain provides cover, making ranged attacks more difficult.\r\n\r\nCover terrain forces ranged attackers to move if they want to shoot around it. It also helps creatures avoid ranged attacks.\r\n\r\nToo much cover makes the encounter too difficult for ranged attackers\r\n",
          "exterior_examples" => [
              "fallen trees",
              "trenches",
              "obscuring foliage"
          ],
          "interior_examples" => [
              "low walls",
              "piles of rubble"
          ],
          "name" => "Cover terrain",
          "terrain_type" => "cover"
      }
    ]
  }

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "save combat encounter" do
    test "shows combat encounter with id", %{conn: conn} do
      data = %{email: "broomie@test.com", name: "Broomie"}

      %{"encounter" => encounter} =
        conn
        |> assign(:jwt, Token.generate_jwt!(data))
        |> put_req_header("content-type", "application/json")
        |> post( ~p"/api/combat", encounter: @encounter_request)
        |> json_response(200)

      assert encounter["id"] != nil
    end

    test "renders error if the JSON is incorrect or incomplete", %{conn: conn} do
      data = %{email: "broomie@test.com", name: "Broomie"}

      error =
        conn
        |> assign(:jwt, Token.generate_jwt!(data))
        |> put_req_header("content-type", "application/json")
        |> post( ~p"/api/combat", encounter: %{"enemies" => "wow"})
        |> json_response(422)

      assert error == %{
        "errors" => [
          %{
            "detail" => "Invalid object. Got: string",
            "source" => %{"pointer" => "/encounter/enemies"},
            "title" => "Invalid value"
          }
        ]
      }
    end

    test "fails if the user isn't authenticated", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post( ~p"/api/combat", encounter: @encounter_request)

      assert conn.resp_body =~ "unauthorized"
    end
  end

  test "GET /combat/new/terrain_feature", %{conn: conn} do
    setup_db()

    conn = get(conn, ~p"/api/combat/new/terrain_feature")
    assert json_response(conn, 200) == %{
      "terrain_feature" => %{
        "terrain_type" => "difficult",
        "name" => "Difficult terrain",
        "description" => """
        Difficult terrain slows down characters without blocking line of sight. In encounter design, difficult terrain is a useful tool to make a path less appealing without removing it as an option. It gives you some of the benefits of walls and other terrain that blocks movement without the drawback of constricting the party's options.
        """,
        "interior_examples" => ["Rubble", "Uneven ground", "Steep slope", "Oil slick"],
        "exterior_examples" => [
          "Rubble",
          "Uneven ground",
          "Shallow water",
          "Fallen trees",
          "Steep slope",
          "Mud",
          "Thick undergrowth",
          "Dense vines"
        ]
      }
    }
  end

  test "GET /combat/new/hazard", %{conn: conn} do
    setup_db()

    conn = get(conn, ~p"/api/combat/new/hazard")
    assert json_response(conn, 200) == %{
      "hazard" => %{
        "hazard_type" => "trap",
        "name" => "Sawblades",
        "description" => """
        Sawblades in the walls, floor or ceiling. Stepping on a pressure plate activates the sawblades and slice through whatever's in their path.
        """
      }
    }
  end

  defp setup_db() do
    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :trap,
      name: "Sawblades",
      description: """
      Sawblades in the walls, floor or ceiling. Stepping on a pressure plate activates the sawblades and slice through whatever's in their path.
      """
    })

    TerrainFeaturesRepo.insert_terrain_feature(%{
      terrain_type: :difficult,
      name: "Difficult terrain",
      description: """
      Difficult terrain slows down characters without blocking line of sight. In encounter design, difficult terrain is a useful tool to make a path less appealing without removing it as an option. It gives you some of the benefits of walls and other terrain that blocks movement without the drawback of constricting the party's options.
      """,
      interior_examples: ["Rubble", "Uneven ground", "Steep slope", "Oil slick"],
      exterior_examples: [
        "Rubble",
        "Uneven ground",
        "Shallow water",
        "Fallen trees",
        "Steep slope",
        "Mud",
        "Thick undergrowth",
        "Dense vines"
      ]
    })
  end
end
