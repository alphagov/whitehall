require "csv"

namespace :temp_worldwide_organisation_history do
  desc "Output all worldwide organisation corporate information page history as a CSV"
  task history: [:environment] do
    history = WorldwideOrganisation.find_each.each.map(&:corporate_information_pages).flatten.map { |cip|
      cip.versions.map do |version|
        {
          public_path: cip.public_path,
          timestamp: version.created_at,
          actor: version.whodunnit ? User.find(version.whodunnit).email : "",
          event: version.event,
          state: version.state,
        }
      end
    }.flatten

    CSV.open("ww-org-cip-history.csv", "w") do |csv|
      csv << history.first.keys
      history.each do |item|
        csv << item.values
      end
    end
  end

  desc "Output all worldwide organisation corporate information page editorial remarks as a CSV"
  task editorial_remarks: [:environment] do
    history = WorldwideOrganisation.find_each.map(&:corporate_information_pages).flatten.map { |cip|
      cip.editorial_remarks.map do |remark|
        {
          public_path: cip.public_path,
          timestamp: remark.created_at,
          actor: remark.author_id ? User.find(remark.author_id).email : "",
          remark: remark.body,
        }
      end
    }.flatten

    CSV.open("ww-org-cip-editorial-remarks.csv", "w") do |csv|
      csv << history.first.keys
      history.each do |item|
        csv << item.values
      end
    end
  end
end
