class RenameEditionableWorldwideOrganisationPolymorphicRelationships < ActiveRecord::Migration[7.1]
  def up
    Asset.where(assetable_type: "EditionableWorldwideOrganisation").update_all(assetable_type: "WorldwideOrganisation")
    Attachment.where(attachable_type: "EditionableWorldwideOrganisation").update_all(attachable_type: "WorldwideOrganisation")
    Contact.where(contactable_type: "EditionableWorldwideOrganisation").update_all(contactable_type: "WorldwideOrganisation")
    Document.where(document_type: "EditionableWorldwideOrganisation").update_all(document_type: "WorldwideOrganisation")
    Edition.where(type: "EditionableWorldwideOrganisation").update_all(type: "WorldwideOrganisation")
    EditionDependency.where(dependable_type: "EditionableWorldwideOrganisation").update_all(dependable_type: "WorldwideOrganisation")
    FeaturedImageData.where(featured_imageable_type: "EditionableWorldwideOrganisation").update_all(featured_imageable_type: "WorldwideOrganisation")
    FeaturedLink.where(linkable_type: "EditionableWorldwideOrganisation").update_all(linkable_type: "WorldwideOrganisation")
    FeatureList.where(featurable_type: "EditionableWorldwideOrganisation").update_all(featurable_type: "WorldwideOrganisation")
    LinkCheckerApiReport.where(link_reportable_type: "EditionableWorldwideOrganisation").update_all(link_reportable_type: "WorldwideOrganisation")
    PolicyGroupDependency.where(dependable_type: "EditionableWorldwideOrganisation").update_all(dependable_type: "WorldwideOrganisation")
    SocialMediaAccount.where(socialable_type: "EditionableWorldwideOrganisation").update_all(socialable_type: "WorldwideOrganisation")
  end

  def down
    Asset.where(assetable_type: "WorldwideOrganisation").update_all(assetable_type: "EditionableWorldwideOrganisation")
    Attachment.where(attachable_type: "WorldwideOrganisation").update_all(attachable_type: "EditionableWorldwideOrganisation")
    Contact.where(contactable_type: "WorldwideOrganisation").update_all(contactable_type: "EditionableWorldwideOrganisation")
    Document.where(document_type: "WorldwideOrganisation").update_all(document_type: "EditionableWorldwideOrganisation")
    Edition.where(type: "WorldwideOrganisation").update_all(type: "EditionableWorldwideOrganisation")
    EditionDependency.where(dependable_type: "WorldwideOrganisation").update_all(dependable_type: "EditionableWorldwideOrganisation")
    FeaturedImageData.where(featured_imageable_type: "WorldwideOrganisation").update_all(featured_imageable_type: "EditionableWorldwideOrganisation")
    FeaturedLink.where(linkable_type: "WorldwideOrganisation").update_all(linkable_type: "EditionableWorldwideOrganisation")
    FeatureList.where(featurable_type: "WorldwideOrganisation").update_all(featurable_type: "EditionableWorldwideOrganisation")
    LinkCheckerApiReport.where(link_reportable_type: "WorldwideOrganisation").update_all(link_reportable_type: "EditionableWorldwideOrganisation")
    PolicyGroupDependency.where(dependable_type: "WorldwideOrganisation").update_all(dependable_type: "EditionableWorldwideOrganisation")
    SocialMediaAccount.where(socialable_type: "WorldwideOrganisation").update_all(socialable_type: "EditionableWorldwideOrganisation")
  end
end
