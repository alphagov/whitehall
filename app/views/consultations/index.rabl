collection @consultations

attributes :title, :slug, :opening_on, :closing_on
attributes :open? => :open
node(:url) { |c| consultation_url(c.slug) }
node(:api_url) { |c| consultation_url(c.slug, format: request.format.to_sym) }
