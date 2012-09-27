class AddScheduledPublicationToEdition < ActiveRecord::Migration
  def change
    add_column :editions, :scheduled_publication, :datetime
  end
end
