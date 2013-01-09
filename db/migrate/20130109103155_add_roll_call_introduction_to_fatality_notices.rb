class AddRollCallIntroductionToFatalityNotices < ActiveRecord::Migration
  def change
    add_column :editions, :roll_call_introduction, :text
  end
end
