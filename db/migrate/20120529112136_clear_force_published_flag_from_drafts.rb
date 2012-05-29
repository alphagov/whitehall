class ClearForcePublishedFlagFromDrafts < ActiveRecord::Migration
  def up
    execute %q{
    update editions set force_published=null where state in ('draft', 'submitted', 'rejected')
    }
  end

  def down
  end
end
