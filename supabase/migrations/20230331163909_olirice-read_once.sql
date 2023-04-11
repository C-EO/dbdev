insert into app.packages(
    handle,
    partial_name,
    control_description,
    control_relocatable,
    control_requires
)
values (
    'olirice',
    'read_once',
    'Send messages that can only be read once',
    false,
    '{pg_cron}'
);


insert into app.package_versions(package_id, version_struct, sql, description_md)
values (
(select id from app.packages where package_name = 'olirice-read_once'),
(0,3,1),
$pkg$

-- Enforce requirements
-- Workaround to https://github.com/aws/pg_tle/issues/183
do $$
    declare
        pg_cron_exists boolean = exists(
            select 1
            from pg_available_extensions
            where
                name = 'pg_cron'
                and installed_version is not null
        );
    begin

        if not pg_cron_exists then
            raise
                exception '"olirice-read_once" requires "pg_cron"'
                using hint = 'Run "create extension pg_cron" and try again';
        end if;
    end
$$;


create schema read_once;

create unlogged table read_once.messages(
    id uuid primary key default gen_random_uuid(),
    contents text not null default '',
    created_at timestamp default now()
);

revoke all on read_once.messages from public;
revoke usage on schema read_once from public;

create or replace function send_message(
    contents text
)
    returns uuid
    security definer
    volatile
    strict
    language sql
    as
$$
    insert into read_once.messages(contents)
    values ($1)
    returning id;
$$;

create or replace function read_message(id uuid)
    returns text
    security definer
    volatile
    strict
    language sql
    as
$$
    delete from read_once.messages
    where read_once.messages.id = $1
    returning contents;
$pkg$,

$description_md$

# read_once

A Supabase application for sending messages that can only be read once

Features:
- messages can only be read one time
- messages are not logged in PostgreSQL write-ahead-log (WAL)

Note: to expose the `send_message` and `read_message` functions over HTTP, install the extension in a schema that is on the search_path.

For example:
```sql
create extension "olirice-read_once"
    schema 'public'
    version '0.3.1';
```

## HTTP API

### Create a Message

```sh
curl -X POST https://<PROJECT_REF>/rest/v1/rpc/send_message \
    -H 'apiKey: <API_KEY>' \
    -H 'Content-Type: application/json'
    --data-raw '{"contents": "hello, dbdev!"}

# Returns: "2989156b-2356-4543-9d1b-19dfb8ec3268"
```

### Read a Message

```sh
curl -X https://<PROJECT_REF>/rest/v1/rpc/read_message
    -H 'apiKey: <API_KEY>' \
    -H 'Content-Type: application/json' \
  --data-raw '{"id": "2989156b-2356-4543-9d1b-19dfb8ec3268"}

# Returns: "hello, dbdev!"
```


## SQL API

### Create a Message

```sql
-- Creates a new messages and returns its unique id
create or replace function send_message(
    contents text
)
    returns uuid
```

### Read a Message

```sql
-- Read a message by its id
create or replace function send_message(
    id uuid
)
    returns text
```
$description_md$
);
