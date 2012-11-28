class FixAttorneyGeneralSlug < ActiveRecord::Migration
  class Organisation < ActiveRecord::Base
  end

  def up
    change_slug_from_to 'the-attorney-general-s-office', 'the-attorney-generals-office'
  end

  def down
    change_slug_from_to 'the-attorney-generals-office', 'the-attorney-general-s-office'
  end

  def change_slug_from_to(from, to)
    org = Organisation.where(slug: from).first
    if org
      org.slug = to
      org.save
    end
  end
end
