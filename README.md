# clickhouse-table [![Build Status](https://travis-ci.org/maiha/clickhouse-table.svg?branch=master)](https://travis-ci.org/maiha/clickhouse-table)

A standalone ClickHouse table manager that provides partial data updates.

```console
$ clickhouse-table create
$ clickhouse-table insert  20180924 diff.csv
$ clickhouse-table replace 20180924 full.csv
```

#### Features
- create table schema
- insert table data
- replace table data

#### Assumes
- client: `clickhouse-client`
- engine: `MergeTree`
- table: `Merge`
- range of update: daily

## Architecture

#### tables
```
logs          # Merge('^logs_')
logs_20180922 # MergeTree
logs_20180923 # MergeTree
logs_20180924 # MergeTree
```
- table name `logs` is set by `config:table`

#### replace
```sql
DROP   TABLE logs_20180924
CREATE TABLE logs_20180924
INSERT INTO  logs_20180924 FORMAT CSV
```

## Installation

#### Static Binary is ready for x86_64 linux

- https://github.com/maiha/clickhouse-table/releases

## Usage

#### configure

First, create a new config file. 
Then, set schema settings about `table`, `column`, `engine`.

```console
$ clickhouse-table config sample > .clickhouse-table.toml
$ vi .clickhouse-table.toml
```

#### insert data

Invoke `insert` command for daily operation. 
This accumulates the data each operations.

```console
$ clickhouse-table insert 20180924 data.csv
```

#### replace data

Invoke `replace` command for correction batch.
This replaces the data for the day.

```console
$ clickhouse-table replace 20180924 data.csv
```

## Development

```console
$ make test
```

## Contributing

1. Fork it (<https://github.com/maiha/clickhouse-table/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
