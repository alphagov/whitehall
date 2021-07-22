module PastForeignSecretariesHelper
  def past_foreign_secretary_nav
    people = {
      "edward-wood" => "Edward Frederick Lindley Wood",
      "austen-chamberlain" => "Sir Austen Chamberlain",
      "george-curzon" => "George Nathaniel Curzon",
      "edward-grey" => "Sir Edward Grey",
      "henry-petty-fitzmaurice" => "Henry Petty-Fitzmaurice",
      "robert-cecil" => "Robert Cecil",
      "george-gower" => "George Leveson Gower",
      "george-gordon" => "George Hamilton Gordon",
      "charles-fox" => "Charles James Fox",
      "william-grenville" => "William Wyndham Grenville",
    }
    
    {
      "links" => {
        "ordered_related_items" => people.map do |slug, name|
          {
            "title" => name,
            "base_path" => "/government/history/past-foreign-secretaries/#{slug}",
          }
        end
      }
    }
  end

  def service_date(service)
    if service.is_a?(Array)
      service.map { |date| { text: date } }
    else
      [{
        text: service,
      }]
    end
  end
end
