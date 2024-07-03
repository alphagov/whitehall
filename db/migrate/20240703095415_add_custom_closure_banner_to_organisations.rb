class AddCustomClosureBannerToOrganisations < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :custom_contextual_banner, :string, null: true, default: nil
  end
end
