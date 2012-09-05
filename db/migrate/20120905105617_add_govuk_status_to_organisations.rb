class AddGovukStatusToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :govuk_status, :string, null: false, default: 'live'
  end
end
