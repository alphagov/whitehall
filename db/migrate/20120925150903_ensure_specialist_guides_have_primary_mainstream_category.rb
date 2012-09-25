class EnsureSpecialistGuidesHavePrimaryMainstreamCategory < ActiveRecord::Migration
  def up
    mainstream_category = select_one(%{SELECT id FROM mainstream_categories ORDER BY title LIMIT 1})
    unless mainstream_category.present?
      raise "This migration requires at least one mainstream category"
    end

    mainstream_category_id = mainstream_category["id"]

    update(%{
      UPDATE editions SET primary_mainstream_category_id = #{mainstream_category_id}
        WHERE primary_mainstream_category_id IS NULL
          AND type = 'SpecialistGuide'})
  end

  def down
    # It seems pointless to reverse this
  end
end
