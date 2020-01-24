class CreateBrexitNoDealContentNoticeLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :brexit_no_deal_content_notice_links do |t|
      t.string :title
      t.string :url
      t.integer :edition_id, foreign_key: true

      t.timestamps
    end
  end
end
