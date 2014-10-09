class EmailSignupPagesFinder
  def self.find(organisation)
    case organisation.slug
    when "medicines-and-healthcare-products-regulatory-agency"
      mhra_email_signup_pages
    end
  end

  def self.mhra_email_signup_pages
    [
      OpenStruct.new(
        text: "Safety alerts",
        url: "/drug-device-alerts/email-signup",
        description: "Drug alerts and medical device alerts published by the MHRA.",
      ),
      OpenStruct.new(
        text: "Drug safety updates",
        url: "/drug-safety-update/email-signup",
        description: "The drug safety update is a monthly newsletter for healthcare professionals, bringing you information and clinical advice on the safe use of medicines.",
      ),
      OpenStruct.new(
        text: "News and publications from the MHRA",
        url:  "/government/email-signup/new?email_signup%5Bfeed%5D=https%3A%2F%2Fwww.gov.uk%2Fgovernment%2Forganisations%2Fmedicines-and-healthcare-products-regulatory-agency.atom",
        description: "Information published by the MHRA about policies, announcements, publications, statistics and consultations.",
      ),
    ]
  end
end
