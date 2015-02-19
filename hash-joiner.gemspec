# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hash-joiner/version'

Gem::Specification.new do |s|
  s.name = 'hash-joiner'
  s.version = HashJoiner::VERSION
  s.summary = (
    'Module for pruning, promoting, deep-merging, and joining Hash data')
  s.description = (
    'Performs pruning or one-level promotion of Hash attributes (typically ' +
    'labeled "private:"), and deep merges and joins of Hash objects. Works ' +
    'on Array objects containing Hash objects as well.')
  s.authors = ['Mike Bland']
  s.email = 'michael.bland@gsa.gov'
  s.files = `git ls-files -z README.md lib`.split("\x0")
  s.executables << 'filter-yaml-files'
  s.homepage = 'https://github.com/18F/hash-joiner'
  s.license = 'CC0'
  s.add_runtime_dependency 'safe_yaml'
  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'codeclimate-test-reporter'
end
