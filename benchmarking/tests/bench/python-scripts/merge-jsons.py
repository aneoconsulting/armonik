#! /usr/bin/env python3

import json
import re
from jsonmerge import merge

with open("../../../../versions.tfvars.json", "r") as versions:
    infra = json.load(versions)
with open("../stats/test-env.json", "r") as test_env:
    env = (json.load(test_env))
with open("../stats/1k.json", "r") as stats:
    result_1k = json.load(stats)
with open("../stats/5k.json", "r") as stats:
    result_5k = json.load(stats)
with open("../stats/10k.json", "r") as stats:
    result_10k = json.load(stats)
with open("../stats/100k.json", "r") as stats:
    result_100k = json.load(stats)
with open("../stats/1m.json", "r") as stats:
    result_1m = json.load(stats)
# print(merged)
with open("../stats/results.json", "w") as r:
    dict_json = [merge(infra, env), result_1k, result_5k, result_10k, result_100k, result_1m]
    json.dump(dict_json, r)
