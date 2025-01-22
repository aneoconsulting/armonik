# Results

The results table contains data for <!-- TODO: write description -->.

::alert{type="info"}
In the database, the table name is `Result`. :warning: Table name has no `Data` suffix like other tables.
::

## Table Structure

| Column Name | Type | Description |
| ----------- | ---- | ----------- |

## Table Data

Here an example of the table data:

```json
[
  {
    "_id": "79b92458-e9a1-4c99-b3a5-d8c3fb510f14",
    "SessionId": "29fa8ea4-f287-4104-a5d7-732d19260c1b",
    "Name": "4a3b5f41-61c5-4ebd-a2dd-8046094d2376",
    "OwnerTaskId": "8e48ebd9-777b-419c-9153-5ae2de9ac929",
    "Status": 2,
    "DependentTasks": [],
    "CreationDate": "2023-07-08T11:15:33.405Z",
    "Data": ""
  },
  {
    "_id": "592f4b86-397a-4427-a896-8bb9de7ed489",
    "SessionId": "29fa8ea4-f287-4104-a5d7-732d19260c1b",
    "Name": "531782a9-0ca7-40fd-a9ff-a250a94ff0a8",
    "OwnerTaskId": "3d47e6fe-3e63-4c6b-b301-ad2ca7a4fc4d",
    "Status": 2,
    "DependentTasks": [
      "8e48ebd9-777b-419c-9153-5ae2de9ac929"
    ],
    "CreationDate": "2023-07-08T11:15:37.264Z",
    "Data": ""
  }
]
```
