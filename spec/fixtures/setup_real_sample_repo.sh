# intended to be run from pairSee root dir
ln -s `pwd`/bin/pairsee ~/bin/pairsee
rm -rf spec/fixtures/example_usage_of_pairsee
mkdir spec/fixtures/example_usage_of_pairsee
cd spec/fixtures/example_usage_of_pairsee
git init                                                          
echo bar >> foo.txt ; git add -A ; git commit -m "noone foo"                       
echo bar >> foo.txt ; git add -A ; git commit -m "Person1/Person3 [FOO-1] foo"     
echo bar >> foo.txt ; git add -A ; git commit -m "Person2/Person3 [FOO-1] foo"     
echo bar >> foo.txt ; git add -A ; git commit -m "Person1/Person2 [FOO-3] foo"     
echo bar >> foo.txt ; git add -A ; git commit -m "Person1/Person3 [FOO-100] foo"   
echo bar >> foo.txt ; git add -A ; git commit -m "Person1/Person3 [FOO-001] foo"   
cd -
pairsee -r spec/fixtures/example_usage_of_pairsee -c config/sample_config.yml
pairsee -r spec/fixtures/example_usage_of_pairsee -c config/sample_config.yml -h
pairsee -r spec/fixtures/example_usage_of_pairsee -c config/sample_config.yml -e
pairsee -r spec/fixtures/example_usage_of_pairsee -c config/sample_config.yml -l
pairsee -r spec/fixtures/example_usage_of_pairsee -c config/sample_config.yml -d
pairsee -r spec/fixtures/example_usage_of_pairsee -c config/sample_config.yml -s
rm -rf spec/fixtures/example_usage_of_pairsee # comment this out in order to leave sample repo in place for later examination