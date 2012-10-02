class MainstreamCategory < ActiveRecord::Base; end
class EditionMainstreamCategory < ActiveRecord::Base; end
class Edition < ActiveRecord::Base; end
class DetailedGuide < Edition
  belongs_to :primary_mainstream_category, class_name: "MainstreamCategory"
end

class UpdateMainstreamCategories < ActiveRecord::Migration
  def up
    MainstreamCategory.delete_all
    EditionMainstreamCategory.delete_all
    new_categories.each do |parent_tag, title, parent_title|
      slug = title.parameterize
      puts "Create: #{parent_tag}/#{slug}: #{title}"
      MainstreamCategory.create!(
        title: title,
        slug: slug,
        parent_tag: parent_tag,
        parent_title: parent_title)
    end
    execute("update editions set primary_mainstream_category_id=#{MainstreamCategory.first.id} where type='DetailedGuide'")
  end

  def down
  end

  def new_categories
    [
      ["business/maritime", "Maritime and freshwater businesses", "Maritime vessels and work at sea"],
      ["business/licences", "Chemical licensing", "Licences and licence applications"],
      ["business/waste-environment", "Environmental regulations", "Waste and environmental impact"],
      ["business/farming", "Crops and horticulture", "Farming"],
      ["business/farming", "Farm management and finance", "Farming"],
      ["business/farming", "Farming and the environment", "Farming"],
      ["business/farming", "Grants and payments for farmers", "Farming"],
      ["business/farming", "Organic farming", "Farming"],
      ["business/farming", "Livestock", "Farming"],
      ["business/manufacturing", "Manufacturing regulations", "Manufacturing"],
      ["business/manufacturing", "Import and export of manufactured goods", "Manufacturing"],
      ["business/imports-exports", "Excise duty", "Imports and exports"],
      ["business/imports-exports", "Import and export controls", "Imports and exports"],
      ["business/imports-exports", "Import and export procedures", "Imports and exports"],
      ["business/imports-exports", "Embargoes and sanctions", "Imports and exports"],
      ["business/imports-exports", "Classification of goods", "Imports and exports"],
      ["business/imports-exports", "Transporting goods", "Imports and exports"],
      ["business/corporation-tax-capital-allowance", "Tax and legislation for corporations", "Corporation tax and capital allowances"],
      ["employing-people/payroll", "Tax guidance for employers", "Payroll"],
      ["tax/self-assessment", "Guidance for tax advisers and agents", "Self-assessment"]
    ]
  end
end
