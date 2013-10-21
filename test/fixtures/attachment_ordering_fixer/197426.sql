-- MySQL dump 10.13  Distrib 5.5.12, for osx10.6 (i386)
--
-- Host: localhost    Database: whitehall_test
-- ------------------------------------------------------
-- Server version	5.5.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` (`id`, `created_at`, `updated_at`, `slug`, `document_type`) VALUES (197426,'2013-10-09 12:30:24','2013-10-09 12:30:24','provider-guidance-esf-for-families-with-multiple-problems','Publication');
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `editions`
--

LOCK TABLES `editions` WRITE;
/*!40000 ALTER TABLE `editions` DISABLE KEYS */;
INSERT INTO `editions` (`id`, `created_at`, `updated_at`, `lock_version`, `document_id`, `state`, `type`, `role_appointment_id`, `location`, `delivered_on`, `opening_on`, `closing_on`, `major_change_published_at`, `first_published_at`, `speech_type_id`, `stub`, `change_note`, `force_published`, `minor_change`, `publication_type_id`, `related_mainstream_content_url`, `related_mainstream_content_title`, `additional_related_mainstream_content_url`, `additional_related_mainstream_content_title`, `alternative_format_provider_id`, `published_related_publication_count`, `public_timestamp`, `primary_mainstream_category_id`, `scheduled_publication`, `replaces_businesslink`, `access_limited`, `published_major_version`, `published_minor_version`, `operational_field_id`, `roll_call_introduction`, `news_article_type_id`, `relevant_to_local_government`, `person_override`, `locale`, `external`, `external_url`) VALUES (248643,'2013-10-09 12:30:24','2013-10-09 13:23:03',2,197426,'draft','Publication',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,3,NULL,NULL,NULL,NULL,10,0,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,0,NULL,'en',0,'');
/*!40000 ALTER TABLE `editions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `edition_translations`
--

