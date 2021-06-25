class DropBrexitNoDealContentNoticeLinks < ActiveRecord::Migration[6.0]
  def up
    drop_table :brexit_no_deal_content_notice_links
    remove_column :editions, :show_brexit_no_deal_content_notice
  end
end
