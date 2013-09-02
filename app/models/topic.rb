# == Schema Information
#
# Table name: classifications
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  description              :text
#  slug                     :string(255)
#  state                    :string(255)
#  published_edition_count  :integer          default(0), not null
#  published_policies_count :integer          default(0), not null
#  type                     :string(255)
#  carrierwave_image        :string(255)
#  logo_alt_text            :string(255)
#  start_date               :date
#  end_date                 :date
#

class Topic < Classification
end
