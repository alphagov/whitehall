class ExtractConsultationParticipationsIntoSeparateModel < ActiveRecord::Migration
  def up
    create_table :consultation_participations, force: true do |t|
      t.references :edition
      t.string :link_url
      t.string :link_text
      t.timestamps
    end
    insert %{
      INSERT INTO consultation_participations (edition_id, link_url, link_text, created_at, updated_at)
        SELECT id, consultation_participation_link_url, consultation_participation_link_text, created_at, updated_at 
          FROM editions
          WHERE consultation_participation_link_url IS NOT NULL OR consultation_participation_link_text IS NOT NULL
    }
    remove_column :editions, :consultation_participation_link_url
    remove_column :editions, :consultation_participation_link_text
  end

  def down
    add_column :editions, :consultation_participation_link_url, :string
    add_column :editions, :consultation_participation_link_text, :string
    update %{
      UPDATE editions, consultation_participations
        SET editions.consultation_participation_link_url = consultation_participations.link_url,
            editions.consultation_participation_link_text = consultation_participations.link_text,
            editions.updated_at = GREATEST(editions.updated_at, consultation_participations.updated_at)
        WHERE editions.id = consultation_participations.edition_id
    }
    drop_table :consultation_participations
  end
end
