class CreateGovspeakContents < ActiveRecord::Migration
  MEDIUM_TEXT = 16.megabytes - 1

  def change
    create_table :govspeak_contents do |t|
      t.references :html_attachment
      t.text :body, limit: MEDIUM_TEXT
      t.boolean :manually_numbered_headings
      t.text :computed_body_html, limit: MEDIUM_TEXT
      t.text :computed_headers_html

      t.timestamps
    end

    add_index :govspeak_contents, :html_attachment_id
  end
end
