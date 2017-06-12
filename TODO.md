- Fix bug in --extras where multi-name users are shown in extras
- multiple codebases?
- fix bug in "last commit" in -d, dates are not accurate
- sort --latest by commit date
- multiple card starters

- Rakefile / rake_commit
- Reduce number of git/filesystem interactions in spec
- aggregate stats across multiple git repos
- label for "BAD" to most-solo-commits view
- Graph over time of cards worked on and duration
- add COLOR to graph / outputs - use vlad's color library?
- sort -s by # cards worked

- standardize quotes

Fix this bug:
DMM-103 - - - commits: 7 - - - duration: 0 days - - - last commit: 2017-03-07 - - - commits per day: Infinity
DMM-17 - - - commits: 71 - - - duration: -1 days - - - last commit: 2017-04-06 - - - commits per day: -71.0
DMM-39 - - - commits: 6 - - - duration: -6 days - - - last commit: 2017-04-12 - - - commits per day: -1.0
DMM-81 - - - commits: 3 - - - duration: -6 days - - - last commit: 2017-03-08 - - - commits per day: -0.5
DMM-136 - - - commits: 33 - - - duration: -33 days - - - last commit: 2017-05-30 - - - commits per day: -1.0