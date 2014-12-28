## hash-joiner Gem

Performs pruning or one-level promotion of `Hash` attributes (typically labeled `private:`), and deep merges and joins of `Hash` objects. Works on `Array` objects containing `Hash` objects as well.

Downloads and API docs are available on the [hash-joiner RubyGems page](https://rubygems.org/gems/hash-joiner).

### Motivation

This gem was extracted from [the 18F Hub Joiner plugin](https://github.com/18F/hub/blob/master/_plugins/joiner.rb). That plugin manipulates [Jekyll-imported data](http://jekyllrb.com/docs/datafiles/) by removing or promoting private data, building indices, and performing joins between different data files so that the results appear as unified collections in Jekyll's `site.data` object. It serves as the first stage in a pipeline that also builds cross-references and canonicalizes data before generating static HTML pages and other artifacts.

### Usage

The typical use case is to have a YAML file containing both public and private data, with all private data nested within `private:` properties:

```
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

```
> HashJoiner.remove_data my_data_collection, "private"
=> {"name"=>"mbland", "full_name"=>"Mike Bland"}
```

#### Promote private data

This will render `private:` data at the same level as other, nonprivate data:

```
> HashJoiner.promote_data my_data_collection, "private"
=> {"name"=>"mbland", "full_name"=>"Mike Bland",
    "email"=>"michael.bland@gsa.gov", "location"=>"DCA"}
```

#### Perform a deep merge with other Hash values

```
> extra_info = {
  'languages' => ['C++', 'Python'], 'full_name' => 'Michael S. Bland',
  'private' => {
    'location' => 'Alexandria, VA', 'previous_companies' => ['Google'],
    },
  }

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

> HashJoiner.deep_merge my_data_collection, extra_info
=> {"name"=>"mbland", "full_name"=>"Michael S. Bland",
    "private"=>{
      "email"=>"michael.bland@gsa.gov", "location"=>"Alexandria, VA",
      "previous_companies"=>["Google", "Northrop Grumman"]},
    "languages"=>["C++", "Python", "Ruby"]}
```

#### Join an Array of Hash values

This corresponds to the process of joining different collections of Jekyll-imported data within the 18F Hub, such as joining `site.data['private']['team']` into `site.data['team']`.

```
> class DummySite
    attr_accessor :data
    def initialize
      @data = {'private' => {}}
    end
  end

> site = DummySite.new

> site.data['team'] = [
    {'name' => 'mbland', 'languages' => ['C++']},
    {'name' => 'foobar', 'full_name' => 'Foo Bar'},
  ]

> site.data['private']['team'] = [
    {'name' => 'mbland', 'languages' => ['Python', 'Ruby']},
    {'name' => 'foobar', 'email' => 'foo.bar@gsa.gov'},
    {'name' => 'bazquux', 'email' => 'baz.quux@gsa.gov'},
  ]

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

### Contributing

Just fork [18F/hash-joiner](https://github.com/18F/hash-joiner) and start sending pull requests! Feel free to ping [@mbland](https://github.com/mbland) with any questions you may have, especially if the current documentation should've addressed your needs, but didn't.

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
