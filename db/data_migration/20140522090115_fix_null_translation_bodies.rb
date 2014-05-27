Edition::Translation.where("body is NULL").update_all(body: "")
