Gem::Specification.new do |s|
  s.name = 'hash-joiner'
  s.version = '0.0.0'
  s.date = '2014-12-19'
  s.summary = (
    'Module for pruning, promoting, deep-merging, and joining Hash data')
  s.description = (
    'Performs pruning or one-level promotion of Hash attributes (typically ' +
    'labeled "private:"), and deep merges and joins of Hash objects. Works ' +
    'on Array objects containing Hash objects as well.')
  s.authors = ['Mike Bland']
  s.email = 'michael.bland@gsa.gov'
  s.files = ['lib/hash-joiner.rb', 'README.md']
  s.homepage = 'https://github.com/18F/hash-joiner'
  s.license = 'CC0'
  s.add_development_dependency 'rake'
end
