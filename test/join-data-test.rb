require_relative "../lib/hash-joiner"
require_relative "test_helper"
require "minitest/autorun"

module HashJoinerTest
  class JoinDataTest < ::Minitest::Test
    def test_ignore_if_rhs_empty
      lhs = {'team' => [{'name' => 'mbland'}]}
      rhs = {}
      assert_same lhs, HashJoiner.join_data('team', 'name', lhs, rhs)
      assert_equal({'team' => [{'name' => 'mbland'}]}, lhs)
    end

    def test_assign_value_if_lhs_empty
      lhs = {}
      rhs = {'team' => [{'name' => 'mbland'}]}
      assert_same lhs, HashJoiner.join_data('team', 'name', lhs, rhs)
      assert_equal rhs, lhs
    end

    def test_overwrite_nonmergeable_values
      lhs = {'team' => 'mbland'}
      rhs = {'team' => 'foobar'}
      assert_same lhs, HashJoiner.join_data('team', 'name', lhs, rhs)
      assert_equal rhs, lhs
    end

    def test_join_hashes_via_deep_merge
      lhs = {'team' => {
        'mbland' => {'languages' => ['C++']},
        'foobar' => {'full_name' => 'Foo Bar'},
        },
      }

      rhs = {
        'team' => {
          'mbland' => {'languages' => ['Python', 'Ruby']},
          'foobar' => {'email' => 'foo.bar@gsa.gov'},
          'bazquux' => {'email' => 'baz.quux@gsa.gov'},
        },
      }

      expected = {
        'team' => {
          'mbland' => {'languages' => ['C++', 'Python', 'Ruby']},
          'foobar' => {
            'full_name' => 'Foo Bar', 'email' => 'foo.bar@gsa.gov'},
          'bazquux' => {'email' => 'baz.quux@gsa.gov'},
        },
      }

      assert_same lhs, HashJoiner.join_data('team', 'name', lhs, rhs)
      assert_equal expected, lhs
    end

    def test_join_arrays_of_hashes
      lhs = {'team' => [
        {'name' => 'mbland', 'languages' => ['C++']},
        {'name' => 'foobar', 'full_name' => 'Foo Bar'},
        ],
      }
      rhs = {
        'team' => [
          {'name' => 'mbland', 'languages' => ['Python', 'Ruby']},
          {'name' => 'foobar', 'email' => 'foo.bar@gsa.gov'},
          {'name' => 'bazquux', 'email' => 'baz.quux@gsa.gov'},
        ],
      }
      expected = {
        'team' => [
          {'name' => 'mbland', 'languages' => ['C++', 'Python', 'Ruby']},
          {'name' => 'foobar', 'full_name' => 'Foo Bar',
           'email' => 'foo.bar@gsa.gov'},
          {'name' => 'bazquux', 'email' => 'baz.quux@gsa.gov'},
        ],
      }
      assert_same lhs, HashJoiner.join_data('team', 'name', lhs, rhs)
      assert_equal expected, lhs
    end
  end
end
