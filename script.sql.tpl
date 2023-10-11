DO $do$
DECLARE
  each_schema text;
  affected_database text := '${affected_database}';
BEGIN
  IF EXISTS (
    SELECT FROM pg_catalog.pg_roles
    WHERE  rolname = '${group_role}') THEN
    RAISE NOTICE 'Role ${group_role} already exists. Skipping...';
  ELSE
    CREATE ROLE ${group_role} NOLOGIN;
    RAISE NOTICE 'Role ${group_role} is created.';
  END IF;

  IF ${make_admin_own} THEN
    GRANT "${db_owner}" TO "${admin_user}";
    RAISE NOTICE 'DB owner role granted to admin user.';
  END IF;

  RAISE NOTICE '==> Grant privileges on % database:', affected_database;
  GRANT CONNECT ON DATABASE "${affected_database}" TO "${group_role}";
  RAISE NOTICE 'CONNECT privileges were granted.';

  FOR each_schema IN SELECT nspname FROM pg_namespace where nspname != 'pg_toast' 
    and nspname != 'pg_statistic' 
    and nspname != 'pg_catalog' 
    and nspname != 'information_schema'
  LOOP
    EXECUTE FORMAT('GRANT USAGE ON SCHEMA %I TO "${group_role}"', each_schema);
    RAISE NOTICE 'USAGE privileges were granted on schema %.', each_schema;
    EXECUTE FORMAT('GRANT SELECT ON ALL TABLES IN SCHEMA %s TO "${group_role}"', each_schema);
    RAISE NOTICE 'SELECT privileges were granted on all tables in %.', each_schema;
  END LOOP;
  
  IF ${make_admin_own} THEN
    REVOKE "${db_owner}" FROM "${admin_user}";
    RAISE NOTICE 'DB owner role revoked from admin user.';
  END IF;
END
$do$;
