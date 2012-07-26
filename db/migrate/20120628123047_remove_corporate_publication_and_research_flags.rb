class RemoveCorporatePublicationAndResearchFlags < ActiveRecord::Migration
  def up
    remove_column :editions, :corporate_publication
    remove_column :editions, :research
    Edition.reset_column_information
  end

  def down
    add_column :editions, :corporate_publication, :boolean, default: false
    add_column :editions, :research, :boolean, default: false
  end
end
