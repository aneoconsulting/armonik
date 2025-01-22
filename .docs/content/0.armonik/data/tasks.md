# Tasks

The users table contains data for <!-- TODO: write description -->.

::alert{type="info"}
In the database, the table name is `TaskData`.
::

## Table Structure

| Column Name | Type | Description |
| ----------- | ---- | ----------- |

## Task Status

## Table Data

Here an example of the table data:

```json
[
  {
    "_id": "d9b1d8e7-140b-47c0-9866-0779fb0bdda1",
    "SessionId": "29fa8ea4-f287-4104-a5d7-732d19260c1b",
    "OwnerPodId": "10.42.0.32",
    "OwnerPodName": "compute-plane-default-77c8fdbf95-4grsj",
    "PayloadId": "d9b1d8e7-140b-47c0-9866-0779fb0bdda1",
    "ParentTaskIds": [
      "29fa8ea4-f287-4104-a5d7-732d19260c1b"
    ],
    "DataDependencies": [],
    "RemainingDataDependencies": {},
    "ExpectedOutputIds": [
      "79b92458-e9a1-4c99-b3a5-d8c3fb510f14"
    ],
    "InitialTaskId": "d9b1d8e7-140b-47c0-9866-0779fb0bdda1",
    "RetryOfIds": [],
    "Status": 4,
    "StatusMessage": "",
    "Options": {
      "MaxDuration": "00:05:00",
      "MaxRetries": 2,
      "Options": {},
      "Priority": 1,
      "PartitionId": "default",
      "ApplicationName": "ArmoniK.Samples.SymphonyPackage",
      "ApplicationVersion": "2.0.0",
      "ApplicationService": "",
      "ApplicationNamespace": "ArmoniK.Samples.Symphony.Packages",
      "EngineType": "Symphony"
    },
    "CreationDate": "2023-07-08T11:15:34.048Z",
    "SubmittedDate": "2023-07-08T11:15:34.439Z",
    "StartDate": "2023-07-08T11:15:34.963Z",
    "EndDate": "2023-07-08T11:15:38.199Z",
    "ReceptionDate": "2023-07-08T11:15:34.457Z",
    "AcquisitionDate": "2023-07-08T11:15:34.730Z",
    "PodTtl": "2023-07-08T11:15:34.963Z",
    "ProcessingToEndDuration": "00:00:03.2363477",
    "CreationToEndDuration": "00:00:04.1516866",
    "Output": {
      "Success": true,
      "Error": ""
    }
  },
  {
    "_id": "6e74f7a3-d6e4-477a-93f2-3f19001b945a",
    "SessionId": "29fa8ea4-f287-4104-a5d7-732d19260c1b",
    "OwnerPodId": "10.42.0.32",
    "OwnerPodName": "compute-plane-default-77c8fdbf95-4grsj",
    "PayloadId": "6e74f7a3-d6e4-477a-93f2-3f19001b945a",
    "ParentTaskIds": [
      "29fa8ea4-f287-4104-a5d7-732d19260c1b",
      "d9b1d8e7-140b-47c0-9866-0779fb0bdda1"
    ],
    "DataDependencies": [],
    "RemainingDataDependencies": {},
    "ExpectedOutputIds": [
      "592f4b86-397a-4427-a896-8bb9de7ed489"
    ],
    "InitialTaskId": "6e74f7a3-d6e4-477a-93f2-3f19001b945a",
    "RetryOfIds": [],
    "Status": 4,
    "StatusMessage": "",
    "Options": {
      "MaxDuration": "00:05:00",
      "MaxRetries": 2,
      "Options": {},
      "Priority": 1,
      "PartitionId": "default",
      "ApplicationName": "ArmoniK.Samples.SymphonyPackage",
      "ApplicationVersion": "2.0.0",
      "ApplicationService": "",
      "ApplicationNamespace": "ArmoniK.Samples.Symphony.Packages",
      "EngineType": "Symphony"
    },
    "CreationDate": "2023-07-08T11:15:37.541Z",
    "SubmittedDate": "2023-07-08T11:15:38.144Z",
    "StartDate": "2023-07-08T11:15:38.280Z",
    "EndDate": "2023-07-08T11:15:38.493Z",
    "ReceptionDate": "2023-07-08T11:15:38.241Z",
    "AcquisitionDate": "2023-07-08T11:15:38.258Z",
    "PodTtl": "2023-07-08T11:15:38.280Z",
    "ProcessingToEndDuration": "00:00:00.2124666",
    "CreationToEndDuration": "00:00:00.9524081",
    "Output": {
      "Success": true,
      "Error": ""
    }
  }
]
```
