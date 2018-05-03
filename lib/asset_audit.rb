class AssetAudit
  def cache_bust
    "cache_bust=#{rand(1e8)}"
  end

  def call(email, password, sample_size)
    signon_url = Plek.new.external_url_for('signon')
    whitehall_base_url = Plek.new.external_url_for('assets-origin')
    asset_manager_base_url = Plek.new.external_url_for('draft-assets')

    mechanize = Mechanize.new
    mechanize.agent.allowed_error_codes = %w(404)
    # mechanize.log = Logger.new($stdout)

    sign_in_page = mechanize.get("#{signon_url}/users/sign_in")
    signed_in_page = sign_in_page.form_with(id: 'new_user') do |form|
      form['user[email]'] = email
      form['user[password]'] = password
    end.submit

    message = (signed_in_page / '.alert-success').text
    raise 'Failed to sign in' unless message == 'Signed in successfully.'

    csv = CSV.new($stdout, col_sep: "\t")
    csv << %w(
      id
      visible
      whitehall_code
      asset_manager_code
      whitehall_location
      asset_manager_location
    )

    samples = AttachmentData.order("RAND(123)").limit(sample_size)
    samples.each do |attachment_data|
      visible = attachment_data.visible_to?(nil)
      unless visible
        csv << [
          attachment_data.id,
          visible
        ]
        next
      end

      whitehall_path = attachment_data.file.url
      asset_manager_path = attachment_data.file.asset_manager_path

      whitehall_url = "#{whitehall_base_url}#{whitehall_path}"
      asset_manager_url = "#{asset_manager_base_url}#{asset_manager_path}"

      # Make request for asset from Whitehall
      mechanize.redirect_ok = false
      whitehall_response = mechanize.get("#{whitehall_url}?#{cache_bust}")

      # Preparatory request for asset from Asset Manager following redirects
      # in order to authenticate against Asset Manager if necessary
      mechanize.redirect_ok = true
      mechanize.get("#{asset_manager_url}?#{cache_bust}")

      # Make request for asset from Asset Manager
      mechanize.redirect_ok = false
      asset_manager_response = mechanize.get("#{asset_manager_url}?#{cache_bust}")

      csv << [
        attachment_data.id,
        visible,
        whitehall_response.code,
        asset_manager_response.code,
        whitehall_response.header['location'],
        asset_manager_response.header['location'],
      ]
    end
  end
end
