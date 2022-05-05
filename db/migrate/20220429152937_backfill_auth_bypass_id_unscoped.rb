# This supplements the previous migration, BackfillAuthBypassId.
# It acts upon Edition.unscoped to bypass the default scope that Edition::Workflow introduces.
# Without unscoping the model, the migration excludes Editions in the 'deleted' state.
class BackfillAuthBypassIdUnscoped < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    to_update = Edition.unscoped.where(auth_bypass_id: nil)
    to_update.find_each do |edition|
      edition.update_column(:auth_bypass_id, SecureRandom.uuid)
    end
  end
end
