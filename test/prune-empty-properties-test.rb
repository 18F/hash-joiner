require_relative "../lib/hash-joiner"
require_relative "test_helper"
require "minitest/autorun"

module HashJoinerTest
  class PruneEmptyPropertiesTest < ::Minitest::Test
    def test_empty
      assert_empty HashJoiner.prune_empty_properties({})
      assert_empty HashJoiner.prune_empty_properties([])
    end

    def test_pruning
      original = [
        {'name' => 'mbland',
         'full_name' => '',
         'projects' => [],
         'departments' => [{}],
         'working_groups' => [
           {'name' => 'Documentation',
            'leads' => ['mbland'],
            'members' => [],
           },
         ],
        },
      ]

      expected = [
        {'name' => 'mbland',
         'working_groups' => [
           {'name' => 'Documentation',
            'leads' => ['mbland'],
           },
         ],
        },
      ]

      assert_equal(expected, HashJoiner.prune_empty_properties(original))
    end

    def test_pruning_circular_reference
      team_member = {
        'name' => 'mbland',
        'full_name' => '',
        'projects' => [],
        'departments' => [{}],
        'working_groups' => [],
        }
      working_group = {
        'name' => 'Documentation',
        'leads' => [],
        'members' => [],
        'artifacts' => [],
        'repositories' => [{}],
        'mission' => '',
      }

      team_member['working_groups'] << working_group
      working_group['leads'] << team_member
      working_group['members'] << team_member

      original = [team_member, working_group]

      expected = [
        {'name' => 'mbland',
         'working_groups' => [working_group],
        },
        {'name' => 'Documentation',
         'leads' => [team_member],
         'members' => [team_member],
        },
      ]
      actual = HashJoiner.prune_empty_properties original
      assert_equal(expected[0].keys, actual[0].keys)
      assert_equal(expected[1].keys, actual[1].keys)
    end
  end
end
