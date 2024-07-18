class RemoveNonEditionableWorldwideOrganisations < ActiveRecord::Migration[7.1]
  def up
    Asset.where(assetable_type: "WorldwideOrganisation").destroy_all
    Attachment.where(attachable_type: "WorldwideOrganisation").destroy_all
    Contact.where(contactable_type: "WorldwideOrganisation").destroy_all
    EditionDependency.where(dependable_type: "WorldwideOrganisation").destroy_all
    FeatureList.where(featurable_type: "WorldwideOrganisation").destroy_all
    FeaturedImageData.where(featured_imageable_type: "WorldwideOrganisation").destroy_all
    FeaturedLink.where(linkable_type: "WorldwideOrganisation").destroy_all
    LinkCheckerApiReport.where(link_reportable_type: "WorldwideOrganisation").destroy_all
    PolicyGroupDependency.where(dependable_type: "WorldwideOrganisation").destroy_all
    SocialMediaAccount.where(socialable_type: "WorldwideOrganisation").destroy_all

    drop_table :edition_worldwide_organisations
    drop_table :sponsorships
    drop_table :worldwide_organisation_roles
    drop_table :worldwide_organisation_translations
    drop_table :worldwide_organisation_world_locations
    drop_table :worldwide_organisations

    WorldwideOffice.where("worldwide_organisation_id IS NOT NULL").destroy_all
    remove_column :worldwide_offices, :worldwide_organisation_id
  end
end
