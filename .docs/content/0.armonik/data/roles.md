# Roles

The roles table contains data for the available roles for users

::alert{type="info"}
In the database, the table name is `RoleData`.
::

## Table Structure

| Column Name | Type | Description |
| ----------- | ---- | ----------- |
| _id | ObjectId | Role Id |
| Permissions | list of strings | List of user permissions. Check out the [authentication documentation](https://github.com/aneoconsulting/ArmoniK.Core/blob/main/.docs/content/1.concepts/6.authentication.md) for more information. |
| RoleName | string | Role name |

## Table Data

Here an example of the table data:

```json
[
  {
    "_id":{
      "$oid":"64ad1b8954ef712cc099e9e4"
    },
    "Permissions":[
      "Submitter:GetServiceConfiguration",
      "Submitter:CountTasks",
      "Submitter:GetTaskStatus",
      "Submitter:GetResultStatus",
      "Submitter:ListTasks",
      "Submitter:ListSessions",
      "Sessions:GetSession",
      "Sessions:ListSessions",
      "Tasks:GetTask",
      "Tasks:ListTasks",
      "Tasks:GetResultIds",
      "Results:GetOwnerTaskId"
    ],
    "RoleName":"Monitoring"
  },
  {
    "_id":{
      "$oid":"64ad1b8954ef712cc099e9e5"
    },
    "Permissions":[
      "Submitter:GetServiceConfiguration",
      "Submitter:CancelSession",
      "Submitter:CancelTasks",
      "Submitter:CreateSession",
      "Submitter:CreateSmallTasks",
      "Submitter:CreateLargeTasks",
      "Submitter:CountTasks",
      "Submitter:TryGetResultStream",
      "Submitter:WaitForCompletion",
      "Submitter:TryGetTaskOutput",
      "Submitter:WaitForAvailability",
      "Submitter:GetTaskStatus",
      "Submitter:GetResultStatus",
      "Submitter:ListTasks",
      "Submitter:ListSessions",
      "Sessions:CancelSession",
      "Sessions:GetSession",
      "Sessions:ListSessions",
      "Tasks:GetTask",
      "Tasks:ListTasks",
      "Tasks:GetResultIds",
      "Results:GetOwnerTaskId",
      "General:Impersonate"
    ],
    "RoleName":"Submitter"
  }
]

```
