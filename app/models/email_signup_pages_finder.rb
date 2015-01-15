class EmailSignupPagesFinder

  def self.signup_page_for_atom_url(atom_url)
    special_cases.find { |c| atom_url.match(c.regex) }
  end

private

  def self.special_cases
    [
      OpenStruct.new(
        regex: /medicines-and-healthcare-products-regulatory-agency.atom$/,
        email_signup_path: self.route_helpers.organisation_email_signup_information_path("medicines-and-healthcare-products-regulatory-agency"),
        signup_pages: [
          OpenStruct.new(
            text: "Drug alerts and medical device alerts",
            description: "Subscribe to <a href='/drug-device-alerts/email-signup'>MHRA's alerts and recalls for drugs and medical devices</a>.".html_safe,
          ),
          OpenStruct.new(
            text: "Drug Safety Update",
            description: "Subscribe to the <a href='/drug-safety-update/email-signup'>Drug Safety Update</a>, the monthly newsletter for healthcare professionals, with clinical advice on the safe use of medicines.".html_safe,
          ),
          OpenStruct.new(
            text: "News and publications from the MHRA",
            description: "Subscribe to <a href='/government/email-signup/new?email_signup%5Bfeed%5D=https%3A%2F%2Fwww.gov.uk%2Fgovernment%2Forganisations%2Fmedicines-and-healthcare-products-regulatory-agency.atom'>MHRA's new publications, statistics, consultations and announcements</a>.".html_safe,
          ),
        ]
      )
    ]
  end

  def self.route_helpers; Rails.application.routes.url_helpers; end

end
