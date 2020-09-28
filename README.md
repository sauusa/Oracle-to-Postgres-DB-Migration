# Oracle to Postgres DB Migration

## in Python:

The oracle2postgres package can be used to migrate data from Oracle to Postgres. It uses SQLAlchemy as an intermediary to map data types between the two database systems. The approach is hacky, but it worked for us! 

### Example Notebook

For example usage, see the Jupyter Notebook at: [https://github.com/MIT-LCP/oracle-to-postgres/blob/master/migration.ipynb](https://github.com/MIT-LCP/oracle-to-postgres/blob/master/migration.ipynb).

### Instructions for use

1. `pip install oracle2postgres`
2. Follow the instructions in the Jupyter Notebook at: [https://github.com/MIT-LCP/oracle-to-postgres/blob/master/migration.ipynb](https://github.com/MIT-LCP/oracle-to-postgres/blob/master/migration.ipynb).

## using ora2pg tool:

Ora2pg is a powerful Perl script for migrating from an Oracle (or MySQL) database into a Postgres database.
If you're using Ora2Pg tool for migration from Oracle/MySql to PostgreSQL then please follow the steps below:
http://ora2pg.darold.net/start.html

Note: Use Encryption in config files for data security

## Docker container for ora2pg

Ora2pg is **highly** configurable, so study the docs carefully as it can probably do what you need: https://ora2pg.darold.net/documentation.html

This example is a full migration from scratch.

```bash
# build the docker container
docker build -t ora2pg:20 .

# create a migration directory (to be mounted)
mkdir -p migrations && cd migrations;

# start the container interactively
docker container run --rm -it -v ${PWD}:/migrations ora2pg bash;

# create the full migration template 
cd migrations;
ora2pg --project_base ./ --init_project migration_01;
cd migration_01;

# edit ./config/ora2pg.conf and set values for:
# - ORACLE_DSN
# - ORACLE_USER
# - ORACLE_PWD
# - SCHEMA
# (or MySQL equivalents)

# run the schema migration (this may take a while...)
./export_schema.sh; 

# inspect ./reports and ./schema; edit if required

# export data (this will take a while...)
ora2pg -t COPY -o data.sql -b ./data -c ./config/ora2pg.conf;

# follow prompts and import data
./import_all.sh -x -h <HOST> -p <PORT> -U <USER> -o <OWNER> -d <DB>

```

### Tips

* if your Postgres database is running on the local host, you can access it from within a container using the hostname: `host.docker.internal`. Example: `psql -h host.docker.internal -p 5000 -U postgres`

* if you see a lot of error messages during import, then try using this flag: `psql -v ON_ERROR_STOP=1 ...args`.

* alternatively, modify `./data/data.sql` to add the following line at the start: `\set ON_ERROR_STOP ON`

* you can run `import_all.sh` as a dry-run to get the list of psql calls. You can then run them manually. 

### Manual imports

Instead of running `./import_all.sh`, you can run import commands manually if you wish:

```bash
LINK="-h host.docker.internal -p 5000 -U postgres"
DB="tec"
dropdb $LINK $DB
createdb -E UTF8 --owner postgres $LINK $DB
psql --single-transaction  $LINK -d $DB -f ./schema/tables/table.sql
psql --single-transaction  $LINK -d $DB -f ./schema/packages/package.sql
psql --single-transaction  $LINK -d $DB -f ./schema/views/view.sql
psql --single-transaction  $LINK -d $DB -f ./schema/sequences/sequence.sql
psql --single-transaction  $LINK -d $DB -f ./schema/triggers/trigger.sql
psql --single-transaction  $LINK -d $DB -f ./schema/synonyms/synonym.sql
psql $LINK -d $DB -f ./data/data.sql
psql $LINK -d $DB -f ./schema/tables/INDEXES_table.sql
psql $LINK -d $DB -f ./schema/tables/CONSTRAINTS_table.sql
psql $LINK -d $DB -f ./schema/tables/FKEYS_table.sql
```
