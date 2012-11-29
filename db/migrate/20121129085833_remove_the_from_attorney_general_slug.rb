class RemoveTheFromAttorneyGeneralSlug < ActiveRecord::Migration
  class Organisation < ActiveRecord::Base
  end

  def up
    change_slug_from_to 'the-attorney-generals-office', 'attorney-generals-office'
  end

  def down
    change_slug_from_to 'attorney-generals-office', 'the-attorney-generals-office'
  end

  def change_slug_from_to(from, to)
    org = Organisation.where(slug: from).first
    if org
      org.slug = to
      org.save
    end
  end
end
