class AddAlternativeFormatProviderToEdition < ActiveRecord::Migration
  def change
    add_column :editions, :alternative_format_provider_id, :integer
  end
end
