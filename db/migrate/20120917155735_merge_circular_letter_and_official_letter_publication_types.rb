class MergeCircularLetterAndOfficialLetterPublicationTypes < ActiveRecord::Migration
  def up
    execute %{
      update editions
      set publication_type_id = 8
      where publication_type_id = 9
    }
  end

  def down
  end
end
