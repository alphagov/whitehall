[
  ['Alcohol licensing', 'How to apply for a licence to sell alcohol, with details of fees and the role of the licensing authority.', 'business/licences', 'Licences and licence applications'],
  ['Powers of entry', 'Covering powers of entry, drug-testing, firearms licensing, arrest and detention, technology and equipment, extradition and police pay and pensions.', 'justice/rights', 'Your rights and the law'],
  ['Criminal record disclosure', 'Guidance on criminal record checks from the Disclosure and Barring Service (DBS) for recruitment and protection.', 'employing-people/recruiting-hiring', 'Recruiting and hiring'],
  ['Animal reseach and testing', 'How to apply for licences for research involving animals, and information on the bodies that regulate animal testing.', 'business/science', 'Scientific research and development'],
  ['Dealing with domestic violence', 'Guidance on preventing and responding to domestic violence and homicides, including information on protection notices and orders.', 'justice/reporting-crimes-compensation', 'Reporting crimes and getting compensation'],
  ['Death registration disclosure', 'Preventing fraud and other offences through disclosure of death registration information (DDRI).', 'births-deaths-marriages/death', 'Death and bereavement'],
].each do |row|
  title, description, parent_tag, parent_title = row
  unless category = MainstreamCategory.where(title: title).first
    category = MainstreamCategory.create(
      title: title,
      slug:  title.parameterize,
      parent_tag: parent_tag,
      parent_title: parent_title,
      description: description
      )
    if category
      puts "Mainstream category '#{category.title}' created"
    end
  else
    puts "Mainstream category '#{category.title}' already exists, skipping"
  end
end
