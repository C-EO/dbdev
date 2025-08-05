You can install extensions available on the database.dev registry using the dbdev CLI's `add` command. The dbdev client is itself an extension which you can install by following the instructions below.

## Pre-requisites

Before you can install a package, ensure you have the `pg_tle` extension installed in your database.

!!! note

    If your database is running on Supabase, `pg_tle` is already installed.

!!! warning

    Restoring a logical backup of a database with a TLE installed can fail. For this reason, dbdev should only be used with databases with physical backups enabled.

```sql
create extension if not exists pg_tle;
```

## Use

Once the prerequisites are met, you can create a migration file to install a TLE available on database.dev by running the following dbdev command:

```bash
dbdev add -o <migration_folder_path> -v <version> -s <schema> package -n <package_name>
```

For example, to install `kiwicopple@pg_idkit` version 0.0.4 in `extensions` schema run:

```bash
dbdev add -o "./migrations/" -v 0.0.4 -s extensions package -n kiwicopple@pg_idkit
```

To create a migration file to update to the latest version of a package, you need to specify the `-c` flag with the connection string to your database. The connection is used to check the current version of the package installed in the database and generate a migration file that will update it to the latest version available on database.dev.

```bash
dbdev add -c <postgres_connection_string> -o <migration_folder_path> package -n <package_name>
```
To update the `kiwicopple@pg_idkit` package to the latest version, you can run:

```bash
dbdev add -c "postgresql://postgres:[YOUR-PASSWORD]@[YOUR-HOST]:5432/postgres" -o "./migrations/" package -n kiwicopple@pg_idkit
```

!!! warning

    To generate a correct update migration file, ensure that before running the `dbdev add` command, all existing migrations in the `migrations` folder have been applied to the database. The `dbdev add` command looks for existing installed extensions in the database and generates a migration file that will install the TLE if it is not already installed.
