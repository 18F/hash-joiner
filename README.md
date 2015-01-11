## hash-joiner Gem

[![Gem Version](https://badge.fury.io/rb/hash-joiner.svg)](http://badge.fury.io/rb/hash-joiner)
[![Build Status](https://travis-ci.org/18F/hash-joiner.svg?branch=master)](https://travis-ci.org/18F/hash-joiner)
[![Code Climate](https://codeclimate.com/github/18F/hash-joiner/badges/gpa.svg)](https://codeclimate.com/github/18F/hash-joiner)
[![Test Coverage](https://codeclimate.com/github/18F/hash-joiner/badges/coverage.svg)](https://codeclimate.com/github/18F/hash-joiner)

Performs pruning or one-level promotion of `Hash` attributes (typically labeled `private:`), and deep merges and joins of `Hash` objects. Works on `Array` objects containing `Hash` objects as well.

Downloads and API docs are available on the [hash-joiner RubyGems page](https://rubygems.org/gems/hash-joiner). API documentation is written using [YARD markup](http://yardoc.org/).

Contributed by the 18F team, part of the United States General Services Administration: https://18f.gsa.gov/

### Motivation

This gem was extracted from [the 18F Hub Joiner plugin](https://github.com/18F/hub/blob/master/_plugins/joiner.rb). That plugin manipulates [Jekyll-imported data](http://jekyllrb.com/docs/datafiles/) by removing or promoting private data, building indices, and performing joins between different data files so that the results appear as unified collections in Jekyll's `site.data` object. It serves as the first stage in a pipeline that also builds cross-references and canonicalizes data before generating static HTML pages and other artifacts.

### Installation

```
$ gem install hash-joiner
```

### Usage

The typical use case is to have a YAML file containing both public and private data, with all private data nested within `private:` properties:

```ruby
> require 'hash-joiner'
> my_data_collection = {
    'name' => 'mbland', 'full_name' => 'Mike Bland',
    'private' => {
      'email' => 'michael.bland@gsa.gov', 'location' => 'DCA',
    },
  }
```

The following examples, except for **Join an Array of Hash values**, all begin with `my_data_collection` in the above state.  Further examples can be found in the [test/](test/) directory.

#### Strip private data

```ruby
# Everything within the `private:` property will be deleted.
> HashJoiner.remove_data my_data_collection, "private"
=> {"name"=>"mbland", "full_name"=>"Mike Bland"}
```

#### Promote private data

This will render `private:` data at the same level as other, nonprivate data:

```ruby
# Everything within the `private:` property will be
# promoted up one level.
> HashJoiner.promote_data my_data_collection, "private"
=> {"name"=>"mbland", "full_name"=>"Mike Bland",
    "email"=>"michael.bland@gsa.gov", "location"=>"DCA"}
```

#### Perform a deep merge with other Hash values

```ruby
> extra_info = {
  'languages' => ['C++', 'Python'], 'full_name' => 'Michael S. Bland',
  'private' => {
    'location' => 'Alexandria, VA', 'previous_companies' => ['Google'],
    },
  }

# The original Hash will have information added for
# `full_name`, `languages', and `private => location`.
> HashJoiner.deep_merge my_data_collection, extra_info
=> {"name"=>"mbland", "full_name"=>"Michael S. Bland",
    "private"=>{
      "email"=>"michael.bland@gsa.gov", "location"=>"Alexandria, VA",
      "previous_companies"=>["Google"]},
    "languages"=>["C++", "Python"]}

> extra_info = {
    'languages' => ['Ruby'],
    'private' => {
      'previous_companies' => ['Northrop Grumman'],
    },
  }

# The Hash will now have added information for
# `languages` and `private => previous_companies`.
> HashJoiner.deep_merge my_data_collection, extra_info
=> {"name"=>"mbland", "full_name"=>"Michael S. Bland",
    "private"=>{
      "email"=>"michael.bland@gsa.gov", "location"=>"Alexandria, VA",
      "previous_companies"=>["Google", "Northrop Grumman"]},
    "languages"=>["C++", "Python", "Ruby"]}
```

#### Join an Array of Hash values

This corresponds to the process of joining different collections of Jekyll-imported data within the 18F Hub, such as joining `site.data['private']['team']` into `site.data['team']`.

```ruby
# This defines a fake object emulating a Jekyll::Site.
> class DummySite
    attr_accessor :data
    def initialize
      @data = {'private' => {}}
    end
  end

> site = DummySite.new

# This data would correspond to _data/team.yml
# in a Jekyll project.
> site.data['team'] = [
    {'name' => 'mbland', 'languages' => ['C++']},
    {'name' => 'foobar', 'full_name' => 'Foo Bar'},
  ]

# This data would correspond to _data/private/team.yml
# in a Jekyll project.
> site.data['private']['team'] = [
    {'name' => 'mbland', 'languages' => ['Python', 'Ruby']},
    {'name' => 'foobar', 'email' => 'foo.bar@gsa.gov'},
    {'name' => 'bazquux', 'email' => 'baz.quux@gsa.gov'},
  ]

# After joining, each element of `site.data['team']` contains
# the union of the original element and the corresponding
# element in `site.data['private']['team']`.
#
# `site.data['private']` can now be safely discarded.
> HashJoiner.join_data 'team', 'name', site.data, site.data['private']
=> {"private"=>{
      "team"=>[
        {"name"=>"mbland", "languages"=>["Python", "Ruby"]},
        {"name"=>"foobar", "email"=>"foo.bar@gsa.gov"},
        {"name"=>"bazquux", "email"=>"baz.quux@gsa.gov"}]},
    "team"=>[
      {"name"=>"mbland", "languages"=>["C++", "Python", "Ruby"]},
      {"name"=>"foobar", "full_name"=>"Foo Bar", "email"=>"foo.bar@gsa.gov"},
      {"name"=>"bazquux", "email"=>"baz.quux@gsa.gov"}]}
```

### Running `filter-yaml-files`

The `filter-yaml-files` program can be used to generate "public" versions of YAML files containing "private" data. For example:

```
$ export DATA_DIR=../hub/_data

$ filter-yaml-files ${DATA_DIR}/private/{team,projects}.yml -o ${DATA_DIR}/public
../hub/_data/private/team.yml => ../hub/_data/public/team.yml
../hub/_data/private/projects.yml => ../hub/_data/public/projects.yml
```

The `filter-yaml-files` program can also strip other properties besides `private:`, and can promote data contained within a property rather than strip it. Run `filter-yaml-files -h` to see the options that allow this.

### Contributing

Just fork [18F/hash-joiner](https://github.com/18F/hash-joiner) and start sending pull requests! Feel free to ping [@mbland](https://github.com/mbland) with any questions you may have, especially if the current documentation should've addressed your needs, but didn't.

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
