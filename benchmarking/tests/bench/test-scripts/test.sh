#!/bin/bash

# warm up run
./bench-1k.sh

#clearmeasured runs
./bench-1k.sh >> ../stats/1k.json && ./bench-5k.sh >> ../stats/5k.json && ./bench-10k.sh >> ../stats/10k.json && ./bench-100k.sh >> ../stats/100k.json && ./bench-1m.sh >> ../stats/1m.json
#clean the output file
../python-scripts/cleaner.py

#merge json files
../python-scripts/merge-jsons.py

# save and print pretty json file
jq . ../stats/results.json > ../stats/pretty-results.json
jq . ../stats/pretty-results.json

#print the test stats and plot graphs
#../python-scripts/reader.py

