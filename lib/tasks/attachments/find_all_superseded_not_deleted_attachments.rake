desc "Report on AttachmentData in WH that is not deleted"
task attachment_data_not_deleted: :environment do
  file1 = File.open("./lib/tasks/attachments/ad_not_deleted_but_replaced_OK.txt", "a")
  file11 = File.open("./lib/tasks/attachments/ad_not_deleted_but_replaced_with_draft_replacement.txt", "a")
  file2 = File.open("./lib/tasks/attachments/ad_not_deleted_replaced_in_wh_but_not_in_am.txt", "a")
  file3 = File.open("./lib/tasks/attachments/ad_not_deleted_not_replaced_in_wh.txt", "a")

  AttachmentData.find_each.map do |attachment_data|
    attachments = attachment_data.attachments
    attachables = attachments.map(&:attachable).compact

    next unless attachables.any?
    next if attachables.detect { |attachable| !attachable.is_a?(Edition) }
    next if (attachables.map(&:state) - %w[superseded]).any?

    next if attachment_data.deleted?

    document_id = attachables.last.document.id

    attachment_data.assets.map do |asset|
      begin
        am_response = GdsApi.asset_manager.asset(asset.asset_manager_id).to_h
      rescue GdsApi::HTTPNotFound
        next
      end

      variant = asset.variant

      if attachment_data.replaced_by_id
        if am_response["replacement_id"]
          replacement = get_rep(am_response["replacement_id"])

          if replacement["draft"]
            puts "draft_rep - ad: #{attachment_data.id}, d_id: #{document_id}, am_id: #{asset.asset_manager_id}, v: #{variant}, deleted: #{am_response['deleted']}, draft: #{am_response['draft']}, redirect: #{!am_response['redirect_url'].nil?}, #{attachment_data.created_at.year}, rep_del: #{replacement['deleted']}, rep_rep: #{!replacement['replacement_id'].nil?}"
            file11 << "draft_rep - ad: #{attachment_data.id}, d_id: #{document_id}, am_id: #{asset.asset_manager_id}, v: #{variant}, deleted: #{am_response['deleted']}, draft: #{am_response['draft']}, redirect: #{!am_response['redirect_url'].nil?}, #{attachment_data.created_at.year}, rep_del: #{replacement['deleted']}, rep_rep: #{!replacement['replacement_id'].nil?}" << "\n"
          else
            puts "all OK - ad: #{attachment_data.id}, d_id: #{document_id}, am_id: #{asset.asset_manager_id}, deleted: #{am_response['deleted']}, draft: #{am_response['draft']}, redirect: #{!am_response['redirect_url'].nil?}, #{attachment_data.created_at.year}"
            file1 << "all OK - ad: #{attachment_data.id}, d_id: #{document_id}, am_id: #{asset.asset_manager_id}, deleted: #{am_response['deleted']}, draft: #{am_response['draft']}, redirect: #{!am_response['redirect_url'].nil?}, #{attachment_data.created_at.year}" << "\n"
          end
        else
          puts "missing rep am - ad: #{attachment_data.id}, d_id: #{document_id}, am_id: #{asset.asset_manager_id}, v: #{variant}, deleted: #{am_response['deleted']}, draft: #{am_response['draft']}, redirect: #{!am_response['redirect_url'].nil?}, #{attachment_data.created_at.year}"
          file2 << "missing rep am - ad: #{attachment_data.id}, d_id: #{document_id}, am_id: #{asset.asset_manager_id}, v: #{variant}, deleted: #{am_response['deleted']}, draft: #{am_response['draft']}, redirect: #{!am_response['redirect_url'].nil?}, #{attachment_data.created_at.year}" << "\n"
        end
      else
        puts "nothing - ad: #{attachment_data.id}, d_id: #{document_id}, am_id: #{asset.asset_manager_id}, v: #{variant}, deleted: #{am_response['deleted']}, draft: #{am_response['draft']}, redirect: #{!am_response['redirect_url'].nil?}, #{attachment_data.created_at.year}, AL: #{am_response['access_limited'].present?}, ALO: #{am_response['access_limited_organisation_ids'].present?}"
        file3 << "nothing - ad: #{attachment_data.id}, d_id: #{document_id}, am_id: #{asset.asset_manager_id}, v: #{variant}, deleted: #{am_response['deleted']}, draft: #{am_response['draft']}, redirect: #{!am_response['redirect_url'].nil?}, #{attachment_data.created_at.year}, AL: #{am_response['access_limited'].present?}, ALO: #{am_response['access_limited_organisation_ids'].present?}" << "\n"
      end
    end
  end

  file1.close
  file11.close
  file2.close
  file3.close
end

def get_rep(replacement_id)
  begin
    am_response = GdsApi.asset_manager.asset(replacement_id).to_h
  rescue GdsApi::HTTPNotFound
    puts "#{attachment_data.id}, #{asset.asset_manager_id}, no replacement found for given ID"

    nil
  end

  am_response
end
