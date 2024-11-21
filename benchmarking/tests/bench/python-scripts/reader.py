#! /usr/bin/env python3

import json
from pytimeparse import parse
import matplotlib.pyplot as plt
import numpy as np


# Class test_case
# An object store a lists of the stats of all the runs of the test case
# So we could calculate the mean and the median of each stat
class TestCase:

    def __init__(self, file):
        self.nbtasks = []
        self.time = []
        self.exec_time = []
        self.sub_time = []
        self.retrv_time = []
        self.throughput = []
        self.d_parallel = []
        self.file = file
        with open(file) as my_bench_file:
            data = my_bench_file.read()
        # case = TestCase()
        runs = json.loads(data)

        for run in runs:
            if run["nb_pods"] == 100:
                self.nbtasks.append(run["TotalTasks"])
                self.time.append(float(parse(run["ElapsedTime"])))
                self.exec_time.append(float(parse(run["TasksExecutionTime"])))
                self.sub_time.append(float(parse(run["SubmissionTime"])))
                self.retrv_time.append(float(parse(run["ResultRetrievingTime"])))
                self.throughput.append(float(run["throughput"]))
                self.d_parallel.append(run["DegreeOfParallelism"])


if __name__ == "__main__":

    files = ['../stats/1k.json', '../stats/5k.json', '../stats/10k.json', '../stats/100k.json', '../stats/1m.json']
    JsonFiles = [x for x in files if x.endswith(".json")]

    # dictionary to store the stats of each test case
    cases = {
    }
    cases["1k"] = TestCase(JsonFiles[0])
    cases["5k"] = TestCase(JsonFiles[1])
    cases["10k"] = TestCase(JsonFiles[2])
    cases["100k"] = TestCase(JsonFiles[3])
    cases["1m"] = TestCase(JsonFiles[4])

    # Dictionary to store the mean of each test case
    mean = {
        "time": {},
        "exec_time": {},
        "sub_time": {},
        "retrv_time": {},
        "throughput": {}
    }

    # calculate the mean of each test case
    for file in files:
        filename = file.split(".")[0]
        mean["time"][filename] = np.mean(cases[filename].time)
        mean["exec_time"][filename] = np.mean(cases[filename].exec_time)
        mean["sub_time"][filename] = np.mean(cases[filename].sub_time)
        mean["retrv_time"][filename] = np.mean(cases[filename].retrv_time)
        mean["throughput"][filename] = np.mean(cases[filename].throughput)

    # print the stats
    for file in files:
        filename = file.split(".")[0]
        print('Degree of parallelism of retrieving time is : ' + str(cases[filename].d_parallel[0]))
        print('mean total time for treatment of ' + filename + ' tasks is : ' + str(
            mean["time"][filename]) + ' s')
        print('mean time of the execution of ' + filename + ' tasks is : ' + str(
            mean["exec_time"][filename]) + ' s')
        print('mean time of the submission of ' + filename + ' tasks is : ' + str(
            mean["sub_time"][filename]) + ' s')
        print('mean time of the retrieving of ' + filename + ' tasks is : ' + str(
            mean["retrv_time"][filename]) + ' s')
        print('mean throughput for ' + filename + ' tasks is : ' + str(
            mean["throughput"][filename]) + " tasks/s \n")
