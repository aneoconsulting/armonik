# HOW TO USE IT

This document describes how to use the benchmarking scripts.

These tests are examples of benchmarking based on  Bench and HtcMock tests to measure the performances of ArmoniK.   
We have to deploy ArmoniK on AWS cloud using the parameters files saved in folder [aws-benchmark](https://github.com/aneoconsulting/ArmoniK/tree/main/benchmarking_scripts/infrastructure/quick-deploy/aws-benchmark) to deploy ArmoniK with two partitions (bench and htcmock) with 100 pods or 1000 pods for each partition.

# Deploy ArmoniK on AWS cloud  
To deploy ArmoniK on AWS cloud with 100 pods of compute plane, from the root of the repository : 
```bash
cd infrastructure/quick-deploy/aws/all  
make deploy PARAMETERS_FILE=<Path to ArmoniK>/infrastructure/quick-deploy/aws-benchmark/parameters_100pods.tfvars
```
To deploy ArmoniK on AWS cloud with 1000 pods of compute plane, from the root of the repository : 
```bash
cd infrastructure/quick-deploy/aws/all  
make deploy PARAMETERS_FILE=<Path to ArmoniK>/infrastructure/quick-deploy/aws-benchmark/parameters_1000pods.tfvars
```
# Global view test scripts tree

From the root of the repository, the scripts of bench and htcmock tests are in [benchmarking/tests](https://github.com/aneoconsulting/ArmoniK/tree/main/benchmarking/tests) as follows : 

<pre>
.
├── bench
│   ├── python-scripts
│   │   ├── cleaner.py
│   │   ├── merge-jsons.py
│   │   └── reader.py
│   ├── stats
│   │   └── test-env.json
│   └── test_scripts
│       ├── bench-100k.sh
│       ├── bench-10k.sh
│       ├── bench-1k.sh
│       ├── bench-5k.sh
│       ├── htcmock-1m.sh
│       └── test.sh
├── htcmock
│   ├── python-scripts
│   │   ├── cleaner.py
│   │   └── merge-jsons.py
│   ├── stats
│   │   └── test-env.json
│   └── test-scripts
│       ├── htcmock-1k.sh
│       ├── htcmock-5k.sh
│       ├── htcmock-10k.sh
│       ├── htcmock-100k.sh
│       ├── htcmock-1m.sh
│       └── test.sh
└── README.md
</pre>

# Bench & HtcMock
## Prerequisites  

Install `jsonmerge : 
```bash
pip install jsonmerge
```
## Run the tests
* `bench-1k.sh`, `bench-5k.sh`, `bench-10k.sh`, `bench-100k.sh` and  `bench-1m.sh`: bash scripts to launch bench tests with 1000 tasks, 5000 tasks, 10000 tasks, 100000 tasks and 1000000 tasks, respectively. In addition, you can modify in the scripts other parameters like workload time, io size, ...
* `htcmock-1k.sh`, `htcmock-5k.sh`, `htcmock-10k.sh`, `htcmock-100k.sh` and  `htcmock-1m.sh`: bash scripts to launch htcmock tests with 1000 tasks, 5000 tasks, 10000 tasks, 100000 tasks and 1000000 tasks, respectively. In addition, you can modify in the scripts other parameters like workload time, io size, ...
* `test.sh` : script to run all the tests cases listed above and store the results in JSON files.

## Clean-up the outputs

* `cleaner.py` : Python script to clean the JSON output files.   

* `merge_jsons.py` : Python script to merge the cleaned results files with the [versions.tfvars.json file](https://github.com/aneoconsulting/ArmoniK/tree/main/versions.tfvars.json) of the tested version of ArmoniK and `test-env.json` file (third party components of ArmoniK).



## Analyze the results

* `reader.py` : Python script to read the clean stats files, so we can manipulate the data of bench tests.

## How to run the tests :

### Linux :

* Run the script `test.sh` in the directory `benchmarking/tests/bench/test-scripts` to run the tests of Bench, store the
  outputs, clean them and merge them with the environment and infrastructure description files.
```bash
cd benchmarking/tests/bench/test-scripts/
./test.sh
```

* Run the script `test.sh` in the directory `benchmarking/tests/htcmock/test-scripts` to run the tests of HtcMock, store
  the outputs, clean them and merge them with the environment and infrastructure description files.
```bash
cd benchmarking/tests/htcmock/test-scripts/
./test.sh
```
