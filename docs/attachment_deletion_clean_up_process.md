# Context

We've conducted some analysis to understand how attachments and their asset counterparts fall out of sync. 
As part of that, we've queried whitehall and asset-manager to identify where they disagree about the state of deleted assets.

There are various states we're interested in:
1. Attachments are marked as deleted in wh but their assets in AM are not deleted (see process below)
   For these ones, we will call the `delete_attachment` rake task on the output `content_ids`
   The relevant rake task in `find_attachments_deleted_in_whitehall_but_not_in_asset_manager.rake`.
2. Attachments are on unpublished editions but their assets are not redirected.


# Process for identifying which assets are deleted in whitehall but not in asset manager

1. Login to aws and fetch the `govuk/whitehall-admin/mysql` password for next step
`gds aws govuk-integration-poweruser -l`

2. Run SQL query to identify assets
   - The command below outputs the result of the query into a temp file
   - Input the password (from previous step) when prompted
   - This query includes data for validation, as well as the attachment `content_id` which we're going to need to run the clean up rake task.
```shell
mysql -h whitehall-mysql.ceu7s3y9xx35.eu-west-1.rds.amazonaws.com -u whitehall -p -D whitehall_production -B -e "SELECT ad.id AS attachment_data_id, a.content_id AS attachment_content_id, assets.asset_manager_id
                                                                                                                 FROM attachment_data ad
                                                                                                                 INNER JOIN attachments a
                                                                                                                 ON a.attachment_data_id = ad.id
                                                                                                                 LEFT JOIN editions e
                                                                                                                 ON a.attachable_id = e.id
                                                                                                                 LEFT JOIN assets
                                                                                                                 ON assets.assetable_id=ad.id
                                                                                                                 WHERE e.state='superseded'
                                                                                                                 AND a.attachable_type = 'Edition'
                                                                                                                 AND assets.assetable_type = 'AttachmentData'
                                                                                                                 AND a.deleted=TRUE;" | tr '\t' ',' > /tmp/output.csv
```

3. Exit the pod
4. Use the pod identifier from the previous step and run:
   `kubectl cp -n apps whitehall-admin-7b5f787c96-9bcnl:/tmp/output.csv ~/govuk/deleted_in_wh_on_superseded_editions.csv`

5. Validate the output
   - In the wh console, loop through the output `AttachmentData` ids, and check that it's `deleted?`
```shell
# random selection from csv
attachment_data_ids = [147131, 147131, 185075, 185075, 289095, 289095, 185078, 185078, 363066, 363066, 343097, 343097, 376691, 376691, 83062,s 83062,s 387448, 387448, 838054, 276634, 276634, 406960, 406960, 407020, 407020, 409665, 409665, 409666, 409666, 345422, 345422, 424746, 424746, 429735, 429735, 437640, 440366, 440366, 442062, 442062, 454622, 451809, 451809, 459163, 459146, 431361, 431361, 471059, 343408, 343408, 343354, 343386, 343386, 343387, 343387, 343388, 343388, 343659, 343649, 343649, 343647, 343647, 378962, 378962, 378964, 378964, 378965, 378965, 378967, 378967, 378969, 378969, 378973]
attachment_data_ids.map{|id| AttachmentData.find(id).deleted?}
# all should be true
```

6. Test run
   - Run the script to identify assets on the sample csv by changing line 19 in the script to use `deleted_in_wh_on_superseded_editions_sample.csv` 
   - Run `rake find_attachments_deleted_in_whitehall_but_not_in_asset_manager["superseded]`

