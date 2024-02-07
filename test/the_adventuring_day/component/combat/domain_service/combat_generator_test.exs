defmodule TheAdventuringDay.Component.Combat.DomainService.CombatGeneratorTest do
  use TheAdventuringDay.DataCase
  use ExUnitProperties

  alias TheAdventuringDay.Component.Combat.DomainService.CombatGenerator
  alias TheAdventuringDay.Infrastructure.Persistence.HazardFeaturesRepo
  alias TheAdventuringDay.Infrastructure.Persistence.TerrainFeaturesRepo
  alias TheAdventuringDay.Infrastructure.Persistence.EnemyTemplateSpecRepo

  test "creates a valid combat encounter" do
    setup_enemy_template_data()
    setup_terrain_features_data()

    {:ok, _encounter} =
      CombatGenerator.generate(:standard, :interior, 5)

    # assert match?(%CombatGenerator{
    #   enemies: %GeneratedEnemyTemplate{},
    #   terrain_features: [%GeneratedTerrainFeature{}]
    # }, encounter)
  end

  def setup_enemy_template_data() do
    %{
      min_budget_required: 4.5,
      template: [
        %{amount: 1, role: :skirmisher, level: :same_level, type: :standard},
        %{amount: 2, role: :troop, level: :one_level_lower, type: :standard},
        %{amount: 1, role: :wrecker, level: :same_level, type: :double_strength}
      ],
      addons: %{
        enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler],
        enemy_levels: [:same_level, :one_level_lower],
        enemy_types: [:mook]
      },
      restrictions: [],
      permutations: []
    }
    |> EnemyTemplateSpecRepo.insert_enemy_template_spec()
  end

  def setup_terrain_features_data() do
    HazardFeaturesRepo.insert_hazard_feature(%{
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

    TerrainFeaturesRepo.insert_terrain_feature(%{
      terrain_type: :hindering,
      name: "Hindering terrain",
      description: """
      Hindering terrain prevents movement (or severely punishes it) or damages creatures that enter it, but allows line of sight.

      Hindering terrain can be interesting because it encourages ranged attacks. You can shoot an arrow over hindering terrain, while it is impossible or risky to run through it to attack in melee.

      Too much hindering terrain makes melee characters and monsters worthless. It is best used to protect a monster or two, or as a favorable defensive position that the PCs can exploit.
      """,
      interior_examples: ["Pits", "Room underwater", "Fire", "Lava"],
      exterior_examples: ["Pits", "Deep water", "Lava", "Fire"]
    })

    TerrainFeaturesRepo.insert_terrain_feature(%{
      terrain_type: :blocking,
      name: "Blocking terrain",
      description: """
      Blocking terrain prevents movement and blocks line of sight. The characters might be able to climb over such obstacles, but otherwise this type of terrain prevents movement.

      Blocking terrain channels the encounter's flow and cuts down on the range at which the PCs can attack the monsters (and vice versa). Using blocking terrain, you can present two or three distinct paths in an encounter area and different challenges down each one. For example, the characters come under attack when they enter an intersection. Orc warriors charge down two corridors, while an orc shaman casts spells from a third. If the PCs charge the shaman, they risk attack from two sides. If they fall back, they can meet the warriors along one front, but the shaman is safely away from the melee.

      Don't use too much blocking terrain. Fights in endless narrow corridors are boring. While the fighter beats on the monster, the rest of the party must rely on ranged attacks.
      """,
      interior_examples: ["Walls", "Doors", "Impassable rubble", "Makeshift fortification"],
      exterior_examples: ["Impassable rubble", "Trees", "Dense thickets", "Large rock formations"]
    })

    TerrainFeaturesRepo.insert_terrain_feature(%{
      terrain_type: :challenging,
      name: "Challenging terrain",
      description: """
      Challenging terrain requires a check or test of some kind to cross. Fail, and something bad happens to you. Challenging terrain makes skills more important. It adds an active element of risk to the game. Some challenging terrain is also difficult terrain.

      The type of terrain determines what happens when characters fail their checks. Climbing characters might fall. Characters wading through mud get stuck or get blindsided by an attack. Characters moving across ice fall down or slide into a disadvantageous position.

      Too much challenging terrain wears down the party or slows the action if the characters have a few unlucky tests. If the characters are cautious, they can treat it as hindering terrain instead.
      """,
      interior_examples: ["Oil slick", "Thin beams", "Climbing", "Precarious bridge", "Narrow ledge"],
      exterior_examples: ["Slick ice", "Deep mud", "Climbing", "Deep water", "Narrow ledge"]
    })

    TerrainFeaturesRepo.insert_terrain_feature(%{
      terrain_type: :obscured,
      name: "Obscured terrain",
      description: """
      Obscured terrain provides concealment and blocks line of sight if a target is far enough away from you. However, it has no effect on movement.

      Obscured terrain lends a sense of mystery to an encounter. The characters can't see what lurks ahead, but their enemies have open space they can move through to attack. It restricts ranged attacks similar to blocking terrain does, but it allows more movement. Encounters are a little more tense and unpredictable.

      Obscured terrain becomes a problem when it shuts down the fight. The characters likely stick close together, and if the monsters can ignore the concealing terrain due to some magical effect, the fight might be unfair rather than tense.
      """,
      interior_examples: ["Fog", "Darkness", "Poison mist"],
      exterior_examples: ["Fog", "Mist", "Nighttime"]
    })

    TerrainFeaturesRepo.insert_terrain_feature(%{
      terrain_type: :cover,
      name: "Cover terrain",
      description: """
      Cover terrain provides cover, making ranged attacks more difficult.

      Cover terrain forces ranged attackers to move if they want to shoot around it. It also helps creatures avoid ranged attacks.

      Too much cover makes the encounter too difficult for ranged attackers
      """,
      interior_examples: ["Low walls", "Piles of rubble"],
      exterior_examples: ["Fallen trees", "Trenches", "Obscuring foliage"]
    })
  end
end
