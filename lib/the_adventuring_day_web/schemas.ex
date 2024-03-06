defmodule TheAdventuringDayWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  alias TheAdventuringDay.Component.Combat.Domain.Enemy

  defmodule Enemy do
    OpenApiSpex.schema(%{
      title: "Enemy",
      description: "An enemy group as part of a combat encounter",
      type: :object,
      properties: %{
        amount: %Schema{
          type: :integer,
          description:
            "Number of enemies in this group. Not to be confused with a mook group that already counts as a group."
        },
        role: %Schema{
          type: :string,
          description: "Enemy role such as archer or leader.",
          enum: ["archer", "blocker", "caster", "leader", "spoiler", "troop", "wrecker"]
        },
        level: %Schema{
          type: :string,
          description: "The enemy's level relative to the group.",
          enum: ["same_level", "one_level_higher", "one_level_lower", "two_levels_higher", "two_levels_lower"]
        },
        type: %Schema{
          type: :string,
          description: "The enemy's type such standard, weakling or mook.",
          enum: ["standard", "double_strength", "triple_strength", "mook", "elite", "weakling"]
        }
      },
      example: %{amount: 2, role: "archer", level: "same_level", type: "double_strength"}
    })
  end

  defmodule Enemies do
    OpenApiSpex.schema(%{
      title: "Enemies",
      description: "Template containing all enemy groups and their respective budget cost.",
      type: :object,
      properties: %{
        available_budget: %Schema{type: :number, format: :float},
        budget_used: %Schema{type: :number, format: :float},
        template: %Schema{type: :array, items: Enemy}
      },
      example: %{
        available_budget: 5.0,
        budget_used: 1.0,
        template: %{
          amount: 2,
          role: "archer",
          level: "same_level",
          type: "double_strength"
        }
      }
    })
  end

  defmodule TerrainFeature do
    OpenApiSpex.schema(%{
      title: "TerrainFeature",
      description: "A terrain feature as part of a combat encounter",
      type: :object,
      properties: %{
        terrain_type: %Schema{
          type: :string,
          description: "Type of the terrain such as difficult, dangerous, hindering.",
          enum: ["difficult", "hindering", "blocking", "challenging", "obscured", "cover"]
        },
        name: %Schema{type: :string, description: "Name of the terrain type."},
        description: %Schema{type: :string, description: "Description of the terrain's effects."},
        interior_examples: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "Examples of such terrain in an indoor combat encounter."
        },
        exterior_examples: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "Examples of such terrain in an outdoor combat encounter."
        }
      },
      example: %{
        terrain_type: "difficult",
        name: "Difficult terrain",
        description: "Difficult terrain is difficult to move through and costs additional move points.",
        interior_examples: ["rubble"],
        exterior_examples: ["dense foliage"]
      }
    })
  end

  defmodule Hazard do
    OpenApiSpex.schema(%{
      title: "Hazard",
      description: "A hazard as part of a combat encounter",
      type: :object,
      properties: %{
        hazard_type: %Schema{
          type: :string,
          description: "Type of hazard such as trap, terrain or zone.",
          enum: ["trap", "terrain", "zone"]
        },
        name: %Schema{type: :string, description: "Name of the hazard."},
        description: %Schema{type: :string, description: "Description of the hazard."}
      },
      example: %{
        hazard_type: "trap",
        name: "Sawblade trap",
        description: "Sawblades come out of the floor and slice and dice anything in their path."
      }
    })
  end

  defmodule CombatEncounter do
    OpenApiSpex.schema(%{
      title: "CombatEncounter",
      description: "A generated combat encounter",
      type: :object,
      properties: %{
        enemies: Enemies,
        terrain_features: %Schema{type: :array, items: TerrainFeature},
        hazards: %Schema{type: :array, items: Hazard}
      },
      example: %{
        enemies: %{
          available_budget: 7,
          budget_used: 6.5,
          template: [
            %{amount: 2, role: "archer", level: "same_level", type: "double_strength"},
            %{amount: 2, role: "troop", level: "same_level", type: "mook"},
            %{amount: 1, role: "leader", level: "same_level", type: "standard"}
          ]
        },
        terrain_features: [
          %{
            terrain_type: "difficult",
            name: "Difficult terrain",
            description: "Difficult terrain is difficult to move through and costs additional move points.",
            interior_examples: ["rubble"],
            exterior_examples: ["dense foliage"]
          }
        ],
        hazards: [
          %{
            hazard_type: "trap",
            name: "Sawblade trap",
            description: "Sawblades come out of the floor and slice and dice anything in their path."
          }
        ]
      }
    })
  end

  defmodule CombatEncounterRequest do
    OpenApiSpex.schema(%{
      title: "CombatEncounterRequest",
      description: "POST body for generating a combat encounter",
      type: :object,
      properties: %{
        party_members: %Schema{type: :integer, description: "Party size to determine how many enemies to generate."},
        encounter_difficulty: %Schema{
          type: :string,
          description:
            "How difficult the encounter will be, usually in the form of additional or higher-level enemies.",
          default: "medium",
          enum: ["easy", "medium", "hard"]
        },
        environs: %Schema{
          type: :string,
          description: "If the battle takes place indoors or outdoors, to flavor hazards and terrain features.",
          default: "outdoor",
          enum: ["indoor", "outdoor"]
        },
        complexity: %Schema{
          type: :string,
          description: "If the encounter should make use of more complex features such as timers.",
          default: "simple",
          enum: ["simple", "complex"]
        }
      },
      required: [:party_members],
      example: %{
        party_members: 4,
        encounter_difficulty!: "medium",
        environs: "outdoor",
        complexity: "simple"
      }
    })
  end

  defmodule PersistCombatEncounterRequest do
    OpenApiSpex.schema(%{
      title: "PersistCombatEncounterRequest",
      description: "Request schema for a combat encounter to persist",
      type: :object,
      properties: %{
        encounter: CombatEncounter
      },
      example: %{
        encounter: %{
          enemies: %{
            available_budget: 7,
            budget_used: 6.5,
            template: [
              %{amount: 2, role: "archer", level: "same_level", type: "double_strength"},
              %{amount: 2, role: "troop", level: "same_level", type: "mook"},
              %{amount: 1, role: "leader", level: "same_level", type: "standard"}
            ]
          },
          terrain_features: [
            %{
              terrain_type: "difficult",
              name: "Difficult terrain",
              description: "Difficult terrain is difficult to move through and costs additional move points.",
              interior_examples: ["rubble"],
              exterior_examples: ["dense foliage"]
            }
          ],
          hazards: [
            %{
              hazard_type: "trap",
              name: "Sawblade trap",
              description: "Sawblades come out of the floor and slice and dice anything in their path."
            }
          ]
        }
      }
    })
  end

  defmodule CombatEncounterResponse do
    OpenApiSpex.schema(%{
      title: "CombatEncounterResponse",
      description: "Response schema for a combat encounter",
      type: :object,
      properties: %{
        encounter: CombatEncounter
      },
      example: %{
        encounter: %{
          enemies: %{
            available_budget: 7,
            budget_used: 6.5,
            template: [
              %{amount: 2, role: "archer", level: "same_level", type: "double_strength"},
              %{amount: 2, role: "troop", level: "same_level", type: "mook"},
              %{amount: 1, role: "leader", level: "same_level", type: "standard"}
            ]
          },
          terrain_features: [
            %{
              terrain_type: "difficult",
              name: "Difficult terrain",
              description: "Difficult terrain is difficult to move through and costs additional move points.",
              interior_examples: ["rubble"],
              exterior_examples: ["dense foliage"]
            }
          ],
          hazards: [
            %{
              hazard_type: "trap",
              name: "Sawblade trap",
              description: "Sawblades come out of the floor and slice and dice anything in their path."
            }
          ]
        }
      }
    })
  end

  defmodule HazardResponse do
    OpenApiSpex.schema(%{
      title: "HazardResponse",
      description: "Response schema for a hazard",
      type: :object,
      properties: %{
        hazard: Hazard
      },
      example: %{
        hazard: %{
          hazard_type: "trap",
          name: "Sawblade trap",
          description: "Sawblades come out of the floor and slice and dice anything in their path."
        }
      }
    })
  end

  defmodule TerrainFeatureResponse do
    OpenApiSpex.schema(%{
      title: "TerrainFeatureResponse",
      description: "Response schema for a terrain feature",
      type: :object,
      properties: %{
        terrain_feature: TerrainFeature
      },
      example: %{
        terrain_features: %{
          terrain_type: "difficult",
          name: "Difficult terrain",
          description: "Difficult terrain is difficult to move through and costs additional move points.",
          interior_examples: ["rubble"],
          exterior_examples: ["dense foliage"]
        }
      }
    })
  end
end
