defmodule TheAdventuringDay.Component.RandomTable.Application.ConvertRandomTablesTest do
  use TheAdventuringDay.DataCase

  alias TheAdventuringDay.Component.RandomTable.Application.ConvertRandomTables

  @repo Application.compile_env!(:the_adventuring_day, :random_table_collection_repo)

  @json_data [%{
    "header" => %{
      "descriptor" => "This thing is...",
      "dieSize" => 3,
      "rollsRequired" => 1
    },
    "results" => ["small", "medium", "large"],
    "rollBehavior" => "REPEAT"
  }]

  setup do
    @repo.truncate()
    :ok
  end

  test "converts an old random table into the new format" do
    {:ok, result} =
      ConvertRandomTables.convert_random_tables(
        collection_name: "sizes",
        table_names: ["size"],
        random_table_data: @json_data
      )

    assert result.collection_name == "sizes"
    assert result.tables == %{"size" => ["small", "medium", "large"]}
  end

  test "conversion fails if not too few table names are given" do
    {:error, :table_names_mismatch} =
      ConvertRandomTables.convert_random_tables(
        collection_name: "sizes",
        table_names: [],
        random_table_data: @json_data
      )
  end

  test "conversion fails if too many table names are given" do
    {:error, :table_names_mismatch} =
      ConvertRandomTables.convert_random_tables(
        collection_name: "sizes",
        table_names: ["size", "categories"],
        random_table_data: @json_data
      )
  end

  test "converting a table with the same collection_name as an existing one replaces it" do
    {:ok, _} =
      ConvertRandomTables.convert_random_tables(
        collection_name: "sizes",
        table_names: ["size"],
        random_table_data: @json_data
      )

    {:ok, result} =
      ConvertRandomTables.convert_random_tables(
        collection_name: "sizes",
        table_names: ["categories"],
        random_table_data: [%{
          "header" => %{
            "descriptor" => "This thing is...",
            "dieSize" => 3,
            "rollsRequired" => 1
          },
          "results" => ["tiny", "humanoid", "giant"],
          "rollBehavior" => "REPEAT"
        }]
      )

    assert result.collection_name == "sizes"
    assert result.tables == %{"categories" => ["tiny", "humanoid", "giant"]}
  end

  test "convert an old multi-table json into the new format" do
    {:ok, result} =
      ConvertRandomTables.convert_random_tables(
        collection_name: "once_upon_a_time",
        table_names: ["damsel", "villain"],
        random_table_data: [
          %{
            "header" => %{
              "descriptor" => "Once upon a time there was a...",
              "dieSize" => 3,
              "rollsRequired" => 1
            },
            "results" => ["damsel", "princess", "prince"],
            "rollBehavior" => "REPEAT"
          },
          %{
            "header" => %{
              "descriptor" => "who was captured by a...",
              "dieSize" => 3,
              "rollsRequired" => 1
            },
            "results" => ["dragon", "troll", "giant"],
            "rollBehavior" => "REPEAT"
          }
        ]
      )

    assert result.collection_name == "once_upon_a_time"

    assert result.tables == %{
             "damsel" => ["damsel", "princess", "prince"],
             "villain" => ["dragon", "troll", "giant"]
           }
  end
end
