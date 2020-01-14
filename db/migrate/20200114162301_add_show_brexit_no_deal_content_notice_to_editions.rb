class AddShowBrexitNoDealContentNoticeToEditions < ActiveRecord::Migration[5.1]
  def change
    add_column :editions, :show_brexit_no_deal_content_notice, :boolean, default: false
  end
end
