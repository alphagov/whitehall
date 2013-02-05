module Admin::SocialMediaAccountsHelper
  def social_media_accounts_list_url_for(socialable)
    case socialable
    when Organisation
      url_for(controller: :organisations, action: :show, id: socialable, anchor: 'social_media_accounts')
    when WorldwideOffice
      url_for(controller: :worldwide_offices, action: :social_media_accounts, id: socialable)
    else
      url_for([:admin, socialable])
    end
  end
end