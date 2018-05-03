class AssetAudit
  def cache_bust
    "cache_bust=#{rand(1e8)}"
  end

  def self.dump
    whitehall_base_url = Plek.new.external_url_for('assets-origin')
    asset_manager_base_url = Plek.new.external_url_for('draft-assets')

    CSV.new($stdout, headers: %i[whitehall asset_manager], write_headers: true) do |csv|
      AttachmentData.find_each do |attachment_data|
        next unless attachment_data.visible_to?(nil)

        whitehall_path = attachment_data.file.url
        asset_manager_path = attachment_data.file.asset_manager_path

        csv << { whitehall: "#{whitehall_base_url}#{whitehall_path}",
                 asset_manager: "#{asset_manager_base_url}#{asset_manager_path}" }
      end
    end
  end

  def signon_url
    @signon_url ||= Plek.new.external_url_for("signon")
  end

  def sign_user_in(mechanize, email, password)
    sign_in_page = mechanize.get("#{signon_url}/users/sign_in")
    sign_in_form = sign_in_page.form_with(id: 'new_user') do |form|
      form['user[email]'] = email
      form['user[password]'] = password
    end
    signed_in_page = sign_in_form.submit

    message = (signed_in_page / '.alert-success').text
    raise 'Failed to sign in' unless message == 'Signed in successfully.'
  end

  def ask_password
    print "Password: "
    STDIN.noecho(&:gets).chomp
  end

  def self.check_status(*args)
    new.check_status(*args)
  end

  def check_status(email, app_domain, urls_filename)
    ENV["GOVUK_APP_DOMAIN"] = app_domain

    mechanize = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    mechanize.agent.allowed_error_codes = %w(404)

    sign_user_in(mechanize, email, ask_password)

    csv = CSV.new(
      $stdout,
      headers: %w(
        whitehall_url
        asset_manage_url
        whitehall_status_code
        asset_manager_status_code
        whitehall_location
        asset_manager_location
        whitehall_content_type
        asset_manager_content_type
      ),
      write_headers: true,
    )

    CSV.foreach(urls_filename, headers: true) do |(whitehall_url, asset_manager_url)|
      mechanize.redirect_ok = false
      whitehall_response = mechanize.get("#{whitehall_url}?#{cache_bust}")

      # sign in through a signon redirect
      mechanize.redirect_ok = true
      mechanize.get("#{asset_manager_url}?#{cache_bust}")

      mechanize.redirect_ok = false
      asset_manager_response = mechanize.get("#{asset_manager_url}?#{cache_bust}")

      whitehall_status_code = whitehall_response.code
      asset_manager_status_code = asset_manager_response.code
      whitehall_location = whitehall_response.header["Location"]
      asset_manager_location = asset_manager_response.header["Location"]
      whitehall_content_type = whitehall_response.header["Content-Type"]
      asset_manager_content_type = asset_manager_response.header["Content-Type"]
      whitehall_content_length = whitehall_response.header["Content-Length"]
      asset_manager_content_length = asset_manager_response.header["Content-Length"]

      next if whitehall_status_code == asset_manager_status_code &&
          whitehall_location == asset_manager_location &&
          whitehall_content_type == asset_manager_content_type &&
          whitehall_content_length == asset_manager_content_length

      csv << [
        whitehall_url, asset_manager_url,
        whitehall_status_code, asset_manager_status_code,
        whitehall_location, asset_manager_location,
        whitehall_content_type, asset_manager_content_type,
        whitehall_content_length, asset_manager_content_length,
      ]
    end
  end
end
