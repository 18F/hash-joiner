## hash-joiner Gem

Performs pruning or one-level promotion of `Hash` attributes (typically labeled `"private"`) and deep joins of `Hash` objects. Works on `Array` objects containing `Hash` objects as well.

The typical use case is to have a YAML file containing both public and private data, with all private data nested within "private" properties:

```
my_data_collection = {
  'name' => 'mbland', 'full_name' => 'Mike Bland',
  'private' => {
    'email' => 'michael.bland@gsa.gov', 'location' => 'DCA',
   },
}
```

### Contributing

Just fork [18F/hash-joiner](https://github.com/18F/hash-joiner) and start sending pull requests! Feel free to ping @mbland with any questions you may have, especially if the current documentation should've addressed your needs, but didn't.

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
