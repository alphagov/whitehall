class RevertChangeTribunalOrgType < ActiveRecord::Migration[5.1]
  def change
    Organisation
    .where(organisation_type_key: :tribunal)
    .update_all(organisation_type_key: :tribunal_ndpb)
  end
end
