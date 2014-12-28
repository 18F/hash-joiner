require "minitest/autorun"
require "hash-joiner"

module HashJoinerTest
  class PromoteDataTest < ::Minitest::Test
    def test_ignore_if_not_a_collection
      assert_nil HashJoiner.promote_data 27, 'private'
      assert_nil HashJoiner.promote_data 'foobar', 'private'
      assert_nil HashJoiner.promote_data :msb, 'private'
      assert_nil HashJoiner.promote_data true, 'private'
    end

    def test_no_effect_on_empty_collections
      hash_data = {}
      assert_same hash_data, HashJoiner.promote_data(hash_data, 'private')
      assert_empty hash_data

      array_data = []
      assert_same array_data, HashJoiner.promote_data(array_data, 'private')
      assert_empty array_data
    end

    def test_promote_private_hash_data
      data = {
        'name' => 'mbland',
        'private' => {'email' => 'michael.bland@gsa.gov'},
        'full_name' => 'Mike Bland',
      }

      expected = {
        'name' => 'mbland',
        'email' => 'michael.bland@gsa.gov',
        'full_name' => 'Mike Bland',
      }

      assert_same data, HashJoiner.promote_data(data, 'private')
      assert_equal expected, data
    end

    def test_promote_private_array_data
      data = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland'},
        {'private' => [{'name' => 'foobar'}]},
      ]

      expected = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland'},
        {'name' => 'foobar'},
      ]

      assert_same data, HashJoiner.promote_data(data, 'private')
      assert_equal expected, data
    end

    def test_promote_private_data_in_array_at_different_depths
      data =[
        {'name' => 'mbland',
         'full_name' => 'Michael S. Bland',
         'languages' => ['C++'],
         'private' => {
           'full_name' => 'Mike Bland',
           'email' => 'michael.bland@gsa.gov',
           'languages' => ['Python', 'Ruby'],
         },
        },
        {'private' => [
           {'name' => 'foobar',
            'full_name' => 'Foo Bar',
            'email' => 'foo.bar@gsa.gov',
           },
         ],
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
         'email' => 'foo.bar@gsa.gov',
        },
      ]

      assert_same data, HashJoiner.promote_data(data, 'private')
      assert_equal expected, data
    end

    def test_promote_private_data_in_hash_at_different_depths
      data = {
        'team' => [
          {'name' => 'mbland',
           'private' => {'email' => 'michael.bland@gsa.gov'}},
          {'private' => [
            {'name' => 'foobar', 'email' => 'foo.bar@gsa.gov'},
            ],
          },
        ],
        'projects' => [
          {'name' => 'hub', 'private' => {'repo' => '18F/hub'}},
          {'private' => [
            {'name' => 'snippets', 'repo' => '18F/hub'},
            ],
          },
        ],
      }

      expected = {
        'team' => [
          {'name' => 'mbland','email' => 'michael.bland@gsa.gov'},
          {'name' => 'foobar', 'email' => 'foo.bar@gsa.gov'},
        ],
        'projects' => [
          {'name' => 'hub', 'repo' => '18F/hub'},
          {'name' => 'snippets', 'repo' => '18F/hub'},
        ],
      }

      assert_same data, HashJoiner.promote_data(data, 'private')
      assert_equal expected, data
    end
  end
end
