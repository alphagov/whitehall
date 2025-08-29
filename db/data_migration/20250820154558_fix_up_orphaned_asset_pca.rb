asset_manager_id = "655b5723046ed400148b9be1"
redirect_url = AttachmentData.joins(:assets)
                             .where(assets: { asset_manager_id: asset_manager_id })
                             .first
                             .redirect_url

AssetManager::AssetUpdater.call(asset_manager_id, { "redirect_url" => redirect_url })
