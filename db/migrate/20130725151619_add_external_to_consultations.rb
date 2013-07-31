class AddExternalToConsultations < ActiveRecord::Migration
  def change
    add_column :editions, :external, :boolean, default: false
    add_column :editions, :external_url, :string
  end
end
