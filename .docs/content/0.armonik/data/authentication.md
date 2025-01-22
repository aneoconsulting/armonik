# Authentication

The authentication table contains data regarding the user certificates. It associates the users in the [users table](users.md) `UserData` with a given certificate stored as a `Fingerprint` and `CN` (Common Name) pair.

::alert{type="info"}
In the database, the table name is `AuthData`.
::

## Table Structure

| Column Name | Type | Description |
| ----------- | ---- | ----------- |
| _id | ObjectId | Entry Id |
| CN | string | Common name of the certificate |
| Fingerprint | string or null | Fingerprint of the certificate. If missing, matches all certificates of this CN |
| UserId | ObjectId | Id of the user associated with this entry |

## Table Data

Here an example of the table data:

```json
[
  {
    "_id":{
      "$oid":"64ad1b8940ca17b5b5b0fe64"
    },
    "CN":"bbHOYhYoXfmoYXph",
    "Fingerprint":"df4e6c3ec7919f42fd678f3d3b63404bc51772e6",
    "UserId":{
      "$oid":"64ad1b8940ca17b5b5b0fe61"
    }
  },
  {
    "_id":{
      "$oid":"64ad1b8940ca17b5b5b0fe65"
    },
    "CN":"ysNSsPfNZsPdLPhW",
    "Fingerprint":"4186d87b818faaaa9c069d54787b2ac02d3b91eb",
    "UserId":{
      "$oid":"64ad1b8940ca17b5b5b0fe62"
    }
  }
]
```
