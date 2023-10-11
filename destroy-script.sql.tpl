DO $do$
DECLARE
  each_schema text;
  affected_database text := '${affected_database}';
BEGIN
  IF ${make_admin_own} THEN
    GRANT "${db_owner}" TO "${admin_user}";
    RAISE NOTICE 'DB owner role granted to admin user.';
  END IF;

  RAISE NOTICE '==> Revoke privileges on % database:', affected_database;
  REVOKE CONNECT ON DATABASE "${affected_database}" FROM "${group_role}";
  RAISE NOTICE 'CONNECT privileges were revoked.';

  FOR each_schema IN SELECT nspname FROM pg_namespace where nspname != 'pg_toast' 
    and nspname != 'pg_statistic' 
    and nspname != 'pg_catalog' 
    and nspname != 'information_schema'
  LOOP
    EXECUTE FORMAT('REVOKE USAGE ON SCHEMA %I FROM "${group_role}"', each_schema);
    RAISE NOTICE 'USAGE privileges were revoked on schema %.', each_schema;
    EXECUTE FORMAT('REVOKE SELECT ON ALL TABLES IN SCHEMA %s FROM "${group_role}"', each_schema);
    RAISE NOTICE 'SELECT privileges were revoked on all tables in %.', each_schema;
  END LOOP;

  IF ${make_admin_own} THEN
    REVOKE "${db_owner}" FROM "${admin_user}";
    RAISE NOTICE 'DB owner role revoked from admin user.';
  END IF;
END
$do$;
