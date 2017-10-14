- see devs on longest running cards
- see cards still in progress (all commits, with commits within the last x days)
- feature "cards without more than one developer"



- fix bug in "last commit" in -d, dates are not accurate
- sort --latest by commit date

- Rakefile / rake_commit
- Reduce number of git/filesystem interactions in spec

Fix this bug:
DMM-103 - - - commits: 7 - - - duration: 0 days - - - last commit: 2017-03-07 - - - commits per day: Infinity
DMM-17 - - - commits: 71 - - - duration: -1 days - - - last commit: 2017-04-06 - - - commits per day: -71.0
DMM-39 - - - commits: 6 - - - duration: -6 days - - - last commit: 2017-04-12 - - - commits per day: -1.0
DMM-81 - - - commits: 3 - - - duration: -6 days - - - last commit: 2017-03-08 - - - commits per day: -0.5
DMM-136 - - - commits: 33 - - - duration: -33 days - - - last commit: 2017-05-30 - - - commits per day: -1.0
