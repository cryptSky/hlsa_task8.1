### Setup

1. Install docker
2. `docker-compose up --build` 
3. `docker exec -it db0 /bin/bash`
4. `mysql -u dbuser -p` - password "dbpassword"
5. `use db;`


## The flow

#### Check current transaction level

```console
mysql> select @@transaction_isolation;
+-------------------------+
| @@transaction_isolation |
+-------------------------+
| REPEATABLE-READ         |
+-------------------------+
1 row in set (0.00 sec)
```

### Read uncommitted isolation level in MySQL

#### Set transaction level to read uncommited
 ```console
mysql> set session transaction isolation level read uncommitted;
Query OK, 0 rows affected (0.00 sec)

mysql> select @@transaction_isolation;
+-------------------------+
| @@transaction_isolation |
+-------------------------+
| READ-UNCOMMITTED        |
+-------------------------+
1 row in set (0.00 sec)
```

#### Now open a new mysql session and set transaction level to "read uncommitted" as above

#### Create two transactions in each session

```console
-- Tx1:
mysql> start transaction;
Query OK, 0 rows affected (0.00 sec)

-- Tx2:
mysql> begin;
Query OK, 0 rows affected (0.01 sec)
```

```console
-- Tx1:
mysql> select * from user;
+----+-------------------+----------------------------+------------+---------+
| id | name              | email                      | birthdate  | balance |
+----+-------------------+----------------------------+------------+---------+
|  1 | SuzanneWhitaker   | maytammy@example.org       | 1972-10-22 |     100 |
|  2 | ShellyKing        | bruce77@example.org        | 2000-08-06 |     100 |
|  3 | EileenRivera      | snyderjulia@example.org    | 1997-04-19 |     100 |
|  4 | LaurenReed        | bradyfernandez@example.net | 1993-08-30 |     100 |
```

```console
-- Tx2:
mysql> select * from user  where id = 1;
+----+-----------------+----------------------+------------+---------+
| id | name            | email                | birthdate  | balance |
+----+-----------------+----------------------+------------+---------+
|  1 | SuzanneWhitaker | maytammy@example.org | 1972-10-22 |     100 |
+----+-----------------+----------------------+------------+---------+
1 row in set (0.00 sec)
```

#### Now let's update balance in first transaction and select from both

```console
-- Tx1:
mysql> update user set balance = balance - 10 where id = 1;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from user  where id = 1;
+----+-----------------+----------------------+------------+---------+
| id | name            | email                | birthdate  | balance |
+----+-----------------+----------------------+------------+---------+
|  1 | SuzanneWhitaker | maytammy@example.org | 1972-10-22 |      90 |
+----+-----------------+----------------------+------------+---------+
1 row in set (0.00 sec)

-- Tx2:
mysql> select * from user  where id = 1;
+----+-----------------+----------------------+------------+---------+
| id | name            | email                | birthdate  | balance |
+----+-----------------+----------------------+------------+---------+
|  1 | SuzanneWhitaker | maytammy@example.org | 1972-10-22 |      90 |
+----+-----------------+----------------------+------------+---------+
1 row in set (0.00 sec)
```

#### Value changed for both sessions, let;s commit and try different isolation level

```console

-- Tx1:
mysql> commit;
Query OK, 0 rows affected (0.00 sec)

-- Tx2:
mysql> commit;
Query OK, 0 rows affected (0.00 sec)

```

### Read committed isolation level in MySQL

```console

-- Tx1 + Tx2
mysql> set session transaction isolation level read committed;
Query OK, 0 rows affected (0.00 sec)

mysql> select @@transaction_isolation;
+-------------------------+
| @@transaction_isolation |
+-------------------------+
| READ-COMMITTED          |
+-------------------------+
1 row in set (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

```

#### Let's start transactions in both sessions by using `begin;` and select

```console
-- Tx1:
mysql> select * from user;
+----+-------------------+----------------------------+------------+---------+
| id | name              | email                      | birthdate  | balance |
+----+-------------------+----------------------------+------------+---------+
|  1 | SuzanneWhitaker   | maytammy@example.org       | 1972-10-22 |      90 |
|  2 | ShellyKing        | bruce77@example.org        | 2000-08-06 |     100 |
|  3 | EileenRivera      | snyderjulia@example.org    | 1997-04-19 |     100 |
|  4 | LaurenReed        | bradyfernandez@example.net | 1993-08-30 |     100 |

-- Tx2:
mysql> select * from user  where id = 1;
+----+-----------------+----------------------+------------+---------+
| id | name            | email                | birthdate  | balance |
+----+-----------------+----------------------+------------+---------+
|  1 | SuzanneWhitaker | maytammy@example.org | 1972-10-22 |      90 |
+----+-----------------+----------------------+------------+---------+
1 row in set (0.00 sec)
```

