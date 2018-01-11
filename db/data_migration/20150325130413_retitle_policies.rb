require "csv"

csv_file = File.join(File.dirname(__FILE__), "20150325130413_retitle_policies.csv")

csv = CSV.parse(File.open(csv_file), headers: true)

gds_user = User.find_by!(name: "GDS Inside Government Team")

csv.each do |row|
  url = row["url"]
  new_title = row["New"]

  if url =~ %r|policies/([^/]+)$|
    slug = $1

    if (policy_document = Document.at_slug("Policy", slug))

      [policy_document.latest_edition, policy_document.published_edition].compact.uniq.each do |policy|
        old_title = policy.title
        puts %{Updating policy: #{old_title} -> #{new_title}}

        policy.update_attribute(:title, new_title)
        policy.editorial_remarks << EditorialRemark.new(author: gds_user, body: "Automatically updated title: #{old_title} -> #{new_title}")
      end
    else
      puts %{Could not find policy: no policy with slug "#{slug}" exists}
    end
  else
    puts %{Could not find policy: "#{url}" is not a /policies URL}
  end
end