LOCK TABLES `edition_translations` WRITE;
/*!40000 ALTER TABLE `edition_translations` DISABLE KEYS */;
INSERT INTO `edition_translations` (`id`, `edition_id`, `locale`, `title`, `summary`, `body`, `created_at`, `updated_at`) VALUES (224074,248643,'en','Provider Guidance: ESF for families with multiple problems','Information for providers about your role as an organisation contracted to deliver \'ESF for families with multiple problems\' provision for the DWP.\r\n','Information for providers about your role as an organisation contracted to deliver \'ESF for families with multiple problems\' provision for the DWP.\r\n\r\n*[DWP]: Department for Work and Pensions\r\n*[ESF]: European Social Fund','2013-10-09 12:30:24','2013-10-09 12:31:28');
/*!40000 ALTER TABLE `edition_translations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `attachments`
--

LOCK TABLES `attachments` WRITE;
/*!40000 ALTER TABLE `attachments` DISABLE KEYS */;
INSERT INTO `attachments` (`id`, `created_at`, `updated_at`, `title`, `accessible`, `isbn`, `unique_reference`, `command_paper_number`, `order_url`, `price_in_pence`, `attachment_data_id`, `ordering`, `hoc_paper_number`, `parliamentary_session`, `unnumbered_command_paper`, `unnumbered_hoc_paper`, `attachable_id`, `attachable_type`) VALUES (393467,'2013-10-09 12:33:42','2013-10-09 12:33:44','Chapter 1 - Introduction and Overview ',0,'','','','',NULL,249129,0,'','',0,0,248643,'Edition'),(393469,'2013-10-09 12:34:28','2013-10-09 12:34:28','Chapter 2 - Strategic Working Relationships, Working with Partners ',0,'','','','',NULL,249131,1,'','',0,0,248643,'Edition'),(393470,'2013-10-09 12:35:11','2013-10-09 12:35:12','Chapter 3 - Eligibility and initial engagement ',0,'','','','',NULL,249132,2,'','',0,0,248643,'Edition'),(393476,'2013-10-09 12:38:47','2013-10-09 12:38:47','Chapter 4 - Completion of ESF14 and Attachments',0,'','','','',NULL,249138,3,'','',0,0,248643,'Edition'),(393478,'2013-10-09 12:41:58','2013-10-09 12:41:58','Chapter 5 - Action planning and working with families ',0,'','','','',NULL,249140,4,'','',0,0,248643,'Edition'),(393483,'2013-10-09 12:43:01','2013-10-09 12:43:01','Chapter 6 - Progress Measures ',0,'','','','',NULL,249145,5,'','',0,0,248643,'Edition'),(393488,'2013-10-09 12:46:04','2013-10-09 12:46:04','Chapter 7 - Payments, Timing and Evidence Requirements ',0,'','','','',NULL,249151,6,'','',0,0,248643,'Edition'),(393490,'2013-10-09 12:54:26','2013-10-09 12:54:26','Chapter 8 - Performance Management and ESF Compliance ',0,'','','','',NULL,249155,7,'','',0,0,248643,'Edition'),(393505,'2013-10-09 13:13:35','2013-10-09 13:13:35','Chapter 9 - Completing ESF and Updating ESF Customer Records',0,'','','','',NULL,249166,8,'','',0,0,248643,'Edition'),(393541,'2013-10-09 13:20:16','2013-10-09 13:20:16','Chapter 10 - Management Information ',0,'','','','',NULL,249177,9,'','',0,0,248643,'Edition');
/*!40000 ALTER TABLE `attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `old_attachments`
--
DROP TABLE IF EXISTS `old_attachments`;
CREATE TABLE `old_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `accessible` tinyint(1) DEFAULT NULL,
  `isbn` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `unique_reference` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `command_paper_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `order_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price_in_pence` int(11) DEFAULT NULL,
  `attachment_data_id` int(11) DEFAULT NULL,
  `ordering` int(11) DEFAULT NULL,
  `hoc_paper_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parliamentary_session` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `unnumbered_command_paper` tinyint(1) DEFAULT NULL,
  `unnumbered_hoc_paper` tinyint(1) DEFAULT NULL,
  `attachable_id` int(11) DEFAULT NULL,
  `attachable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_attachments_on_attachment_data_id` (`attachment_data_id`),
  KEY `index_attachments_on_ordering` (`ordering`),
  KEY `index_attachments_on_attachable_id_and_attachable_type` (`attachable_id`,`attachable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=395726 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
LOCK TABLES `old_attachments` WRITE;
/*!40000 ALTER TABLE `old_attachments` DISABLE KEYS */;
INSERT INTO `old_attachments` (`id`, `created_at`, `updated_at`, `title`, `accessible`, `isbn`, `unique_reference`, `command_paper_number`, `order_url`, `price_in_pence`, `attachment_data_id`, `ordering`, `hoc_paper_number`, `parliamentary_session`, `unnumbered_command_paper`, `unnumbered_hoc_paper`, `attachable_id`, `attachable_type`) VALUES (393467,'2013-10-09 12:33:42','2013-10-09 12:33:44','Chapter 1 - Introduction and Overview ',0,'','','','',NULL,249129,0,'','',0,0,248643,'Edition'),(393469,'2013-10-09 12:34:28','2013-10-09 12:34:28','Chapter 2 - Strategic Working Relationships, Working with Partners ',0,'','','','',NULL,249131,1,'','',0,0,248643,'Edition'),(393470,'2013-10-09 12:35:11','2013-10-09 12:35:12','Chapter 3 - Eligibility and initial engagement ',0,'','','','',NULL,249132,2,'','',0,0,248643,'Edition'),(393476,'2013-10-09 12:38:47','2013-10-09 12:38:47','Chapter 4 - Completion of ESF14 and Attachments',0,'','','','',NULL,249138,3,'','',0,0,248643,'Edition'),(393478,'2013-10-09 12:41:58','2013-10-09 12:41:58','Chapter 5 - Action planning and working with families ',0,'','','','',NULL,249140,4,'','',0,0,248643,'Edition'),(393483,'2013-10-09 12:43:01','2013-10-09 12:43:01','Chapter 6 - Progress Measures ',0,'','','','',NULL,249145,5,'','',0,0,248643,'Edition'),(393488,'2013-10-09 12:46:04','2013-10-09 12:46:04','Chapter 7 - Payments, Timing and Evidence Requirements ',0,'','','','',NULL,249151,6,'','',0,0,248643,'Edition'),(393490,'2013-10-09 12:54:26','2013-10-09 12:54:26','Chapter 8 - Performance Management and ESF Compliance ',0,'','','','',NULL,249155,7,'','',0,0,248643,'Edition'),(393505,'2013-10-09 13:13:35','2013-10-09 13:13:35','Chapter 9 - Completing ESF and Updating ESF Customer Records',0,'','','','',NULL,249166,8,'','',0,0,248643,'Edition'),(393541,'2013-10-09 13:20:16','2013-10-09 13:20:16','Chapter 10 - Management Information ',0,'','','','',NULL,249177,9,'','',0,0,248643,'Edition');
/*!40000 ALTER TABLE `old_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `attachment_data`
--

LOCK TABLES `attachment_data` WRITE;
/*!40000 ALTER TABLE `attachment_data` DISABLE KEYS */;
INSERT INTO `attachment_data` (`id`, `carrierwave_file`, `content_type`, `file_size`, `number_of_pages`, `created_at`, `updated_at`, `replaced_by_id`) VALUES (249129,'esf-families-provider-guidance-chapter1.pdf','application/pdf',43254,4,'2013-10-09 12:33:41','2013-10-09 12:33:41',NULL),(249131,'esf-families-provider-guidance-chapter2.pdf','application/pdf',45888,5,'2013-10-09 12:34:28','2013-10-09 12:34:28',NULL),(249132,'esf-families-provider-guidance-chapter3.pdf','application/pdf',71145,10,'2013-10-09 12:35:11','2013-10-09 12:35:11',NULL),(249138,'esf-families-provider-guidance-chapter4.pdf','application/pdf',50012,5,'2013-10-09 12:38:47','2013-10-09 12:38:47',NULL),(249140,'esf-families-provider-guidance-chapter5.pdf','application/pdf',44926,5,'2013-10-09 12:41:58','2013-10-09 12:41:58',NULL),(249145,'esf-families-provider-guidance-chapter6.pdf','application/pdf',66265,9,'2013-10-09 12:43:01','2013-10-09 12:43:01',NULL),(249151,'esf-families-provider-guidance-chapter7.pdf','application/pdf',63290,4,'2013-10-09 12:46:03','2013-10-09 12:46:03',NULL),(249155,'esf-families-provider-guidance-chapter8.pdf','application/pdf',49265,4,'2013-10-09 12:54:25','2013-10-09 12:54:25',NULL),(249166,'esf-families-provider-guidance-chapter9.pdf','application/pdf',66757,5,'2013-10-09 13:13:35','2013-10-09 13:13:35',NULL),(249177,'esf-families-provider-guidance-chapter10.pdf','application/pdf',81086,8,'2013-10-09 13:20:16','2013-10-09 13:20:16',NULL);
/*!40000 ALTER TABLE `attachment_data` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-10-21 10:41:49
