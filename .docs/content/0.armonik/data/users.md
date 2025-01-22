# Users

The users table contains data for the users and their respective roles.

::alert{type="info"}
In the database, the table name is `UserData`.
::

## Table Structure

| Column Name | Type | Description |
| ----------- | ---- | ----------- |
| _id | ObjectId | User Id |
| Username | string | User name |
| Roles | list of ObjectId | List of roles of the user. The roles are defined in the [roles table](roles.md) `RoleData`

## Table Data

Here an example of the table data:

```json
[
  {
    "_id":{
      "$oid":"64ad1b8940ca17b5b5b0fe61"
    },
    "Username":"Monitoring",
    "Roles":[
      {
        "$oid":"64ad1b8954ef712cc099e9e4"
      }
    ]
  },
  {
    "_id":{
      "$oid":"64ad1b8940ca17b5b5b0fe62"
    },
    "Username":"Submitter",
    "Roles":[
      {
        "$oid":"64ad1b8954ef712cc099e9e5"
      }
    ]
  }
]

```
