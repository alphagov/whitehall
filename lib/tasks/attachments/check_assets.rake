desc "Check assets"
task check_assets: :environment do
  file = File.open("./lib/tasks/attachments/attachment_data_deleted_in_wh_replaced_in_both_but_replacements_are_draft.txt", "a")

  File.readlines("./lib/tasks/attachments/ads_to_check.txt", chomp: true).each do |line|
    attachment_data_id, asset_manager_id, = line.split(",")

    begin
      asset_manager_response = GdsApi.asset_manager.asset(asset_manager_id).to_h
      rep_response = GdsApi.asset_manager.asset(asset_manager_response["replacement_id"]).to_h
    rescue GdsApi::HTTPNotFound
      next
    end

    if rep_response["draft"]
      puts "ad: #{attachment_data_id}, am_id: #{asset_manager_id}, rep_id: #{asset_manager_response['replacement_id']}, rep_del: #{rep_response['deleted']}, rep_rep: #{!rep_response['replacement_id'].nil?}"
      file << "#{attachment_data_id},#{asset_manager_id},#{asset_manager_response['replacement_id']},#{rep_response['deleted']},#{!rep_response['replacement_id'].nil?}" << "\n"
    else
      print "."
    end
  end

  file.close
end
