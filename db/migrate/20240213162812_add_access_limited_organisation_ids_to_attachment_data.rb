class AddAccessLimitedOrganisationIdsToAttachmentData < ActiveRecord::Migration[7.1]
  def change
    add_column :attachment_data, :access_limited_organisation_ids, :string
  end
end
