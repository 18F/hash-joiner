require_relative "../lib/hash-joiner"
require_relative "test_helper"
require "minitest/autorun"

module HashJoinerTest
  class JoinArrayDataTest < ::Minitest::Test
    def test_empty_arrays
      lhs = []
      assert_same lhs, HashJoiner.join_array_data('unused', lhs, [])
      assert_empty lhs
    end

    def test_assert_raises_if_lhs_and_rhs_are_not_arrays
      assert_raises HashJoiner::JoinError do
        assert_empty HashJoiner.join_array_data('unused', [], {})
      end

      assert_raises HashJoiner::JoinError do
        assert_empty HashJoiner.join_array_data('unused', {}, [])
      end

      assert_raises HashJoiner::JoinError do
        assert_empty HashJoiner.join_array_data('unused', {}, {})
      end
    end

    def test_assert_raises_if_key_field_is_missing
      assert_raises HashJoiner::JoinError do
        assert_empty HashJoiner.join_array_data('key', [{'key'=>true}], [{}])
      end

      assert_raises HashJoiner::JoinError do
        assert_empty HashJoiner.join_array_data('key', [{}], [{'key'=>true}])
      end
    end

    def test_leave_lhs_alone_if_rhs_is_empty
      lhs = [{'key'=>true}]
      rhs = []
      assert_same lhs, HashJoiner.join_array_data('key', lhs, rhs)
      assert_equal [{'key'=>true}], lhs
    end

    def test_lhs_matches_rhs_if_lhs_is_empty
      lhs = []
      rhs = [{'key'=>true}]
      assert_same lhs, HashJoiner.join_array_data('key', lhs, rhs)
      assert_equal [{'key'=>true}], lhs
    end

    def test_join_single_item
      lhs = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'languages' => ['C++'],
        },
      ]
      rhs = [
        {'name' => 'mbland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['Python', 'Ruby'],
        },
      ]
      expected = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['C++', 'Python', 'Ruby'],
        },
      ]
      assert_same lhs, HashJoiner.join_array_data('name', lhs, rhs)
      assert_equal expected, lhs
    end

    def test_join_multiple_items
      lhs = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'languages' => ['C++'],
        },
        {'name' => 'foobar',
         'full_name' => 'Foo Bar',
        },
      ]
      rhs = [
        {'name' => 'foobar',
         'email' => 'Foo.Bar@gsa.gov',
        },
        {'name' => 'mbland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['Python', 'Ruby'],
        },
        {'name' => 'bazquux',
         'full_name' => 'Baz Quux',
         'email' => 'baz.quux@gsa.gov',
        },
      ]
      expected = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['C++', 'Python', 'Ruby'],
        },
        {'name' => 'foobar',
         'full_name' => 'Foo Bar',
         'email' => 'Foo.Bar@gsa.gov',
        },
        {'name' => 'bazquux',
         'full_name' => 'Baz Quux',
         'email' => 'baz.quux@gsa.gov',
        },
      ]
      assert_same lhs, HashJoiner.join_array_data('name', lhs, rhs)
      assert_equal expected, lhs
    end
  end
end
