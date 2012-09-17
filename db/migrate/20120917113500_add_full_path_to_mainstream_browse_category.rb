class AddFullPathToMainstreamBrowseCategory < ActiveRecord::Migration
  def up
    execute("update mainstream_categories set parent_title='Business > International trade' where parent_title='International trade'")
    execute("update mainstream_categories set parent_title='??? > Food and farming' where parent_title='Food and farming'")
  end
end
