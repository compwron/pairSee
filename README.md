# PairSee
[![Code Climate](https://codeclimate.com/github/compwron/pairSee/badges/gpa.svg)](https://codeclimate.com/github/compwron/pairSee)
[![Test Coverage](https://codeclimate.com/github/compwron/pairSee/badges/coverage.svg)](https://codeclimate.com/github/compwron/pairSee)
[![Build Status](https://travis-ci.org/compwron/pairSee.svg)](https://travis-ci.org/compwron/pairSee)
[![Dependency Status](https://gemnasium.com/compwron/pairSee.png)](https://gemnasium.com/compwron/pairSee)


Usage cases:
1. See commit count for all devs and solo devs (in order by # of commits): $ pairsee --after 2012-10-01
2. See what cards have been in play and for how long since given date: $ pairsee --cards --after 2012-10-01
3. See all devs and what cards they have worked on since given date: $ pairsee --after 2013-11-01 -s

Example usage: 
```
$ pairsee --root ../../my_code --after 2012-07-10 --config ../../foo/config/config.yml
$ pairsee --extras --root ../../my_code
$ pairsee --latest --after 2012-09-01 # this outputs pairings by most recent by all devs who have committed since given date (purpose of this is to exclude people who are no longer committers)
```

```
Options:
          --root, -r <s>:   Folder in which .git folder is (default: .)
        --config, -c <s>:   location of config file, example: ../../config/config.yml (default: bin/pairsee/../../config/config.yml)
         --after, -a <s>:   Date since which you want to get commits, in yyyy-mm-dd format (default: 0-1-1)
            --extras, -e:   See all commits without the name of any dev in them
            --latest, -l:   See dates of most recent commits by pairs
       --recommended, -o:   See active devs who have not paired (and therefore should)
             --cards, -d:   See cards and number of commits on each
  --cards-per-person, -s:   See cards for each dev
              --help, -h:   Show this message
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

Config file: `config/config.yml`
contains names and card prefix, a la
```
names: Person1 Person2 Person3
card_prefix: FOO-
```

So if your commit log looks like 
"Bob/Alice [FOO-1] wrote code"
"Alice [FOO-1] stuff"
"Sarah|Alice [FOO-2] code and stuff"

Then your config file will look like:
```
names: Bob Alice Sarah
card_prefix: FOO-
```

To use metrics with SVN, check out SVN codebase with git like: `git svn clone http://svn.example.com/project`