7. Manually validate test run output
```shell
# Output based on sample should be two Attachments & Asset IDs
["5a7de75ded915d74e6222d1d", "5a7e383c40f0b62305b81925"].map{|id| Asset.find(id).deleted_at}
#should both return nil

# the following should all have deleted timestamp (the rest from the sample)
["5a7a55ffed915d1a6421cbea", "5a7a560140f0b66eab99b768", "5a755c48ed915d6faf2b2639", "5a755c47e5274a3cb2869d0a", "5a7c62b1ed915d696ccfc6ce", "5a7c62b140f0b62aff6c14e7", "5a7a27c6e5274a34770e4a5e", "5a7a27c640f0b66eab99a22c", "5a7de75be5274a2e87dae451", "5a7ec2deed915d74e62264b5", "5a7ec2df40f0b6230268b5fd", "5a7e384040f0b62302689ef3", "5a78bf65e5274a2acd1897ac", "5a78bf66ed915d07d35b21e2", "5a7ddadc40f0b65d8b4e3e9e", "5a7ddadbed915d2acb6ee8a0", "5d9e2c0140f0b66914f727c6", "5a7c2b21e5274a1f5cc763ba", "5a7c2b22ed915d26a93017c8", "5a80580740f0b62305b8a996", "5a80580740f0b62302692f21", "5a7f7f5340f0b62305b87814", "5a7f7f5140f0b6230268fd9b", "5a800a8a40f0b62302691274", "5a800a8940f0b62305b88d16", "5a7f2f0d40f0b62305b85988", "5a7f2f0d40f0b6230268df33", "5a7ee0dbed915d74e622708c", "5a7ee0daed915d74e33f2fba", "5a8015c440f0b623026916b5", "5a8015bfe5274a2e8ab4e183", "5a7f52cae5274a2e8ab4b7a4", "5a7f52caed915d74e33f5baf", "5a818967ed915d74e33febf5", "5a80925740f0b6230269449c", "5a809255ed915d74e33fb300", "5a81792a40f0b623026977fa", "5a81792ae5274a2e87dbdd19", "5a7f8e4aed915d74e33f7292", "5a80755740f0b62305b8b45f", "5a807557ed915d74e622e919", "5a81932fed915d74e6233019", "5a8069ade5274a2e87db9ab0", "5a749ec040f0b61938c7eefb", "5a749ec1e5274a410efd1127", "5a815e1be5274a2e87dbd3f4", "5a7ebfcb40f0b62305b82efe", "5a7ebfcd40f0b62305b82eff", "5a7dc3f9e5274a5eaea6633f", "5a7e054ded915d74e33ef884", "5a7e054c40f0b62305b80489", "5a7e063440f0b62305b804ed", "5a7e0633e5274a2e87daf0c7", "5a7f0a55e5274a2e8ab49c4c", "5a7d5a13ed915d28e9f39c4e", "5a7d8586ed915d497af6ff29", "5a7d5eb2e5274a7b50cce8d0", "5a7d5eb2ed915d321c2dea17", "5a7d5014ed915d28e9f39893", "5a7d501540f0b60a7f1a9c07", "5a74e1fd40f0b65f6132300f", "5a74e1fb40f0b65c0e8453f4", "5a74fbad40f0b6399b2afbcc", "5a74fbade5274a59fa7167d9", "5a7ea4d0ed915d74e33f1803", "5a7ea4cfe5274a2e8ab4747a", "5a749b5eed915d0e8e39990f", "5a749b5fe5274a410efd0f56", "5a7ed33ced915d74e6226b16", "5a7ed33a40f0b6230268bc74", "5a7db47eed915d2acb6eda6f"]

# Check that the all AttachmentDatas are deleted?
```

8. Revert the test run changes and run the script to identify assets
`rake find_attachments_deleted_in_whitehall_but_not_in_asset_manager["superseded"]`

9. Validate output
We are outputting a verbose enough text file to be able to validate the data, including the `AttachmentData` id and `Asset` id, as well as the desired data which is the `Attachment` content id.
Check that the all `AttachmentDatas` are deleted. There are under 100 results so we can manually check that all return `deleted?` true.
Check that all `Assets` do not have a deleted timestamp set. There are under 100 results so we can manually check.

