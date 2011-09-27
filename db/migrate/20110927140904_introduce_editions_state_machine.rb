class IntroduceEditionsStateMachine < ActiveRecord::Migration
  def change
    remove_column :editions, :published
    add_column :editions, :state, :string, default: "draft", null: false
  end
end
