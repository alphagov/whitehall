class MigrateOrganisationsToNewOrganisationType < ActiveRecord::Migration
  def up
    add_column :organisations, :organisation_type_key, :string
    execute %Q{
      UPDATE organisations AS o
      INNER JOIN organisation_types AS ot ON o.organisation_type_id = ot.id
      SET o.organisation_type_key = CASE ot.name
        WHEN "Ministerial department"                 THEN "ministerial_department"
        WHEN "Non-ministerial department"             THEN "non_ministerial_department"
        WHEN "Executive agency"                       THEN "executive_agency"
        WHEN "Executive non-departmental public body" THEN "executive_ndpb"
        WHEN "Advisory non-departmental public body"  THEN "advisory_ndpb"
        WHEN "Tribunal non-departmental public body"  THEN "tribunal_ndpb"
        WHEN "Public corporation"                     THEN "public_corporation"
        WHEN "Independent monitoring body"            THEN "independent_monitoring_body"
        WHEN "Ad-hoc advisory group"                  THEN "adhoc_advisory_group"
        WHEN "Other"                                  THEN "other"
        WHEN "Sub-organisation"                       THEN "sub_organisation"
        WHEN "Executive office"                       THEN "executive_office"
        WHEN "Devolved administration"                THEN "devolved_administration"
      END
    }
  end

  def down
    # Magic ids come from 20130912150137_cleanup_organisation_type.rb.
    execute %Q{
      UPDATE organisations
      SET organisation_type_id = CASE organisation_type_key
        WHEN "ministerial_department"      THEN 1
        WHEN "non_ministerial_department"  THEN 2
        WHEN "executive_agency"            THEN 3
        WHEN "executive_ndpb"              THEN 4
        WHEN "advisory_ndpb"               THEN 5
        WHEN "tribunal_ndpb"               THEN 6
        WHEN "public_corporation"          THEN 7
        WHEN "independent_monitoring_body" THEN 8
        WHEN "adhoc_advisory_group"        THEN 9
        WHEN "other"                       THEN 10
        WHEN "sub_organisation"            THEN 11
        WHEN "executive_office"            THEN 12
      END
    }

    remove_column :organisations, :organisation_type_key
  end
end
