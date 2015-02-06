require_relative "../lib/hash-joiner"
require_relative "test_helper"
require "minitest/autorun"

module HashJoinerTest
  class AssignEmptyDefaultsTest < ::Minitest::Test
    def test_hash_all_properties_empty
      assert_empty HashJoiner.assign_empty_defaults({}, [], [], [])
    end

    def test_hash
      assert_equal({'foo' => [], 'bar' => {}, 'baz' => ''},
        HashJoiner.assign_empty_defaults({}, ['foo'], ['bar'], ['baz']))
    end

    def test_array_all_properties_empty
      assert_empty HashJoiner.assign_empty_defaults([], [], [], [])
      assert_equal([{}], HashJoiner.assign_empty_defaults([{}], [], [], []))
    end

    def test_array
      assert_equal([{'foo' => [], 'bar' => {}, 'baz' => ''}],
        HashJoiner.assign_empty_defaults([{}], ['foo'], ['bar'], ['baz']))
    end
  end
end
