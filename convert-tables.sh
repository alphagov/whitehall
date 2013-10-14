#!/bin/bash

if [ "$#" != "4" ]; then
    echo "Usage: `basename $0` db_name db_user db_password db_host"
    exit 1
fi

DB=$1
DBUSER=$2
DBPASS=$3
DBHOST=$4

latin_tables=(
    attachment_data
    attachment_sources
    classification_featuring_image_data
    classification_featurings
    consultation_participations
    consultation_response_attachments
    consultation_response_forms
    consultation_response_form_data
    corporate_information_page_attachments
    corporate_information_pages
    data_migration_records
    delayed_jobs
    document_collections
    document_sources
    edition_authors
    edition_document_series
    edition_mainstream_categories
    edition_organisation_image_data
    edition_policy_groups
    edition_role_appointments
    edition_statistical_data_sets
    edition_world_location_image_data
    fatality_notice_casualties
    force_publication_attempts
    group_memberships
    groups
    import_errors
    imports
    import_logs
    mainstream_categories
    operational_fields
    organisation_mainstream_links
    organisational_relationships
    policy_group_attachments
    responses
    sponsorships
    worldwide_office_world_locations
    worldwide_offices
)


for table in "${latin_tables[@]}"; do
    LATIN1FILE="/tmp/${DB}.${table}.latin1.sql"
    mysqldump -h$DBHOST -u$DBUSER -p$DBPASS --opt -e --skip-set-charset --default-character-set=latin1 --skip-extended-insert $DB --tables $table | sed 's/DEFAULT CHARSET=latin1/DEFAULT CHARSET=utf8/' > $LATIN1FILE
done

for table in "${latin_tables[@]}"; do
    LATIN1FILE="/tmp/${DB}.${table}.latin1.sql"
    mysql -h$DBHOST -u$DBUSER -p$DBPASS $DB < $LATIN1FILE
    rm $LATIN1FILE
done
