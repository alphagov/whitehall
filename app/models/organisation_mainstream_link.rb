class OrganisationMainstreamLink < ActiveRecord::Base
  belongs_to :organisation
  validates :slug, :title, presence: true

  def public_url(host)
    slug_with_leading_slash
    if slug =~ /^http/
      slug
    else
      "http://" + Whitehall.public_host_for(host) + slug_with_leading_slash
    end
  end

  private

  def slug_with_leading_slash
    slug =~ /^\// ? slug : "/#{slug}"
  end
end
