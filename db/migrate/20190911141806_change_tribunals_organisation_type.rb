class ChangeTribunalsOrganisationType < ActiveRecord::Migration[5.1]
  def change
    Organisation
      .where(organisation_type_key: :tribunal_ndpb)
      .update_all(organisation_type_key: :tribunal)
  end
end