class BackfillAuthBypassId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    to_update = Edition.where(auth_bypass_id: nil)
    to_update.find_each do |edition|
      edition.update!(auth_bypass_id: SecureRandom.uuid)
    end
  end
end
