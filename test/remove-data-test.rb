require "minitest/autorun"
require "hash-joiner"

module HashJoinerTest
  class RemoveDataTest < ::Minitest::Test
    def test_ignore_if_not_a_collection
      assert_nil HashJoiner.remove_data 27, 'private'
      assert_nil HashJoiner.remove_data 'foobar', 'private'
      assert_nil HashJoiner.remove_data :msb, 'private'
      assert_nil HashJoiner.remove_data true, 'private'
    end

    def test_ignore_empty_collections
      empty_hash = {}
      assert_same empty_hash, HashJoiner.remove_data(empty_hash, 'private')
      assert_empty empty_hash
      empty_list = []
      assert_same empty_list, HashJoiner.remove_data(empty_list, 'private')
      assert_empty empty_list
    end

    def test_remove_top_level_private_data_from_hash
      data = {
        'name' => 'mbland', 'full_name' => 'Mike Bland',
        'private' => {'email' => 'michael.bland@gsa.gov'}
        }
      assert_same data, HashJoiner.remove_data(data, 'private')
      assert_equal({'name' => 'mbland', 'full_name' => 'Mike Bland'}, data)
    end

    def test_remove_top_level_private_data_from_array
      data = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland'},
        {'private' => {'name' => 'foobar'}}
        ]
      assert_same data, HashJoiner.remove_data(data, 'private')
      assert_equal([{'name' => 'mbland', 'full_name' => 'Mike Bland'}], data)
    end

    def test_remove_private_data_from_object_array_at_different_depths
      data = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland',
         'private' => {'email' => 'michael.bland@gsa.gov'}
        },
        {'private' => [{'name' => 'foobar'}]}
        ]
      assert_same data, HashJoiner.remove_data(data, 'private')
      assert_equal([{'name' => 'mbland', 'full_name' => 'Mike Bland'}], data)
    end
  end
end
