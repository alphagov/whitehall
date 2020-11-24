class AddShowBrexitCurrentStateContentNotice < ActiveRecord::Migration[5.1]
  def change
    add_column :editions, :show_brexit_current_state_content_notice, :boolean, default: false
  end
end
