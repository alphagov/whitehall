module PastForeignSecretariesHelper
  def past_foreign_secretary_nav(current_person)
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
    people
      .map { |slug, name|
        tag.li(class: "govuk-!-margin-0 govuk-body-s govuk-!-padding-top-2 govuk-!-padding-bottom-2") do
          link_to_if(slug != current_person, name.html_safe, past_foreign_secretary_path(id: slug), class: "govuk-link  ")
        end
      }
      .join("")
      .html_safe
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
