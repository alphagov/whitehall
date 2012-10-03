require 'csv'

class CorrectDetailedGuideCategorisation < ActiveRecord::Migration
  class Edition < ActiveRecord::Base; end
  class MainstreamCategory < ActiveRecord::Base; end
  class EditionMainstreamCategory < ActiveRecord::Base; end

  def up
    data.each do |row|
      guide = Edition.find_by_id(row['Edition ID'])
      next unless guide

      category_fields = [
        'Primary detailed guidance category',
        'Detailed guidance category 1',
        'Detailed guidance category 2'
      ]
      primary, *additional = category_fields.map do |field_name|
        MainstreamCategory.find_by_title(row[field_name])
      end
      puts "#{guide.id}: #{guide.title} <= primary: '#{primary && primary.title}', additional: [#{additional.compact.map(&:title).join(', ')}]"
      guide.update_column(:primary_mainstream_category_id, primary.id) if primary
      EditionMainstreamCategory.where(edition_id: guide.id).delete_all
      additional.compact.each do |additional_category|
        EditionMainstreamCategory.create(edition_id: guide.id, mainstream_category_id: additional_category.id)
      end
    end
  end

  def down
  end

  def data
    CSV.read(
      File.dirname(__FILE__) + '/20121002163629_correct_detailed_guide_categorisation.csv',
      headers: true)
  end
end
