class RenameWorldwideOfficesToWorldwideOrganisations < ActiveRecord::Migration
  def up
    rename_index :worldwide_offices, 'index_worldwide_offices_on_slug', 'index_worldwide_organisations_on_slug'
    rename_table :worldwide_offices, :worldwide_organisations

    rename_index :worldwide_office_world_locations, 'index_worldwide_office_world_locations_on_world_location_id', 'index_worldwide_org_world_locations_on_world_location_id'
    rename_index :worldwide_office_world_locations, 'index_worldwide_office_world_locations_on_worldwide_office_id', 'index_worldwide_org_world_locations_on_worldwide_organisation_id'
    rename_column :worldwide_office_world_locations, 'worldwide_office_id', 'worldwide_organisation_id'
    rename_table :worldwide_office_world_locations, :worldwide_organisation_world_locations

    rename_index :worldwide_office_translations, 'index_worldwide_office_translations_on_locale', 'index_worldwide_org_translations_on_locale'
    rename_index :worldwide_office_translations, 'index_worldwide_office_translations_on_worldwide_office_id', 'index_worldwide_org_translations_on_worldwide_organisation_id'
    rename_column :worldwide_office_translations, 'worldwide_office_id', 'worldwide_organisation_id'
    rename_table :worldwide_office_translations, :worldwide_organisation_translations

    rename_index :worldwide_office_roles, 'index_worldwide_office_roles_on_role_id', 'index_worldwide_org_roles_on_role_id'
    rename_index :worldwide_office_roles, 'index_worldwide_office_roles_on_worldwide_office_id', 'index_worldwide_org_roles_on_worldwide_organisation_id'
    rename_column :worldwide_office_roles, 'worldwide_office_id', 'worldwide_organisation_id'
    rename_table :worldwide_office_roles, :worldwide_organisation_roles

    rename_index :edition_worldwide_offices, 'index_edition_worldwide_offices_on_edition_id', 'index_edition_worldwide_orgs_on_edition_id'
    rename_index :edition_worldwide_offices, 'index_edition_worldwide_offices_on_worldwide_office_id', 'index_edition_worldwide_orgs_on_worldwide_organisation_id'
    rename_column :edition_worldwide_offices, 'worldwide_office_id', 'worldwide_organisation_id'
    rename_table :edition_worldwide_offices, :edition_worldwide_organisations

    rename_index :sponsorships, 'index_sponsorships_on_worldwide_office_id', 'index_sponsorships_on_worldwide_organisation_id'
    rename_column :sponsorships, 'worldwide_office_id', 'worldwide_organisation_id'

    execute("UPDATE contacts SET contactable_type = 'WorldWideOrganisation' WHERE contactable_type = 'WorldwideOffice'")
  end

  def down
    execute("UPDATE contacts SET contactable_type = 'WorldWideOffice' WHERE contactable_type = 'WorldwideOrganisation'")

    rename_column :sponsorships, 'worldwide_organisation_id', 'worldwide_office_id'
    rename_index :sponsorships, 'index_sponsorships_on_worldwide_organisation_id', 'index_sponsorships_on_worldwide_office_id'

    rename_table :edition_worldwide_organisations, :edition_worldwide_offices
    rename_column :edition_worldwide_offices, 'worldwide_organisation_id', 'worldwide_office_id'
    rename_index :edition_worldwide_offices, 'index_edition_worldwide_orgs_on_worldwide_organisation_id', 'index_edition_worldwide_offices_on_worldwide_office_id'
    rename_index :edition_worldwide_offices, 'index_edition_worldwide_orgs_on_edition_id', 'index_edition_worldwide_offices_on_edition_id'

    rename_table :worldwide_organisation_roles, :worldwide_office_roles
    rename_column :worldwide_office_roles, 'worldwide_organisation_id', 'worldwide_office_id'
    rename_index :worldwide_office_roles, 'index_worldwide_org_roles_on_worldwide_organisation_id', 'index_worldwide_office_roles_on_worldwide_office_id'
    rename_index :worldwide_office_roles, 'index_worldwide_org_roles_on_role_id', 'index_worldwide_office_roles_on_role_id'

    rename_table :worldwide_organisation_translations, :worldwide_office_translations
    rename_column :worldwide_office_translations, 'worldwide_organisation_id', 'worldwide_office_id'
    rename_index :worldwide_office_translations, 'index_worldwide_org_translations_on_worldwide_organisation_id', 'index_worldwide_office_translations_on_worldwide_office_id'
    rename_index :worldwide_office_translations, 'index_worldwide_org_translations_on_locale', 'index_worldwide_office_translations_on_locale'

    rename_table :worldwide_organisation_world_locations, :worldwide_office_world_locations
    rename_column :worldwide_office_world_locations, 'worldwide_organisation_id', 'worldwide_office_id'
    rename_index :worldwide_office_world_locations, 'index_worldwide_org_world_locations_on_worldwide_organisation_id', 'index_worldwide_office_world_locations_on_worldwide_office_id'
    rename_index :worldwide_office_world_locations, 'index_worldwide_org_world_locations_on_world_location_id', 'index_worldwide_office_world_locations_on_world_location_id'

    rename_table :worldwide_organisations, :worldwide_offices
    rename_index :worldwide_offices, 'index_worldwide_organisations_on_slug', 'index_worldwide_offices_on_slug'
  end
end
