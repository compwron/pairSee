Order cards worked with large durations by most recent date worked?


Bring in svn parsing, using svn data in this format:
(created by command: svn log | perl -l40pe 's/^-+/\n/')

Svn data is being read in from file to prevent errors caused by not being able to access the server (assuming that svn log requires that the server be accessible)


 r1196 | committerID | 2013-08-20 18:13:44 -0500 (Tue, 20 Aug 2013) | 2 lines  [cardNumber] Alice and Bob -  commit message

 desired behavior: if there is no name in the commit, use the committerID as the identity. If there are one or more names in the commit message, prefer to use those. 


 fix --extras for SVN mode (should return no commits if all commits have an ID - which I think they do)
 fix --latest for SVN mode (date formatting issue)
 fox --cards for SVN moce (card separator is different - parameterize it?)
 fix --recommended for SVN moce (same date issue as --latest)