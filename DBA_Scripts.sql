-- 1. Displays information about all database users

SELECT
    username,
    account_status,
    TO_CHAR(lock_date,'DD-MON-YYYY') AS lock_date,
    TO_CHAR(expiry_date,'DD-MON-YYYY') AS expiry_date,
    default_tablespace,
    temporary_tablespace,
    TO_CHAR(created,'DD-MON-YYYY') AS created,
    profile,
    initial_rsrc_consumer_group,
    editions_enabled,
    authentication_type
FROM
    dba_users
ORDER BY username;



-- 2. Displays general information about the database

SELECT
    *
FROM
    v$database;

SELECT
    *
FROM
    v$instance;

SELECT
    *
FROM
    v$version;

SELECT
    a.name,
    a.value
FROM
    v$sga a;

SELECT
    substr(
        c.name,
        1,
        60
    ) "Controlfile",
    nvl(c.status,'UNKNOWN') "Status"
FROM
    v$controlfile c
ORDER BY 1;

SELECT
    substr(
        d.name,
        1,
        60
    ) "Datafile",
    nvl(d.status,'UNKNOWN') "Status",
    d.enabled "Enabled",
    lpad(
        TO_CHAR(
            round(
                d.bytes / 1024000,
                2
            ),
            '9999990.00'
        ),
        10,
        ' '
    ) "Size (M)"
FROM
    v$datafile d
ORDER BY 1;

SELECT
    l.group# "Group",
    substr(
        l.member,
        1,
        60
    ) "Logfile",
    nvl(l.status,'UNKNOWN') "Status"
FROM
    v$logfile l
ORDER BY 1,2;



-- 3. Displays information about specified tables

SELECT
    t.table_name,
    t.tablespace_name,
    t.num_rows,
    t.avg_row_len,
    t.blocks,
    t.empty_blocks,
    round(
        t.blocks * ts.block_size / 1024 / 1024,
        2
    ) AS size_mb
FROM
    dba_tables t
    JOIN dba_tablespaces ts ON t.tablespace_name = ts.tablespace_name
WHERE
    t.owner = upper('db514')
ORDER BY t.table_name;



-- 4. Displays information about specified indexes

SELECT
    table_owner,
    table_name,
    owner AS index_owner,
    index_name,
    tablespace_name,
    num_rows,
    status,
    index_type
FROM
    dba_indexes
WHERE
        table_owner = upper('db514')
    AND
        table_name = DECODE(
            upper('customer'),
            'ALL',
            table_name,
            upper('customer')
        )
ORDER BY
    table_owner,
    table_name,
    index_owner,
    index_name;



-- 5. Displays information on all database sessions

SELECT
    nvl(s.username,'(oracle)') AS username,
    s.osuser,
    s.sid,
    s.serial#,
    p.spid,
    s.lockwait,
    s.status,
    s.service_name,
    s.module,
    s.machine,
    s.program,
    TO_CHAR(s.logon_time,'DD-MON-YYYY HH24:MI:SS') AS logon_time,
    s.last_call_et AS last_call_et_secs
FROM
    v$session s,
    v$process p
WHERE
    s.paddr = p.addr
ORDER BY
    s.username,
    s.osuser;



-- 6. Displays all database property values

SELECT
    property_name,
    property_value
FROM
    database_properties
ORDER BY property_name;



-- 7. Lists the column definitions for the specified table

SELECT
    table_name,
    column_id,
    column_name,
    data_type,
    (
        CASE
            WHEN data_type IN (
                'VARCHAR2','CHAR'
            ) THEN TO_CHAR(data_length)
            WHEN
                data_scale IS NULL
            OR
                data_scale = 0
            THEN TO_CHAR(data_precision)
            ELSE TO_CHAR(data_precision)
             || ','
             || TO_CHAR(data_scale)
        END
    ) "SIZE",
    DECODE(
        nullable,
        'Y',
        '',
        'NOT NULL'
    ) nullable
FROM
    user_tab_columns
WHERE
    table_name = DECODE(
        upper('customer'),
        'ALL',
        table_name,
        upper('customer')
    )
ORDER BY table_name,column_id;



-- 8. Displays memory allocations for the current database sessions

SELECT
    a.inst_id,
    nvl(a.username,'(oracle)') AS username,
    a.module,
    a.program,
    trunc(b.value / 1024) AS memory_kb
FROM
    gv$session a,
    gv$sesstat b,
    gv$statname c
WHERE
        a.sid = b.sid
    AND
        a.inst_id = b.inst_id
    AND
        b.statistic# = c.statistic#
    AND
        b.inst_id = c.inst_id
    AND
        c.name = 'session pga memory'
    AND
        a.program IS NOT NULL
ORDER BY b.value DESC;