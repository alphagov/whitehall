Whitehall.public_host = case Rails.env
  when 'production' then 'www.gov.uk'
  when 'development' then 'www.dev.gov.uk'
  when 'test' then 'www.example.com'
  else raise "Unexpected rails env #{Rails.env}"
end