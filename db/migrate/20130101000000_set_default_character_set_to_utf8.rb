class SetDefaultCharacterSetToUtf8 < ActiveRecord::Migration
  def up
    execute "ALTER DATABASE DEFAULT CHARACTER SET utf8"
    execute "ALTER DATABASE DEFAULT COLLATE utf8_unicode_ci"
  end
end
