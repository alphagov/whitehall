module GravatarHelper
  def gravatar_image(user, opts = {})
    scheme_and_host = opts[:ssl] ? "https://secure.gravatar.com" : "http://www.gravatar.com"
    gravatar_hash = user && user.email ? Digest::MD5.hexdigest(user.email.downcase) : "0"
    url = "#{scheme_and_host}/avatar/#{gravatar_hash}?d=mm&s=40"
    image_tag url, alt: user && user.name
  end
end
