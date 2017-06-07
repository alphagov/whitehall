the_scottish_government = Organisation.find_by(slug: "the-scottish-government")
new_logo_formatted_name = "Scottish \r\nGovernment"

the_scottish_government.update_attributes(
  logo_formatted_name: new_logo_formatted_name
)
