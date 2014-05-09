class AddGovUkClosedStatusToOrganisation < ActiveRecord::Migration
  def up
    add_column :organisations, :govuk_closed_status, :string
  end

  def down
    remove_column :organisations, :govuk_closed_status
  end
end
