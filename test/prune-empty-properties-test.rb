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
  end
end
