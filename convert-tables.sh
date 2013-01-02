#!/bin/bash

DB=$1
DBUSER=$2
DBPASS=$3

if [ "$#" != "3" ]; then
    echo "Usage: `basename $0` db_name db_user db_password"
    exit $E_BADARGS
fi

latin_tables=(
    attachment_data
    attachment_sources
    classification_featuring_image_data
    classification_featurings
    consultation_participations
    consultation_response_attachments
    consultation_response_forms
    corporate_information_page_attachments
    corporate_information_pages
    data_migration_records
    delayed_jobs
    document_series
    document_sources
    edition_authors
    edition_mainstream_categories
    edition_organisation_image_data
    edition_role_appointments
    edition_statistical_data_sets
    fatality_notice_casualties
    group_memberships
    groups
    import_errors
    imports
    mainstream_categories
    operational_fields
    organisation_mainstream_links
    organisational_relationships
    responses
)

for table in "${latin_tables[@]}"; do
    mysqldump -u$DBUSER -p$DBPASS --opt -e --skip-set-charset --default-character-set=latin1 --skip-extended-insert $DB --tables $table | sed 's/DEFAULT_CHARSET=latin1/DEFAULT_CHARSET=utf8/' > "/tmp/${DB}.${table}.latin1.sql"
    cat "/tmp/${DB}.${table}.latin1.sql" | mysql -u$DBUSER -p$DBPASS $DB
    mysqldump -u$DBUSER -p$DBPASS --opt -e --skip-set-charset --default-character-set=utf8 --skip-extended-insert $DB --tables $table > "/tmp/${DB}.${table}.utf8.sql"
done
