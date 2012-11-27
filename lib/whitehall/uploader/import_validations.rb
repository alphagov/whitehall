consultation_fields = HeadingValidator.new
  .required(%w{old_url title summary body organisation})
  .multiple("policy_#", 1..4)
  .required(%w{opening_date closing_date})
  .optional(%w{respond_url respond_email respond_postal_address respond_form_title respond_form_attachment}) # are these implemented?
  .optional(%w{consultation_ISBN consultation_URN})
  .required(%w{response_date response_summary})
  .ignored("ignore_*")
  .multiple(%w{response_#_url response_#_title response_#_ISBN}, 0..50)
  .multiple(%w{attachment_#_url attachment_#_title}, 0..50)

publication_fields = HeadingValidator.new
  .required(%w{old_url title summary body organisation})
  .multiple("policy_#", 1..4)
  .required(%w{publication_type document_series publication_date})
  .required(%w{order_url price isbn urn command_paper_number}) # First attachment
  .ignored("ignore_*")
  .multiple(%w{attachment_#_url attachment_#_title}, 0..50)

news_article_fields = HeadingValidator.new
  .required(%w{old_url title summary body organisation})
  .ignored("ignore_*")
  .required('first_published')
  .multiple("policy_#", 1..4)
  .multiple("minister_#", 1..2)

speech_fields = HeadingValidator.new
  .required(%w{old_url title summary body organisation})
  .ignored("ignore_*")
  .required("type")
  .multiple("policy_#", 1..4)
  .required(%w{delivered_by delivered_on event_and_location})

statistical_data_set_fields = HeadingValidator.new
  .required(%w{old_url title summary body organisation})
  .required(%w{data_series})
  .multiple(%w{attachment_#_url attachment_#_title attachment_#_URN attachment_#_published_date}, 1..100)
