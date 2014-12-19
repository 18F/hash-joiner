require "minitest/autorun"
require "hash-joiner"

module HashJoinerTest
  class DeepMergeTest < ::Minitest::Test
    def test_raise_if_classes_differ
      assert_raises HashJoiner::MergeError do
        HashJoiner.deep_merge({}, [])
      end
    end

    def test_raise_if_not_mergeable
      assert_raises HashJoiner::MergeError do
        HashJoiner.deep_merge(true, false)
      end
    end

    def test_merge_into_empty_hash
      lhs = {}
      rhs = {:foo => true}
      HashJoiner.deep_merge lhs, rhs
      assert_equal rhs, lhs
    end

    def test_merge_into_empty_array
      lhs = []
      rhs = [{:foo => true}]
      HashJoiner.deep_merge lhs, rhs
      assert_equal rhs, lhs
    end

    def test_rhs_hash_overwrites_nonmergeable_lhs_hash_values
      lhs = {:foo => false}
      rhs = {:foo => true}
      HashJoiner.deep_merge lhs, rhs
      assert_equal rhs, lhs
    end

    def test_rhs_appends_values_to_lhs
      lhs = [{:foo => false}]
      rhs = [{:foo => true}]
      HashJoiner.deep_merge lhs, rhs
      assert_equal [{:foo => false}, {:foo => true}], lhs
    end

    def test_recursively_merge_hashes
      lhs = {
        'name' => 'mbland',
        'languages' => ['C++'],
        'age' => 'None of your business',
        'guitars' => {
          'strats' => 'too many',
          'acoustics' => 1,
          },
        }
      rhs = {
        'full_name' => 'Mike Bland',
        'languages' => ['Python', 'Ruby'],
        'age' => 'Not gonna say it',
        'guitars' => {
          'strats' => 'not enough',
          'les_pauls' => 1,
          },
        }
      HashJoiner.deep_merge lhs, rhs

      expected = {
        'name' => 'mbland',
        'full_name' => 'Mike Bland',
        'languages' => ['C++', 'Python', 'Ruby'],
        'age' => 'Not gonna say it',
        'guitars' => {
          'strats' => 'not enough',
          'acoustics' => 1,
          'les_pauls' => 1,
          },
        }

      assert_equal expected, lhs
    end
  end
end
