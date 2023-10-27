(
    echo create table if not exists lookup.zz_country ( \
        country_id smallint, \
        country_abbr varchar(10^^^),\
        country_name varchar(50^^^),\
        default_order smallint,\
        data_sovereignty_region_id smallint,\
        legal_jurisdiction_id smallint\
        ^^^);
) | psql -h localhost -p 5432 -U postgres -d pagila_dev -c "create table if not exists lookup.zz_country ( country_id smallint, country_abbr varchar(10), country_name varchar(50^^^), default_order smallint, data_sovereignty_region_id smallint, legal_jurisdiction_id smallint);"
 psql postgresql://$FP__flyway_user__:$FP__psql_password__@$FP__psql_host__:$FP__psql_port/$FP__flyway_database__^
 -c "create table if not exists lookup.zz_country ( country_id smallint, country_abbr varchar(10), country_name varchar(50), default_order smallint, data_sovereignty_region_id smallint, legal_jurisdiction_id smallint);"

)
psql postgresql://$FP__flyway_user__:$FP__psql_password__@$FP__psql_host__:$FP__psql_port/$FP__flyway_database__^
    -c "\copy source-table from 'source-table.csv' with DELIMITER ','" 

 UPDATE  lookup.country tb\
SET     country_abbr = fl.country_abbr,\

                                    country_name = fl.country_name,\

                                    default_order = fl.default_order,

                                    data_sovereignty_region_id = fl.data_sovereignty_region_id,

                                    legal_jurisdiction_id = fl.legal_jurisdiction_id

FROM    lookup.zz_country fl

WHERE   tb.country_id = fl.country_id

AND                          (tb.country_abbr <> fl.country_abbr OR tb.country_name <> fl.country_name OR tb.default_order <> fl.default_order OR

         tb.data_sovereignty_region_id <> fl.data_sovereignty_region_id OR tb.legal_jurisdiction_id <> fl.legal_jurisdiction_id);

 

INSERT INTO lookup.country (country_id,country_abbr,country_name,default_order,data_sovereignty_region_id, legal_jurisdiction_id)

SELECT      country_id,country_abbr,country_name,default_order, data_sovereignty_region_id, legal_jurisdiction_id

FROM        lookup.zz_country stg

WHERE NOT EXISTS (select 1

                  from     lookup.country tbl

                  where tbl.country_id = stg.country_id);

 

DELETE FROM  lookup.country tbl

WHERE NOT EXISTS (select 1

                  from lookup.zz_country stg

                  where tbl.country_id = stg.country_id);

COMMIT;
)
