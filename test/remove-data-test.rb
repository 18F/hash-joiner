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
      assert_equal({}, HashJoiner.remove_data({}, 'private'))
      assert_equal([], HashJoiner.remove_data([], 'private'))
    end

    def test_remove_top_level_private_data_from_hash
      assert_equal({'name' => 'mbland', 'full_name' => 'Mike Bland'},
        HashJoiner.remove_data(
          {'name' => 'mbland', 'full_name' => 'Mike Bland',
           'private' => {'email' => 'michael.bland@gsa.gov'}}, 'private'))
    end

    def test_remove_top_level_private_data_from_array
      assert_equal([{'name' => 'mbland', 'full_name' => 'Mike Bland'}],
        HashJoiner.remove_data(
          [{'name' => 'mbland', 'full_name' => 'Mike Bland'},
           {'private' => {'name' => 'foobar'}}], 'private'))
    end

    def test_remove_private_data_from_object_array_at_different_depths
      assert_equal([{'name' => 'mbland', 'full_name' => 'Mike Bland'}],
        HashJoiner.remove_data(
          [{'name' => 'mbland', 'full_name' => 'Mike Bland',
            'private' => {'email' => 'michael.bland@gsa.gov'}},
           {'private' => [{'name' => 'foobar'}]}], 'private'))
    end
  end
end
