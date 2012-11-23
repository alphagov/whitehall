class DropBackupTables < ActiveRecord::Migration
  def up
    # These tables were introduced as a way of backing up some data
    # due to some bad migrations - we don't need them any more as the
    # tables have been repaired.
    execute "DROP TABLE IF EXISTS attachments_old"
    execute "DROP TABLE IF EXISTS consultation_response_attachments_old"
    execute "DROP TABLE IF EXISTS corporate_information_page_attachments_old"
    execute "DROP TABLE IF EXISTS edition_attachments_old"
    execute "DROP TABLE IF EXISTS edition_organisations_before_speech_migration"
    execute "DROP TABLE IF EXISTS supporting_page_attachments_old"
  end

  def down
    # No down migration as we're just dropping tables
  end
end
