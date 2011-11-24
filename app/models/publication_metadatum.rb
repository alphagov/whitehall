class PublicationMetadatum < ActiveRecord::Base
  belongs_to :publication

  validates :publication_date, presence: true
  validates :isbn, isbn_format: true, allow_blank: true
  validates :order_url, format: URI::regexp(%w(http https)), allow_blank: true
end