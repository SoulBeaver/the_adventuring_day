defmodule TheAdventuringDay.Infrastructure.Init.Init do
  @moduledoc """
  Initialization module for DB data that must run prior to the app being used.
  """

  alias TheAdventuringDay.Infrastructure.Persistence.EnemyTemplateSpecRepo
  alias TheAdventuringDay.Infrastructure.Persistence.TerrainFeaturesRepo
  alias TheAdventuringDay.Infrastructure.Persistence.HazardFeaturesRepo

  def seed_data() do
    truncate_tables()

    seed_enemy_template_specs()
    seed_terrain_features()
    seed_hazard_features()

    :ok
  end

  defp truncate_tables() do
    EnemyTemplateSpecRepo.truncate()
    TerrainFeaturesRepo.truncate()
    HazardFeaturesRepo.truncate()
  end

  defp seed_enemy_template_specs() do
    EnemyTemplateSpecRepo.insert_enemy_template_spec!(%{
      min_budget_required: 4,
      template: [
        %{amount: 1, role: :skirmisher, level: :same_level, type: :standard},
        %{amount: 2, role: :troop, level: :one_level_lower, type: :standard},
        %{amount: 1, role: :wrecker, level: :same_level, type: :double_strength}
      ],
      addons: %{
        enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler, :troop],
        enemy_levels: [:same_level, :one_level_lower],
        enemy_types: [:mook]
      },
      restrictions: [
        %{max_size: 1, enemy_roles: [:leader]},
        %{max_size: 2, enemy_roles: [:wrecker]}
      ],
      permutations: [
        %{when_amount: 2, when_role: :wrecker, then_type: :standard}
      ]
    })

    EnemyTemplateSpecRepo.insert_enemy_template_spec!(%{
      min_budget_required: 3.5,
      template: [
        %{amount: 1, role: :spoiler, level: :one_level_higher, type: :standard},
        %{amount: 2, role: :troop, level: :same_level, type: :mook}
      ],
      addons: %{
        enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler, :troop],
        enemy_levels: [:same_level, :one_level_lower],
        enemy_types: [:double_strength, :elite]
      },
      restrictions: [
        %{max_size: 2, enemy_roles: [:spoiler]},
        %{max_size: 2, enemy_types: [:mook]},
        %{max_size: 1, enemy_roles: [:wrecker]}
      ],
      permutations: []
    })

    EnemyTemplateSpecRepo.insert_enemy_template_spec!(%{
      min_budget_required: 3.75,
      template: [
        %{amount: 1, role: :leader, level: :same_level, type: :standard},
        %{amount: 1, role: :archer, level: :same_level, type: :standard},
        %{amount: 1, role: :blocker, level: :same_level, type: :standard},
        %{amount: 1, role: :troop, level: :same_level, type: :mook}
      ],
      addons: %{
        enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler, :troop],
        enemy_levels: [:same_level, :one_level_higher, :one_level_lower],
        enemy_types: [:double_strength, :elite, :mook]
      },
      restrictions: [
        %{max_size: 1, enemy_roles: [:leader]}
      ],
      permutations: []
    })

    EnemyTemplateSpecRepo.insert_enemy_template_spec!(%{
      min_budget_required: 3.5,
      template: [
        %{amount: 1, role: :wrecker, level: :same_level, type: :double_strength},
        %{amount: 1, role: :archer, level: :same_level, type: :mook},
        %{amount: 1, role: :troop, level: :same_level, type: :mook}
      ],
      addons: %{
        enemy_roles: [:archer, :caster, :spoiler, :troop],
        enemy_levels: [:same_level, :one_level_higher, :one_level_lower],
        enemy_types: [:double_strength, :elite, :mook]
      },
      restrictions: [
        %{max_size: 1, enemy_roles: [:wrecker]}
      ],
      permutations: []
    })

    EnemyTemplateSpecRepo.insert_enemy_template_spec!(%{
      min_budget_required: 5,
      template: [
        %{amount: 3, role: :troop, level: :same_level, type: :standard},
        %{amount: 1, role: :caster, level: :same_level, type: :standard},
        %{amount: 1, role: :spoiler, level: :same_level, type: :standard}
      ],
      addons: %{
        enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler, :troop],
        enemy_levels: [:same_level, :one_level_higher, :one_level_lower],
        enemy_types: [:double_strength, :elite, :mook]
      },
      restrictions: [
        %{max_size: 1, enemy_roles: [:leader]}
      ],
      permutations: []
    })

    EnemyTemplateSpecRepo.insert_enemy_template_spec!(%{
      min_budget_required: 3.5,
      template: [
        %{amount: 2, role: :wrecker, level: :same_level, type: :mook},
        %{amount: 1, role: :wrecker, level: :same_level, type: :standard},
        %{amount: 1, role: :spoiler, level: :same_level, type: :standard}
      ],
      addons: %{
        enemy_roles: [:archer, :blocker, :caster, :leader, :spoiler, :troop],
        enemy_levels: [:same_level, :one_level_higher, :one_level_lower],
        enemy_types: [:double_strength, :elite, :mook]
      },
      restrictions: [
        %{max_size: 1, enemy_roles: [:leader]}
      ],
      permutations: [
        %{when_amount: 3, when_role: :wrecker, then_level: :one_level_lower}
      ]
    })
  end

  defp seed_terrain_features() do
    TerrainFeaturesRepo.insert_terrain_feature!(%{
      terrain_type: :difficult,
      name: "Difficult terrain",
      description: """
      Difficult terrain slows down characters without blocking line of sight. In encounter design, difficult terrain is a useful tool to make a path less appealing without removing it as an option. It gives you some of the benefits of walls and other terrain that blocks movement without the drawback of constricting the party's options.
      """,
      interior_examples: ["rubble", "uneven ground", "steep slope", "oil slick"],
      exterior_examples: [
        "rubble",
        "uneven ground",
        "shallow water",
        "fallen trees",
        "steep slope",
        "mud",
        "thick undergrowth",
        "dense vines"
      ]
    })

    TerrainFeaturesRepo.insert_terrain_feature!(%{
      terrain_type: :hindering,
      name: "Hindering terrain",
      description: """
      Hindering terrain prevents movement (or severely punishes it) or damages creatures that enter it, but allows line of sight.
      
      Hindering terrain can be interesting because it encourages ranged attacks. You can shoot an arrow over hindering terrain, while it is impossible or risky to run through it to attack in melee.
      
      Too much hindering terrain makes melee characters and monsters worthless. It is best used to protect a monster or two, or as a favorable defensive position that the PCs can exploit.
      """,
      interior_examples: ["pits", "room underwater", "fire", "lava"],
      exterior_examples: ["pits", "deep water", "lava", "fire"]
    })

    TerrainFeaturesRepo.insert_terrain_feature!(%{
      terrain_type: :blocking,
      name: "Blocking terrain",
      description: """
      Blocking terrain prevents movement and blocks line of sight. The characters might be able to climb over such obstacles, but otherwise this type of terrain prevents movement.
      
      Blocking terrain channels the encounter's flow and cuts down on the range at which the PCs can attack the monsters (and vice versa). Using blocking terrain, you can present two or three distinct paths in an encounter area and different challenges down each one. For example, the characters come under attack when they enter an intersection. Orc warriors charge down two corridors, while an orc shaman casts spells from a third. If the PCs charge the shaman, they risk attack from two sides. If they fall back, they can meet the warriors along one front, but the shaman is safely away from the melee.
      
      Don't use too much blocking terrain. Fights in endless narrow corridors are boring. While the fighter beats on the monster, the rest of the party must rely on ranged attacks.
      """,
      interior_examples: ["walls", "doors", "impassable rubble", "makeshift fortification"],
      exterior_examples: ["impassable rubble", "trees", "dense thickets", "large rock formations"]
    })

    TerrainFeaturesRepo.insert_terrain_feature!(%{
      terrain_type: :challenging,
      name: "Challenging terrain",
      description: """
      Challenging terrain requires a check or test of some kind to cross. Fail, and something bad happens to you. Challenging terrain makes skills more important. It adds an active element of risk to the game. Some challenging terrain is also difficult terrain.
      
      The type of terrain determines what happens when characters fail their checks. Climbing characters might fall. Characters wading through mud get stuck or get blindsided by an attack. Characters moving across ice fall down or slide into a disadvantageous position.
      
      Too much challenging terrain wears down the party or slows the action if the characters have a few unlucky tests. If the characters are cautious, they can treat it as hindering terrain instead.
      """,
      interior_examples: ["oil slick", "thin beams", "climbing", "precarious bridge", "narrow ledge"],
      exterior_examples: ["slick ice", "deep mud", "climbing", "deep water", "narrow ledge"]
    })

    TerrainFeaturesRepo.insert_terrain_feature!(%{
      terrain_type: :obscured,
      name: "Obscured terrain",
      description: """
      Obscured terrain provides concealment and blocks line of sight if a target is far enough away from you. However, it has no effect on movement.
      
      Obscured terrain lends a sense of mystery to an encounter. The characters can't see what lurks ahead, but their enemies have open space they can move through to attack. It restricts ranged attacks similar to blocking terrain does, but it allows more movement. Encounters are a little more tense and unpredictable.
      
      Obscured terrain becomes a problem when it shuts down the fight. The characters likely stick close together, and if the monsters can ignore the concealing terrain due to some magical effect, the fight might be unfair rather than tense.
      """,
      interior_examples: ["fog", "darkness", "poison mist"],
      exterior_examples: ["fog", "mist", "nighttime"]
    })

    TerrainFeaturesRepo.insert_terrain_feature!(%{
      terrain_type: :cover,
      name: "Cover terrain",
      description: """
      Cover terrain provides cover, making ranged attacks more difficult.
      
      Cover terrain forces ranged attackers to move if they want to shoot around it. It also helps creatures avoid ranged attacks.
      
      Too much cover makes the encounter too difficult for ranged attackers
      """,
      interior_examples: ["low walls", "piles of rubble"],
      exterior_examples: ["fallen trees", "trenches", "obscuring foliage"]
    })
  end

  defp seed_hazard_features() do
    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :trap,
      name: "Sawblade trap",
      description: """
      There are sawblades in the walls, floor or ceiling. Stepping on a pressure plate activates the sawblades and slice through whatever's in their path.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :terrain,
      name: "Spiderwebs",
      description: """
      Huge spiderwebs that not only count as difficult terrain, they each have thousands of smaller spiders waiting in the wings to descent and bite whichever creature is stuck there.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :trap,
      name: "Illusory wall",
      description: """
      This room appears much smaller than it actually is. Anyone thrown against the wall instead flies through, dispelling the illusion and revealing a much larger arena behind it.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :trap,
      name: "Crushing walls",
      description: """
      The walls of this area are closing in on one another. Perhaps it's two side walls, or maybe the ceiling. In a matter of rounds everything in this room will be crushed.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :terrain,
      name: "Grasping slime",
      description: """
      Grasping slime is difficult terrain that literally reaches up to grab the legs and arms of anyone passing through.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :terrain,
      name: "Ember moss",
      description: """
      This pernicious moss clumps drains the character standing on them of heat. Whats worse, the user becomes vulnerable to cold.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :zone,
      name: "Falling swords",
      description: """
      Hundreds of swords hang like the sword of damocles over the arena. Every once in a while some of them fall down and slice through anything in their path.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :zone,
      name: "Dimensional turbulence",
      description: """
      This nexus has long lost its control and stability as a gateway to another plane. A random amount of creatures nearest to the nexus are immediately teleported to somewhere else in the arena.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :zone,
      name: "Astral flame",
      description: """
      Fiery liquid that sheds bright light, the astral flame completely engulfs whatever it touches. Every so often it moves, slowly, to a new location.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :zone,
      name: "Ravenous bats",
      description: """
      These bats have long succumbed to an unknown frenzy. Only living flesh will sate them, and not even yours is enough to do so. These are like flying piranhas attracted by blood.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :terrain,
      name: "Blood rock",
      description: """
      Bloodred moss clumps cover the rocks in this area. Anyone standing close to them becomes infected with rage. All of their critical hits become more potent.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :terrain,
      name: "Abyssal wellspring",
      description: """
      A wellspring capable of judging a lifetime's worth of deeds. Any found guilty of committing grievous acts against demons and devils is severely punished in its presence.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :trap,
      name: "Undead in a barrel",
      description: """
      The loathsome undead have been forced into a barrel and were sealed away for millennia. The stench from opening it would be unbearable, not to mention the rotblack sludge of the undead's remains.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :terrain,
      name: "Fate of Phalanxes",
      description: """
      Helmeted iron skulls tumble over one another at the bottom of this mass grave, their horns forming a cruel curved bed of mithril spikes.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :terrain,
      name: "Corroded cavity",
      description: """
      Transluscent emerald sludge churns at the bottom of this rough-hewn pit. Three corroded skeletons hang suspended in the sludge.
      """
    })

    HazardFeaturesRepo.insert_hazard_feature!(%{
      hazard_type: :trap,
      name: "Bear trap",
      description: """
      A mean metal snare used to agonize and inhibit the movement of its victims. Either out in the open or cleverly hidden.
      """
    })
  end
end
