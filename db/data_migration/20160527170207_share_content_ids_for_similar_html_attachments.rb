HtmlAttachment.connection.execute(<<-SQL)
  UPDATE `attachments` a
  INNER JOIN `editions` e ON a.`attachable_id` = e.`id` AND a.`attachable_type` = 'Edition'
  INNER JOIN (
  	SELECT e.`document_id`, a.`slug`, MAX(a.`content_id`) content_id
  	FROM `editions` e
  	INNER JOIN `attachments` a ON a.`attachable_id` = e.`id` AND a.`attachable_type` = 'Edition'
  	WHERE a.`type` = 'HtmlAttachment'
  	GROUP BY e.`document_id`, a.`slug`
  ) src ON e.`document_id` = src.`document_id` AND a.`slug` = src.`slug`
  SET a.`content_id` = src.`content_id`;
SQL
