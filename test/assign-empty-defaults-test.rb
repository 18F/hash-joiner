require_relative "../lib/hash-joiner"
require_relative "test_helper"
require "minitest/autorun"

module HashJoinerTest
  class AssignEmptyDefaultsTest < ::Minitest::Test
    def test_hash_all_properties_empty
      assert_empty HashJoiner.assign_empty_defaults({}, [], [], [])
    end

    def test_empty_hash
      assert_equal({'foo' => [], 'bar' => {}, 'baz' => ''},
        HashJoiner.assign_empty_defaults({}, ['foo'], ['bar'], ['baz']))
    end

    def test_array_all_properties_empty
      assert_empty HashJoiner.assign_empty_defaults([], [], [], [])
      assert_equal([{}], HashJoiner.assign_empty_defaults([{}], [], [], []))
    end

    def test_empty_array
      assert_equal([{'foo' => [], 'bar' => {}, 'baz' => ''}],
        HashJoiner.assign_empty_defaults([{}], ['foo'], ['bar'], ['baz']))
    end

    def test_do_not_overwrite_existing_values
      original = {'foo' => [1], 'bar' => {'k' => 2}, 'baz' => '3'}
      assert_equal({'foo' => [1], 'bar' => {'k' => 2}, 'baz' => '3'},
        HashJoiner.assign_empty_defaults(original, ['foo'], ['bar'], ['baz']))
    end
  end
end
