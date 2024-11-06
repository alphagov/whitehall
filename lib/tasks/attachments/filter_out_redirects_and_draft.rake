desc "Report on AttachmentData in WH that should be marked as deleted"
task filter_out_redirects_and_draft: :environment do
  file = File.open("./lib/tasks/attachments/attachment_data_not_deleted_not_replaced_nor_is_in_draft_nor_has_redirect.txt", "a")

  ads = [119997, 215680, 215681, 215682, 348517, 348518, 417520, 429632, 438405, 559781, 571780, 589786, 622647, 654312, 659103, 674082, 681582, 688394, 693189, 693190, 693192, 700701, 705481, 713227, 713235, 713329, 718446, 718852, 734552, 738234, 739408, 739411, 739412, 744919, 745079, 746115, 747595, 747596, 749354, 750167, 750680, 751204, 751205, 751525, 756087, 756819, 765565, 767553, 769159, 792037, 803479, 804536, 804651, 804666, 809636, 823181, 826069, 829632, 840965, 841940, 841941, 848719, 854409, 864729, 871877, 871884, 871887, 876566, 876567, 877574, 880051, 880996, 882883, 883855, 888352, 888391, 888416, 888421, 888453, 888523, 889195, 890465, 890466, 890467, 897289, 899839, 899932, 900032, 900858, 901533, 901940, 903373, 903755, 907446, 911207, 919314, 920491, 925120, 925121, 925122, 925161, 941701, 957939, 961280, 980434, 980451, 980487, 980491, 980502, 980508, 980516, 980528, 980532, 980536, 980541, 980638, 980667, 980689, 980777, 980797, 981011, 981067, 981069, 981581, 981600, 984846, 987078, 997707, 1032258, 1070064, 1075634, 1075702, 1075704, 1075761, 1075814, 1075818, 1075892, 1075898, 1089182, 1161030, 1164980, 1170995, 1170997, 1170998, 1213255, 1229914, 1229915, 1229916, 1229917, 1229918, 1229919, 1229921, 1229922, 1229923, 1229924, 1253893, 1258311]

  ads.map do |attachment_data_id|
    attachment_data = AttachmentData.find(attachment_data_id)
    attachment_data.assets.map do |asset|
      begin
        asset_manager_response = GdsApi.asset_manager.asset(asset.asset_manager_id).to_h
      rescue GdsApi::HTTPNotFound
        next
      end

      puts "#{attachment_data.id}, #{asset.asset_manager_id}, replaced: #{!!asset_manager_response["replacement_id"]}, draft: #{asset_manager_response["draft"]}, redirect: #{asset_manager_response["redirect_url"] || "nil"}"

      next if asset_manager_response["draft"] || asset_manager_response["redirect_url"]

      file << "#{attachment_data.id}, #{asset.asset_manager_id}, replaced: #{!!asset_manager_response["replacement_id"]}, draft: #{asset_manager_response["draft"]}, redirect: #{asset_manager_response["redirect_url"] || "nil"}" << "\n"
    end
  end

  file.close
end
