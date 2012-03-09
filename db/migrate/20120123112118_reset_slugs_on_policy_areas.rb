# require "policy_area"

class ResetSlugsOnPolicyAreas < ActiveRecord::Migration
  # class ::PolicyArea
  #   def should_generate_new_friendly_id?
  #     true
  #   end
  # end

  def up
    # PolicyArea.all.each { |pa| pa.save }
  end

  def down
    # irreversible
  end
end
