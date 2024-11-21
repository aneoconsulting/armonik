#!/bin/bash

# warm up run
./htcmock-1k.sh

#clearmeasured runs
./htcmock-1k.sh >> ../stats/1k.json && ./htcmock-5k.sh >> ../stats/5k.json && ./htcmock-10k.sh >> ../stats/10k.json && ./htcmock-100k.sh >> ../stats/100k.json && ./htcmock-1m.sh >> ../stats/1m.json
#clean the output file
../python-scripts/cleaner.py 

#merge json files
../python-scripts/merge-jsons.py

# save and print pretty json file
jq . ../stats/results.json > ../stats/pretty-results.json
jq . ../stats/pretty-results.json