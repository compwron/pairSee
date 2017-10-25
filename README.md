# PairSee

[![Code Climate](https://codeclimate.com/github/compwron/pairSee/badges/gpa.svg)](https://codeclimate.com/github/compwron/pairSee)
[![Test Coverage](https://codeclimate.com/github/compwron/pairSee/badges/coverage.svg)](https://codeclimate.com/github/compwron/pairSee)
[![Build Status](https://travis-ci.org/compwron/pairSee.svg)](https://travis-ci.org/compwron/pairSee)
[![Dependency Status](https://gemnasium.com/badges/github.com/compwron/pairSee.svg)](https://gemnasium.com/github.com/compwron/pairSee)
[![Gem Version](https://img.shields.io/gem/v/pair_see.svg)](https://rubygems.org/gems/pair_see)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)


Usage cases:
* See commit count for all devs and solo devs (in order by # of commits): $ pairsee --after 2012-10-01
* See what cards have been in play and for how long since given date: $ pairsee --cards --after 2012-10-01
* See all devs and what cards they have worked on since given date: $ pairsee --after 2013-11-01 -s

Example usage:
```
$ pairsee --after 2012-07-10 --config ../../foo/config/config.yml
$ pairsee --extras
$ pairsee --cards
```

```
Options:
  -c, --config=<s>          location of config file, example: ../../config/config.yml (default: config/config.yml)
  -a, --after=<s>           Date since which you want to get commits, in yyyy-mm-dd format (default: 0-1-1)
  -e, --extras              See all commits without the name of any dev in them
  -l, --latest              See dates of most recent commits by pairs
  -r, --recommended         See active devs who have not paired (and therefore should)
  -d, --cards               See cards and number of commits on each
  -s, --cards-by-commits    This goes with --cards and sorts by number of commits instead of active card days
  -p, --cards-per-person    See cards for each dev
  -k, --knowledge-debt      Knowledge debt (cards that only one person worked on)
  -m, --my-pairs            Most recent dates of pairing for user
  -h, --help                Show this message

```

Example config file (see also config/config.yml.sample)
```
names:
  - Person1
  - Person2
  - ManyNamesPerson mnperson mprss
card_prefix:
  - FOO-
  - BAR-
roots:
  - /Users/foo/repo1/
  - /Users/foo/repositories/repo2
  - /Users/foo/repositories/baz/repo3
```

to put on path:
```
cd pairSee
ln -s `pwd`/bin/pairsee ~/bin/pairsee
```

Run tests:
```
rspec
# or
rake_commit
```

To use PairSee with SVN, check out SVN codebase with git like: `git svn clone http://svn.example.com/project`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

```
rubocop --auto-correct
rubocop --auto-gen-config 
```