#### Let's update balance in first transaction and check second

```console
-- Tx1
mysql> update user set balance = balance - 10 where id = 1;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from user  where id = 1;
+----+-----------------+----------------------+------------+---------+
| id | name            | email                | birthdate  | balance |
+----+-----------------+----------------------+------------+---------+
|  1 | SuzanneWhitaker | maytammy@example.org | 1972-10-22 |      80 |
+----+-----------------+----------------------+------------+---------+
1 row in set (0.00 sec)

-- Tx2:
mysql> select * from user  where id = 1;
+----+-----------------+----------------------+------------+---------+
| id | name            | email                | birthdate  | balance |
+----+-----------------+----------------------+------------+---------+
|  1 | SuzanneWhitaker | maytammy@example.org | 1972-10-22 |      90 |
+----+-----------------+----------------------+------------+---------+
1 row in set (0.00 sec)
```

#### This is because we’re using `read-committed` isolation level, and since transaction 1 hasn’t been committed yet, its written data could not be seen by other transactions. It prevents `dirty read` phenomenon. Let's check `non-repeatable` and `phantom read`.

```console
-- Tx2:
mysql> select * from user where balance >= 90;
+----+-------------------+----------------------------+------------+---------+
| id | name              | email                      | birthdate  | balance |
+----+-------------------+----------------------------+------------+---------+
|  1 | SuzanneWhitaker   | maytammy@example.org       | 1972-10-22 |      90 |
|  2 | ShellyKing        | bruce77@example.org        | 2000-08-06 |     100 |
|  3 | EileenRivera      | snyderjulia@example.org    | 1997-04-19 |     100 |

-- Tx1:
mysql> commit;
Query OK, 0 rows affected (0.00 sec)

-- Tx2:
mysql> select * from user  where id = 1;
+----+-----------------+----------------------+------------+---------+
| id | name            | email                | birthdate  | balance |
+----+-----------------+----------------------+------------+---------+
|  1 | SuzanneWhitaker | maytammy@example.org | 1972-10-22 |      80 |
+----+-----------------+----------------------+------------+---------+
1 row in set (0.00 sec)

-- Tx2:
mysql> select * from user where balance >= 90;
+----+-------------------+----------------------------+------------+---------+
| id | name              | email                      | birthdate  | balance |
+----+-------------------+----------------------------+------------+---------+
|  2 | ShellyKing        | bruce77@example.org        | 2000-08-06 |     100 |
|  3 | EileenRivera      | snyderjulia@example.org    | 1997-04-19 |     100 |
|  4 | LaurenReed        | bradyfernandez@example.net | 1993-08-30 |     100 |
```

#### So the same query that get user 1 returns different value. This is `non-repeatable read` phenomenon.
#### The same query was executed, but a different set of rows is returned. One row has disappeared due to other committed transaction. This is called `phantom-read` phenomenon

#### `lost update` anomaly is not possible in MySQL as it locks query when column is updated by another transaction

```console
--Tx1:
mysql> select * from user  where id = 1;
+----+-----------------+----------------------+------------+---------+
| id | name            | email                | birthdate  | balance |
+----+-----------------+----------------------+------------+---------+
|  1 | SuzanneWhitaker | maytammy@example.org | 1972-10-22 |      80 |
+----+-----------------+----------------------+------------+---------+
1 row in set (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> update user set balance=balance+1000 where id=1; 
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

```console
-- Tx2:
mysql> select * from user  where id = 1;
+----+-----------------+----------------------+------------+---------+
| id | name            | email                | birthdate  | balance |
+----+-----------------+----------------------+------------+---------+
|  1 | SuzanneWhitaker | maytammy@example.org | 1972-10-22 |      80 |
+----+-----------------+----------------------+------------+---------+
1 row in set (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> update user set balance=balance+10000 where id=1;
ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
```