CREATE DATABASE  IF NOT EXISTS `cipher_warehouse` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `cipher_warehouse`;
-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: localhost    Database: cipher_warehouse
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `battalions`
--

DROP TABLE IF EXISTS `battalions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `battalions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `division_id` bigint unsigned NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(128) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_battalions_code` (`code`),
  KEY `idx_battalions_division_id` (`division_id`),
  CONSTRAINT `fk_battalions_divisions` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `battalions`
--

LOCK TABLES `battalions` WRITE;
/*!40000 ALTER TABLE `battalions` DISABLE KEYS */;
INSERT INTO `battalions` VALUES (1,1,'BTN-17','◊í◊ì◊ï◊ì 17','2025-12-27 18:18:42','2025-12-27 18:18:42'),(2,1,'BTN-450','◊í◊ì◊ï◊ì 450','2025-12-27 18:18:42','2025-12-27 18:18:42'),(3,1,'BTN-906','◊í◊ì◊ï◊ì 906','2025-12-27 18:18:42','2025-12-27 18:18:42');
/*!40000 ALTER TABLE `battalions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_device`
--

DROP TABLE IF EXISTS `core_device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_device` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `serial` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `makat` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `current_unit_id` bigint unsigned DEFAULT NULL,
  `encryption_model_id` bigint unsigned DEFAULT NULL,
  `battery_life` date DEFAULT NULL,
  `lifecycle_status` enum('NEW','PENDING_CARD','ACTIVE','NOT_ELIGIBLE','TRANSFERRED','REMOVED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NEW',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_core_device_serial` (`serial`),
  KEY `idx_core_device_makat` (`makat`),
  KEY `idx_core_device_current_unit` (`current_unit_id`),
  KEY `idx_core_device_status` (`lifecycle_status`),
  KEY `idx_core_device_deleted_at` (`deleted_at`),
  KEY `idx_core_device_encryption_model` (`encryption_model_id`),
  CONSTRAINT `fk_core_device_enc_model` FOREIGN KEY (`encryption_model_id`) REFERENCES `encryption_device_model` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_core_device_unit` FOREIGN KEY (`current_unit_id`) REFERENCES `storage_units` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_device`
--

LOCK TABLES `core_device` WRITE;
/*!40000 ALTER TABLE `core_device` DISABLE KEYS */;
INSERT INTO `core_device` VALUES (18,'490032','310902748','◊û◊ó 710',5,36,'2026-05-01','NEW',NULL,'2026-01-12 00:20:37','2026-01-12 01:35:17'),(19,'490201','310902748','◊û◊ó 710',1,36,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(20,'112101051','319658875','◊ê◊ï◊ú\"◊® ◊®◊ô◊©◊™◊ô',3,38,'2027-05-01','NEW',NULL,'2026-01-12 00:20:37','2026-01-12 01:25:18'),(21,'102301011','319658869','◊ê◊ï◊ú\"◊® ◊®◊ô◊©◊™◊ô XCOVER',1,39,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(22,'550751','319653269','◊û◊í◊ü ◊û◊õ◊ú◊ï◊ú',2,40,NULL,'ACTIVE',NULL,'2026-01-12 00:20:37','2026-01-13 01:29:06'),(23,'353251','319667169','◊ò◊ú 88',3,37,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(24,'761954','310902683','◊û◊ë\"◊ü',3,42,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(25,'886582','319652817','◊û◊ó◊©◊ë 19◊î',2,41,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(26,'554433','309418000','◊ò◊ú 100 ◊ì◊ô◊ë◊ï◊®',1,NULL,NULL,'NEW',NULL,'2026-01-13 01:06:48','2026-01-13 01:06:48'),(27,'543251','309415906','◊ò◊ú 100 ◊û◊ï◊ì◊ù',3,NULL,NULL,'NEW',NULL,'2026-01-13 01:06:48','2026-01-17 18:49:19'),(28,'533411','309418100','◊ò◊ú 100 ◊û◊ï◊ì◊ù',1,NULL,NULL,'NEW',NULL,'2026-01-13 01:06:48','2026-01-13 01:06:48');
/*!40000 ALTER TABLE `core_device` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `divisions`
--

DROP TABLE IF EXISTS `divisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `divisions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(32) NOT NULL,
  `name` varchar(128) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_divisions_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `divisions`
--

LOCK TABLES `divisions` WRITE;
/*!40000 ALTER TABLE `divisions` DISABLE KEYS */;
INSERT INTO `divisions` VALUES (1,'DIV-1','◊ó◊ò◊ô◊ë◊î 828','2025-12-27 18:18:42','2025-12-27 18:18:42');
/*!40000 ALTER TABLE `divisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `encryption_device_model`
--

DROP TABLE IF EXISTS `encryption_device_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encryption_device_model` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `makat` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `family_id` bigint unsigned NOT NULL,
  `carrier_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_encryption_device_model_makat` (`makat`),
  KEY `idx_encryption_device_model_family_id` (`family_id`),
  KEY `idx_encryption_device_model_is_active` (`is_active`),
  CONSTRAINT `fk_edm_family` FOREIGN KEY (`family_id`) REFERENCES `encryption_family` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `encryption_device_model`
--

LOCK TABLES `encryption_device_model` WRITE;
/*!40000 ALTER TABLE `encryption_device_model` DISABLE KEYS */;
INSERT INTO `encryption_device_model` VALUES (36,'310902748','◊û◊ó 710',1,'751',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(37,'319667169','◊ò◊ú 88',2,'751',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(38,'319658875','◊ê◊ï◊ú\"◊® ◊®◊ô◊©◊™◊ô',5,'◊ú◊ú◊ê',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(39,'319658869','◊ê◊ï◊ú\"◊® ◊®◊ô◊©◊™◊ô XCOVER',5,'◊ú◊ú◊ê',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(40,'319653269','◊û◊í◊ü ◊û◊õ◊ú◊ï◊ú',1,'751',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(41,'319652817','◊û◊ó◊©◊ë 19◊î',3,'656',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(42,'310902683','◊û◊ë\"◊ü',3,'173',1,'2025-12-20 02:19:24','2025-12-20 02:19:24');
/*!40000 ALTER TABLE `encryption_device_model` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `encryption_family`
--

DROP TABLE IF EXISTS `encryption_family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encryption_family` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_encrypted` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_encryption_family_code` (`code`),
  KEY `idx_encryption_family_is_active` (`is_active`),
  KEY `idx_encryption_family_is_encrypted` (`is_encrypted`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `encryption_family`
--

LOCK TABLES `encryption_family` WRITE;
/*!40000 ALTER TABLE `encryption_family` DISABLE KEYS */;
INSERT INTO `encryption_family` VALUES (1,'RADIO_ROMACH','◊®◊ì◊ô◊ï (◊õ◊ï◊ú◊ú ◊®◊ï◊û◊ó)',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(2,'RADIO_NO_ROMACH','◊®◊ì◊ô◊ï (◊ú◊ú◊ê ◊®◊ï◊û◊ó)',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(3,'ZIAD','◊¶◊ô\'◊ì',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(4,'MOBILITY','◊û◊ï◊ë◊ô◊ú◊ô◊ò◊ô',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(5,'OTHER','◊ê◊ó◊®',0,1,'2025-12-19 23:38:48','2025-12-19 23:38:48');
/*!40000 ALTER TABLE `encryption_family` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `encryption_family_rule`
--

DROP TABLE IF EXISTS `encryption_family_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encryption_family_rule` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `family_id` bigint unsigned NOT NULL,
  `symbol_scope` enum('GLOBAL','PER_UNIT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `symbol_global` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_encryption_family_rule_family` (`family_id`),
  KEY `idx_encryption_family_rule_is_active` (`is_active`),
  CONSTRAINT `fk_efr_family` FOREIGN KEY (`family_id`) REFERENCES `encryption_family` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `encryption_family_rule`
--

LOCK TABLES `encryption_family_rule` WRITE;
/*!40000 ALTER TABLE `encryption_family_rule` DISABLE KEYS */;
INSERT INTO `encryption_family_rule` VALUES (1,1,'GLOBAL','6013',1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(2,2,'GLOBAL','7013',1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(3,3,'PER_UNIT',NULL,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(4,4,'PER_UNIT',NULL,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(5,5,'GLOBAL',NULL,1,'2025-12-19 23:38:48','2025-12-19 23:38:48');
/*!40000 ALTER TABLE `encryption_family_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `encryption_period`
--

DROP TABLE IF EXISTS `encryption_period`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encryption_period` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `family_id` bigint unsigned NOT NULL,
  `valid_from` date NOT NULL,
  `valid_to` date DEFAULT NULL,
  `period_code` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `period_order` int NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ep_family_dates` (`family_id`,`valid_from`,`valid_to`),
  KEY `idx_ep_is_active` (`is_active`),
  CONSTRAINT `fk_ep_family` FOREIGN KEY (`family_id`) REFERENCES `encryption_family` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_ep_valid_window` CHECK (((`valid_to` is null) or (`valid_to` >= `valid_from`)))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `encryption_period`
--

LOCK TABLES `encryption_period` WRITE;
/*!40000 ALTER TABLE `encryption_period` DISABLE KEYS */;
INSERT INTO `encryption_period` VALUES (1,3,'2025-01-01',NULL,'049',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(2,1,'2025-01-01',NULL,'960',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(3,2,'2025-01-01',NULL,'960',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(4,2,'2025-01-01',NULL,'961',2,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(5,2,'2025-01-01',NULL,'962',3,1,'2025-12-19 23:38:48','2025-12-19 23:38:48');
/*!40000 ALTER TABLE `encryption_period` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `encryption_unit_symbol`
--

DROP TABLE IF EXISTS `encryption_unit_symbol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encryption_unit_symbol` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `family_id` bigint unsigned NOT NULL,
  `unit_id` bigint unsigned NOT NULL,
  `unit_symbol` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_encryption_unit_symbol` (`family_id`,`unit_id`),
  KEY `idx_eus_unit_id` (`unit_id`),
  KEY `idx_eus_family_id` (`family_id`),
  KEY `idx_eus_is_active` (`is_active`),
  CONSTRAINT `fk_eus_family` FOREIGN KEY (`family_id`) REFERENCES `encryption_family` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_eus_unit` FOREIGN KEY (`unit_id`) REFERENCES `storage_units` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `encryption_unit_symbol`
--

LOCK TABLES `encryption_unit_symbol` WRITE;
/*!40000 ALTER TABLE `encryption_unit_symbol` DISABLE KEYS */;
INSERT INTO `encryption_unit_symbol` VALUES (12,3,3,'800',1,'2025-12-20 06:03:56','2025-12-20 06:03:56'),(13,3,1,'330',1,'2025-12-20 06:04:39','2025-12-20 06:04:39'),(14,3,2,'790',1,'2025-12-20 06:05:05','2025-12-20 06:05:05');
/*!40000 ALTER TABLE `encryption_unit_symbol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refresh_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token_hash` char(64) NOT NULL,
  `issued_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_refresh_tokens_token_hash` (`token_hash`),
  KEY `idx_refresh_tokens_user_id_expires_at` (`user_id`,`expires_at`),
  CONSTRAINT `fk_refresh_tokens_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=425 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` VALUES (330,2,'e4caf8956c87c2c68efa5428291ff8a99c4c0439f13659372346212afcf66409','2026-01-08 23:43:25','2026-02-07 23:43:25',NULL,'PostmanRuntime/7.51.0','::1'),(332,2,'63922f46fedb066246bcde06a54466b467682270285dbb1298bae29fa02402cc','2026-01-08 23:44:49','2026-02-07 23:44:49',NULL,'PostmanRuntime/7.51.0','::1'),(333,4,'fe1ae302765c4920e53b64e1a2d3f7e258b85f47aab23c237a6de1695b7b73e6','2026-01-09 00:11:58','2026-02-08 00:11:58',NULL,'PostmanRuntime/7.51.0','::1'),(337,4,'12ab31a726eef42d93630df09543f4e9406cbd9059d54ee95a23a7497f6cd5c1','2026-01-09 01:02:27','2026-02-08 01:02:27',NULL,'PostmanRuntime/7.51.0','::1'),(338,4,'bc27a8110f2e726e160906e2fe806b94541627a1db42c5e2becb3d006f9605d0','2026-01-09 01:02:29','2026-02-08 01:02:29',NULL,'PostmanRuntime/7.51.0','::1'),(339,4,'59a370f301889dc60e1e0007ccde94c2d385b615ca03a79063bcfda8c527a1e3','2026-01-09 01:14:30','2026-02-08 01:14:30',NULL,'PostmanRuntime/7.51.0','::1'),(340,4,'0ca442155830ca2cbbd36b2fc66c04f09907403edf037f539e84816fff2d0f04','2026-01-09 01:14:31','2026-02-08 01:14:31',NULL,'PostmanRuntime/7.51.0','::1'),(341,2,'5044d3b348bb16d538ef1e31a0114a0d9f980235422224a911ff00e42788d8f1','2026-01-09 01:14:46','2026-02-08 01:14:46',NULL,'PostmanRuntime/7.51.0','::1'),(343,2,'afe8d34f1477cb8beca8a5673a9c55f42d6001dea36b0f4906de2ac2d0c82a03','2026-01-09 01:15:28','2026-02-08 01:15:28',NULL,'PostmanRuntime/7.51.0','::1'),(344,2,'465404e653e1f5ab31b8df6250536c79171b2e07306bd22f304c3328c1e1182d','2026-01-09 01:15:36','2026-02-08 01:15:36',NULL,'PostmanRuntime/7.51.0','::1'),(375,6,'6f65eb3a19912d36b5a0412253a749cdc12e8fb4b6662827c27ea12f6fcd2914','2026-01-16 17:48:47','2026-02-15 17:48:47',NULL,'PostmanRuntime/7.51.0','::1'),(376,6,'fc5aa2c94c89bf13bafca963e0b4059bdf7387d3508eaab42f5df79391c10a21','2026-01-16 17:52:08','2026-02-15 17:52:08',NULL,'PostmanRuntime/7.51.0','::1'),(377,6,'1868b23847017e50524ca9d5d37d478e38d71325fe36d1a1068371d1b55151e4','2026-01-16 18:01:06','2026-02-15 18:01:06',NULL,'PostmanRuntime/7.51.0','::1'),(408,6,'83bd1ff56596437ac2ef87d624bc0bbfd639c145d4ce521a27d564b799295795','2026-01-17 18:48:42','2026-02-16 18:48:42',NULL,'PostmanRuntime/7.51.0','::1'),(409,6,'c60e467e137d1b5bfe5148a9757575c69c3d107e2ee04c9e68392c9e7e0f16ef','2026-01-17 18:49:27','2026-02-16 18:49:27',NULL,'PostmanRuntime/7.51.0','::1'),(411,5,'ecbdad3618d57adaf772e09b02bad811ed906eb1e1cf3c426a4647e989da05e4','2026-01-17 18:53:08','2026-02-16 18:53:08',NULL,'PostmanRuntime/7.51.0','::1'),(413,5,'d11899ba11e7169b428a195cb8843fbf3fed94bac44ee601a0c7a228fae4350f','2026-01-17 18:54:57','2026-02-16 18:54:57',NULL,'PostmanRuntime/7.51.0','::1'),(415,5,'7c149fccc2ee457996a67f735230f10c7bd1005d349841af6e0917bec1ed5e3e','2026-01-17 19:08:54','2026-02-16 19:08:54',NULL,'PostmanRuntime/7.51.0','::1'),(416,5,'29182f45919afe8506949675912281262db6bf2c17b33388fd44509253202d08','2026-01-17 19:09:04','2026-02-16 19:09:04',NULL,'PostmanRuntime/7.51.0','::1'),(417,5,'640c2ac44bc42be4a49d59fa788436c88657c363078aa265c2f817ac809952f1','2026-01-17 21:08:30','2026-02-16 21:08:30',NULL,'PostmanRuntime/7.51.0','::1'),(420,1,'8c75a0907e94722fbfca4f39b6993dcbe6de706228e144fbfc75a449f25c34a1','2026-01-17 21:48:25','2026-02-16 21:48:25',NULL,'PostmanRuntime/7.51.0','::1'),(421,1,'e8f62316bafa916c6e94abc55a1339726085e9a471a5697db556802e498905a2','2026-01-17 22:18:57','2026-02-16 22:18:57',NULL,'PostmanRuntime/7.51.0','::1'),(422,1,'5beb0cf397fcdfdf9b625d674f4010bbe8441e39819d8acc7b7a150fca0b81f5','2026-01-17 22:27:21','2026-02-16 22:27:21',NULL,'PostmanRuntime/7.51.0','::1'),(423,1,'6d89db4cc91061d8a1be73cae930897e9ce37348d5a2f75f841f0701b9a14939','2026-01-17 22:43:59','2026-02-16 22:43:59',NULL,'PostmanRuntime/7.51.0','::1'),(424,1,'0dfafead58ab653849e0a1e65d40429f93045b17c77f6e09ed657c4b72ec16a4','2026-01-17 23:17:53','2026-02-16 23:17:53',NULL,'PostmanRuntime/7.51.0','::1');
/*!40000 ALTER TABLE `refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `storage_units`
--

DROP TABLE IF EXISTS `storage_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `storage_units` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `unit_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `storage_site` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `battalion_id` bigint unsigned DEFAULT NULL,
  `division_id` bigint unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_storage_units_storage_site` (`storage_site`),
  KEY `idx_storage_units_is_active` (`is_active`),
  KEY `idx_storage_units_battalion_id` (`battalion_id`),
  KEY `idx_storage_units_division_id` (`division_id`),
  CONSTRAINT `fk_storage_units_battalions` FOREIGN KEY (`battalion_id`) REFERENCES `battalions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_storage_units_divisions` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storage_units`
--

LOCK TABLES `storage_units` WRITE;
/*!40000 ALTER TABLE `storage_units` DISABLE KEYS */;
INSERT INTO `storage_units` VALUES (1,'◊§◊ú◊ó◊ô◊ß571/◊ó◊ò828','MG01',NULL,1,1,'2025-12-20 03:28:29','2026-01-12 00:19:31'),(2,'◊ó◊ò◊ô◊ë◊î828/◊í◊ì◊ï◊ì450','MG32',2,1,1,'2025-12-20 04:23:44','2026-01-12 01:33:55'),(3,'◊ó◊ò◊ô◊ë◊î828/◊í◊ì◊ï◊ì17','MG72',1,1,1,'2025-12-20 04:23:44','2026-01-12 01:33:55'),(5,'◊í◊ì 828/906/◊ß◊©◊®','MG53',3,1,1,'2026-01-12 01:33:22','2026-01-12 01:34:30');
/*!40000 ALTER TABLE `storage_units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tel100_modem_profile`
--

DROP TABLE IF EXISTS `tel100_modem_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tel100_modem_profile` (
  `core_device_id` bigint unsigned NOT NULL,
  `hamal_user` varchar(160) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_title` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sim_black_ct` longblob,
  `sim_black_iv` binary(12) DEFAULT NULL,
  `sim_black_tag` binary(16) DEFAULT NULL,
  `sim_black_kv` smallint unsigned DEFAULT NULL,
  `sim_red_binding_id_ct` longblob,
  `sim_red_binding_id_iv` binary(12) DEFAULT NULL,
  `sim_red_binding_id_tag` binary(16) DEFAULT NULL,
  `sim_red_binding_id_kv` smallint unsigned DEFAULT NULL,
  `sim_red_copy_marking_short_ct` longblob,
  `sim_red_copy_marking_short_iv` binary(12) DEFAULT NULL,
  `sim_red_copy_marking_short_tag` binary(16) DEFAULT NULL,
  `sim_red_copy_marking_short_kv` smallint unsigned DEFAULT NULL,
  `sim_red_copy_marking_long_ct` longblob,
  `sim_red_copy_marking_long_iv` binary(12) DEFAULT NULL,
  `sim_red_copy_marking_long_tag` binary(16) DEFAULT NULL,
  `sim_red_copy_marking_long_kv` smallint unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`core_device_id`),
  CONSTRAINT `fk_tel100_modem_profile_core_device` FOREIGN KEY (`core_device_id`) REFERENCES `core_device` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tel100_modem_profile`
--

LOCK TABLES `tel100_modem_profile` WRITE;
/*!40000 ALTER TABLE `tel100_modem_profile` DISABLE KEYS */;
INSERT INTO `tel100_modem_profile` VALUES (27,'h0772207','◊û◊ï◊ì◊ù ◊î◊ì◊®◊õ◊î 1',_binary '\Ã\ ÛÑ=\Á+@Ø´™n\‡\ÌîfˇÑ',_binary 'H÷ìKd\·\Ã\"ß¿±=',_binary '<Ñ∞Äà§<JQC\‚é\”',2,_binary 'sd\Ëøx\·\Ã`z/]\Î',_binary 'sJ\¬\—\—R\„GÕ†P\Ó',_binary '~Æ≠ï\∆\–O\’\¬Úv§ßd≥y',2,_binary 'u-\⁄\ÏI([Õ§\‚\—n˘œèÑ¶ã°˙\Ó\ﬂ',_binary '»ã∑[iNg`äÄ\È',_binary '∑L\’R\ÊN≥ùÄb\ƒ^¡',2,_binary ' \‚\ÂqVK2}9\„8˝ZFâ∆©\∆›ê\› \Ÿ\‚\”	f,N\Z∞',_binary '\”Lï8∫O3 V|øW',_binary 'à3^\“\‡´de\Íô\'M\«',2,'2026-01-17 12:25:20','2026-01-17 17:42:19'),(28,'h0772207','◊û◊ï◊ì◊ù ◊î◊ì◊®◊õ◊î 2',_binary 'π\√j£ef)˛âJP\‹x«Äº>',_binary '\›0v\ÊüÒW•_',_binary '\ÊcE.8vT)˚;1ïÿ¶',2,_binary '{*íoZS\Œ\‰E9˚\«',_binary '?%\Â`\„n\√\Ê	\¬',_binary '\‹∞\Ê–Ωs˜•å\ÁÇ|\„',2,_binary '(47`înû\€(ﬂèÉV¥çÑß+\√M',_binary '®/\œ∆ö-]ç',_binary 'ùBpù\’L\"@j\ﬂMn\⁄:p',2,_binary 'ä˘\ ‹õø˛\ﬁCqö¨\÷\ÿvz\›\÷eN	n\‚˚jy\⁄8\√\”g',_binary '•Øö¥SWöèBÿµ',_binary 'ò∏{ÅΩV´˙b∂â1x#',2,'2026-01-17 12:25:22','2026-01-17 18:54:42');
/*!40000 ALTER TABLE `tel100_modem_profile` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tel100_modem_profile_ins` BEFORE INSERT ON `tel100_modem_profile` FOR EACH ROW BEGIN
  DECLARE v_makat varchar(64);

  SELECT d.`makat` INTO v_makat
  FROM `core_device` d
  WHERE d.`id` = NEW.`core_device_id`
  LIMIT 1;

  IF v_makat IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TEL100_MODEM: core_device not found';
  END IF;

  IF v_makat NOT IN ('309415906','309418100') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TEL100_MODEM: invalid makat for modem profile';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tel100_modem_profile_bundle_ins` BEFORE INSERT ON `tel100_modem_profile` FOR EACH ROW BEGIN
  IF NOT (
    (NEW.sim_black_ct IS NULL AND NEW.sim_black_iv IS NULL AND NEW.sim_black_tag IS NULL AND NEW.sim_black_kv IS NULL)
    OR
    (NEW.sim_black_ct IS NOT NULL AND NEW.sim_black_iv IS NOT NULL AND NEW.sim_black_tag IS NOT NULL AND NEW.sim_black_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MODEM: invalid sim_black bundle'; END IF;

  IF NOT (
    (NEW.sim_red_binding_id_ct IS NULL AND NEW.sim_red_binding_id_iv IS NULL AND NEW.sim_red_binding_id_tag IS NULL AND NEW.sim_red_binding_id_kv IS NULL)
    OR
    (NEW.sim_red_binding_id_ct IS NOT NULL AND NEW.sim_red_binding_id_iv IS NOT NULL AND NEW.sim_red_binding_id_tag IS NOT NULL AND NEW.sim_red_binding_id_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MODEM: invalid sim_red_binding_id bundle'; END IF;

  IF NOT (
    (NEW.sim_red_copy_marking_short_ct IS NULL AND NEW.sim_red_copy_marking_short_iv IS NULL AND NEW.sim_red_copy_marking_short_tag IS NULL AND NEW.sim_red_copy_marking_short_kv IS NULL)
    OR
    (NEW.sim_red_copy_marking_short_ct IS NOT NULL AND NEW.sim_red_copy_marking_short_iv IS NOT NULL AND NEW.sim_red_copy_marking_short_tag IS NOT NULL AND NEW.sim_red_copy_marking_short_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MODEM: invalid sim_red_copy_marking_short bundle'; END IF;

  IF NOT (
    (NEW.sim_red_copy_marking_long_ct IS NULL AND NEW.sim_red_copy_marking_long_iv IS NULL AND NEW.sim_red_copy_marking_long_tag IS NULL AND NEW.sim_red_copy_marking_long_kv IS NULL)
    OR
    (NEW.sim_red_copy_marking_long_ct IS NOT NULL AND NEW.sim_red_copy_marking_long_iv IS NOT NULL AND NEW.sim_red_copy_marking_long_tag IS NOT NULL AND NEW.sim_red_copy_marking_long_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MODEM: invalid sim_red_copy_marking_long bundle'; END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tel100_modem_profile_upd` BEFORE UPDATE ON `tel100_modem_profile` FOR EACH ROW BEGIN
  DECLARE v_makat varchar(64);

  SELECT d.`makat` INTO v_makat
  FROM `core_device` d
  WHERE d.`id` = NEW.`core_device_id`
  LIMIT 1;

  IF v_makat IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TEL100_MODEM: core_device not found';
  END IF;

  IF v_makat NOT IN ('309415906','309418100') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TEL100_MODEM: invalid makat for modem profile';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tel100_modem_profile_bundle_upd` BEFORE UPDATE ON `tel100_modem_profile` FOR EACH ROW BEGIN
  IF NOT (
    (NEW.sim_black_ct IS NULL AND NEW.sim_black_iv IS NULL AND NEW.sim_black_tag IS NULL AND NEW.sim_black_kv IS NULL)
    OR
    (NEW.sim_black_ct IS NOT NULL AND NEW.sim_black_iv IS NOT NULL AND NEW.sim_black_tag IS NOT NULL AND NEW.sim_black_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MODEM: invalid sim_black bundle'; END IF;

  IF NOT (
    (NEW.sim_red_binding_id_ct IS NULL AND NEW.sim_red_binding_id_iv IS NULL AND NEW.sim_red_binding_id_tag IS NULL AND NEW.sim_red_binding_id_kv IS NULL)
    OR
    (NEW.sim_red_binding_id_ct IS NOT NULL AND NEW.sim_red_binding_id_iv IS NOT NULL AND NEW.sim_red_binding_id_tag IS NOT NULL AND NEW.sim_red_binding_id_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MODEM: invalid sim_red_binding_id bundle'; END IF;

  IF NOT (
    (NEW.sim_red_copy_marking_short_ct IS NULL AND NEW.sim_red_copy_marking_short_iv IS NULL AND NEW.sim_red_copy_marking_short_tag IS NULL AND NEW.sim_red_copy_marking_short_kv IS NULL)
    OR
    (NEW.sim_red_copy_marking_short_ct IS NOT NULL AND NEW.sim_red_copy_marking_short_iv IS NOT NULL AND NEW.sim_red_copy_marking_short_tag IS NOT NULL AND NEW.sim_red_copy_marking_short_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MODEM: invalid sim_red_copy_marking_short bundle'; END IF;

  IF NOT (
    (NEW.sim_red_copy_marking_long_ct IS NULL AND NEW.sim_red_copy_marking_long_iv IS NULL AND NEW.sim_red_copy_marking_long_tag IS NULL AND NEW.sim_red_copy_marking_long_kv IS NULL)
    OR
    (NEW.sim_red_copy_marking_long_ct IS NOT NULL AND NEW.sim_red_copy_marking_long_iv IS NOT NULL AND NEW.sim_red_copy_marking_long_tag IS NOT NULL AND NEW.sim_red_copy_marking_long_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MODEM: invalid sim_red_copy_marking_long bundle'; END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tel100_voice_profile`
--

DROP TABLE IF EXISTS `tel100_voice_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tel100_voice_profile` (
  `core_device_id` bigint unsigned NOT NULL,
  `full_name` varchar(160) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_type` enum('PERMANENT','RESERVE','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `personal_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_title` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ptt_status` enum('OK','NOT_OK','UNKNOWN') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UNKNOWN',
  `ptt_group_ct` longblob,
  `ptt_group_iv` binary(12) DEFAULT NULL,
  `ptt_group_tag` binary(16) DEFAULT NULL,
  `ptt_group_kv` smallint unsigned DEFAULT NULL,
  `hub_password_ct` longblob,
  `hub_password_iv` binary(12) DEFAULT NULL,
  `hub_password_tag` binary(16) DEFAULT NULL,
  `hub_password_kv` smallint unsigned DEFAULT NULL,
  `operational_auth_code_ct` longblob,
  `operational_auth_code_iv` binary(12) DEFAULT NULL,
  `operational_auth_code_tag` binary(16) DEFAULT NULL,
  `operational_auth_code_kv` smallint unsigned DEFAULT NULL,
  `device_pin_ct` longblob,
  `device_pin_iv` binary(12) DEFAULT NULL,
  `device_pin_tag` binary(16) DEFAULT NULL,
  `device_pin_kv` smallint unsigned DEFAULT NULL,
  `opening_template_ct` longblob,
  `opening_template_iv` binary(12) DEFAULT NULL,
  `opening_template_tag` binary(16) DEFAULT NULL,
  `opening_template_kv` smallint unsigned DEFAULT NULL,
  `sim_black_ct` longblob,
  `sim_black_iv` binary(12) DEFAULT NULL,
  `sim_black_tag` binary(16) DEFAULT NULL,
  `sim_black_kv` smallint unsigned DEFAULT NULL,
  `sim_red_binding_id_ct` longblob,
  `sim_red_binding_id_iv` binary(12) DEFAULT NULL,
  `sim_red_binding_id_tag` binary(16) DEFAULT NULL,
  `sim_red_binding_id_kv` smallint unsigned DEFAULT NULL,
  `sim_red_copy_marking_short_ct` longblob,
  `sim_red_copy_marking_short_iv` binary(12) DEFAULT NULL,
  `sim_red_copy_marking_short_tag` binary(16) DEFAULT NULL,
  `sim_red_copy_marking_short_kv` smallint unsigned DEFAULT NULL,
  `sim_red_copy_marking_long_ct` longblob,
  `sim_red_copy_marking_long_iv` binary(12) DEFAULT NULL,
  `sim_red_copy_marking_long_tag` binary(16) DEFAULT NULL,
  `sim_red_copy_marking_long_kv` smallint unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`core_device_id`),
  CONSTRAINT `fk_tel100_voice_profile_core_device` FOREIGN KEY (`core_device_id`) REFERENCES `core_device` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tel100_voice_profile`
--

LOCK TABLES `tel100_voice_profile` WRITE;
/*!40000 ALTER TABLE `tel100_voice_profile` DISABLE KEYS */;
INSERT INTO `tel100_voice_profile` VALUES (26,'◊ê◊ï◊®◊ê◊ú ◊ò◊ï◊ï◊ô◊ò◊ï','PERMANENT','8388610','◊û◊û ◊¶◊ï◊§◊ü','8178281','OK',_binary '$\„+J›õm˜Nm_kdñ|Ω\ƒ.˚',_binary 'õ\ƒ˜ üØ\„yë\‚',_binary '\nJ\»\ﬂé\÷\nu∫\ÌΩÙ\«',2,_binary 'h’Åd∂',_binary '\À	EÙ≥}\"K\‰*',_binary 'Y\¬t	<ù≤ˆáw\Ôs\r',2,_binary '>6\◊\Œ\Ô',_binary 'Àñ®¿@${G\ÊÃ©',_binary '\√~E\ÓíN¨yOΩRo:{',2,_binary '©Û¨',_binary 'ª\”$7\0ÆD  :$',_binary '\’0Ü#\"6s®yπ≠>\¬\‡\’',2,_binary '.\È˘f¢&\Ã\È&+q',_binary 'e°Ö}f∏´æ##',_binary '∏!p4\‹`@!^trXï',2,_binary '^2sR~\„\œT\ÀZ)\’o¸,¢\›',_binary 'Hâ1ù\Œ◊Ä9õˇ\Á',_binary '\Ó/\È\À\‰LuKn[õêj\Ÿ',2,_binary 'çx\‚Åª%èo∞)',_binary 'MÉSeñ:\‹géT',_binary '$#h•0öç\⁄\Ã|\Õ\Ë<y',2,_binary '	Ø|€π´érî\·\Ó.ª¯\÷\‡cH',_binary '&\√ñä2Ê¨∂π',_binary 'ù±∂U´¶ß AöG\‡\‡',2,_binary 'ıDSH#s\∆r6ªÙ§.\”\√YX`\‚\Î\Ï\ZA(£]ì\r#,\¬',_binary '\Ê\Ì~-\◊T”ø’¶8c',_binary 'àÇ\∆\ÌùOhZ \ÁhΩ',2,'2026-01-17 12:24:43','2026-01-17 21:30:07');
/*!40000 ALTER TABLE `tel100_voice_profile` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tel100_voice_profile_ins` BEFORE INSERT ON `tel100_voice_profile` FOR EACH ROW BEGIN
  DECLARE v_makat varchar(64);

  SELECT d.`makat` INTO v_makat
  FROM `core_device` d
  WHERE d.`id` = NEW.`core_device_id`
  LIMIT 1;

  IF v_makat IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TEL100_VOICE: core_device not found';
  END IF;

  IF v_makat <> '309418000' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TEL100_VOICE: invalid makat for voice profile';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tel100_voice_profile_bundle_ins` BEFORE INSERT ON `tel100_voice_profile` FOR EACH ROW BEGIN
  -- helper macro-like checks (manual)
  IF NOT (
    (NEW.ptt_group_ct IS NULL AND NEW.ptt_group_iv IS NULL AND NEW.ptt_group_tag IS NULL AND NEW.ptt_group_kv IS NULL)
    OR
    (NEW.ptt_group_ct IS NOT NULL AND NEW.ptt_group_iv IS NOT NULL AND NEW.ptt_group_tag IS NOT NULL AND NEW.ptt_group_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid ptt_group bundle'; END IF;

  IF NOT (
    (NEW.hub_password_ct IS NULL AND NEW.hub_password_iv IS NULL AND NEW.hub_password_tag IS NULL AND NEW.hub_password_kv IS NULL)
    OR
    (NEW.hub_password_ct IS NOT NULL AND NEW.hub_password_iv IS NOT NULL AND NEW.hub_password_tag IS NOT NULL AND NEW.hub_password_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid hub_password bundle'; END IF;

  IF NOT (
    (NEW.operational_auth_code_ct IS NULL AND NEW.operational_auth_code_iv IS NULL AND NEW.operational_auth_code_tag IS NULL AND NEW.operational_auth_code_kv IS NULL)
    OR
    (NEW.operational_auth_code_ct IS NOT NULL AND NEW.operational_auth_code_iv IS NOT NULL AND NEW.operational_auth_code_tag IS NOT NULL AND NEW.operational_auth_code_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid operational_auth_code bundle'; END IF;

  IF NOT (
    (NEW.device_pin_ct IS NULL AND NEW.device_pin_iv IS NULL AND NEW.device_pin_tag IS NULL AND NEW.device_pin_kv IS NULL)
    OR
    (NEW.device_pin_ct IS NOT NULL AND NEW.device_pin_iv IS NOT NULL AND NEW.device_pin_tag IS NOT NULL AND NEW.device_pin_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid device_pin bundle'; END IF;

  IF NOT (
    (NEW.opening_template_ct IS NULL AND NEW.opening_template_iv IS NULL AND NEW.opening_template_tag IS NULL AND NEW.opening_template_kv IS NULL)
    OR
    (NEW.opening_template_ct IS NOT NULL AND NEW.opening_template_iv IS NOT NULL AND NEW.opening_template_tag IS NOT NULL AND NEW.opening_template_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid opening_template bundle'; END IF;

  IF NOT (
    (NEW.sim_black_ct IS NULL AND NEW.sim_black_iv IS NULL AND NEW.sim_black_tag IS NULL AND NEW.sim_black_kv IS NULL)
    OR
    (NEW.sim_black_ct IS NOT NULL AND NEW.sim_black_iv IS NOT NULL AND NEW.sim_black_tag IS NOT NULL AND NEW.sim_black_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid sim_black bundle'; END IF;

  IF NOT (
    (NEW.sim_red_binding_id_ct IS NULL AND NEW.sim_red_binding_id_iv IS NULL AND NEW.sim_red_binding_id_tag IS NULL AND NEW.sim_red_binding_id_kv IS NULL)
    OR
    (NEW.sim_red_binding_id_ct IS NOT NULL AND NEW.sim_red_binding_id_iv IS NOT NULL AND NEW.sim_red_binding_id_tag IS NOT NULL AND NEW.sim_red_binding_id_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid sim_red_binding_id bundle'; END IF;

  IF NOT (
    (NEW.sim_red_copy_marking_short_ct IS NULL AND NEW.sim_red_copy_marking_short_iv IS NULL AND NEW.sim_red_copy_marking_short_tag IS NULL AND NEW.sim_red_copy_marking_short_kv IS NULL)
    OR
    (NEW.sim_red_copy_marking_short_ct IS NOT NULL AND NEW.sim_red_copy_marking_short_iv IS NOT NULL AND NEW.sim_red_copy_marking_short_tag IS NOT NULL AND NEW.sim_red_copy_marking_short_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid sim_red_copy_marking_short bundle'; END IF;

  IF NOT (
    (NEW.sim_red_copy_marking_long_ct IS NULL AND NEW.sim_red_copy_marking_long_iv IS NULL AND NEW.sim_red_copy_marking_long_tag IS NULL AND NEW.sim_red_copy_marking_long_kv IS NULL)
    OR
    (NEW.sim_red_copy_marking_long_ct IS NOT NULL AND NEW.sim_red_copy_marking_long_iv IS NOT NULL AND NEW.sim_red_copy_marking_long_tag IS NOT NULL AND NEW.sim_red_copy_marking_long_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid sim_red_copy_marking_long bundle'; END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tel100_voice_profile_upd` BEFORE UPDATE ON `tel100_voice_profile` FOR EACH ROW BEGIN
  DECLARE v_makat varchar(64);

  SELECT d.`makat` INTO v_makat
  FROM `core_device` d
  WHERE d.`id` = NEW.`core_device_id`
  LIMIT 1;

  IF v_makat IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TEL100_VOICE: core_device not found';
  END IF;

  IF v_makat <> '309418000' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TEL100_VOICE: invalid makat for voice profile';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tel100_voice_profile_bundle_upd` BEFORE UPDATE ON `tel100_voice_profile` FOR EACH ROW BEGIN
  -- same checks as insert
  IF NOT (
    (NEW.ptt_group_ct IS NULL AND NEW.ptt_group_iv IS NULL AND NEW.ptt_group_tag IS NULL AND NEW.ptt_group_kv IS NULL)
    OR
    (NEW.ptt_group_ct IS NOT NULL AND NEW.ptt_group_iv IS NOT NULL AND NEW.ptt_group_tag IS NOT NULL AND NEW.ptt_group_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid ptt_group bundle'; END IF;

  IF NOT (
    (NEW.hub_password_ct IS NULL AND NEW.hub_password_iv IS NULL AND NEW.hub_password_tag IS NULL AND NEW.hub_password_kv IS NULL)
    OR
    (NEW.hub_password_ct IS NOT NULL AND NEW.hub_password_iv IS NOT NULL AND NEW.hub_password_tag IS NOT NULL AND NEW.hub_password_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid hub_password bundle'; END IF;

  IF NOT (
    (NEW.operational_auth_code_ct IS NULL AND NEW.operational_auth_code_iv IS NULL AND NEW.operational_auth_code_tag IS NULL AND NEW.operational_auth_code_kv IS NULL)
    OR
    (NEW.operational_auth_code_ct IS NOT NULL AND NEW.operational_auth_code_iv IS NOT NULL AND NEW.operational_auth_code_tag IS NOT NULL AND NEW.operational_auth_code_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid operational_auth_code bundle'; END IF;

  IF NOT (
    (NEW.device_pin_ct IS NULL AND NEW.device_pin_iv IS NULL AND NEW.device_pin_tag IS NULL AND NEW.device_pin_kv IS NULL)
    OR
    (NEW.device_pin_ct IS NOT NULL AND NEW.device_pin_iv IS NOT NULL AND NEW.device_pin_tag IS NOT NULL AND NEW.device_pin_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid device_pin bundle'; END IF;

  IF NOT (
    (NEW.opening_template_ct IS NULL AND NEW.opening_template_iv IS NULL AND NEW.opening_template_tag IS NULL AND NEW.opening_template_kv IS NULL)
    OR
    (NEW.opening_template_ct IS NOT NULL AND NEW.opening_template_iv IS NOT NULL AND NEW.opening_template_tag IS NOT NULL AND NEW.opening_template_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid opening_template bundle'; END IF;

  IF NOT (
    (NEW.sim_black_ct IS NULL AND NEW.sim_black_iv IS NULL AND NEW.sim_black_tag IS NULL AND NEW.sim_black_kv IS NULL)
    OR
    (NEW.sim_black_ct IS NOT NULL AND NEW.sim_black_iv IS NOT NULL AND NEW.sim_black_tag IS NOT NULL AND NEW.sim_black_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid sim_black bundle'; END IF;

  IF NOT (
    (NEW.sim_red_binding_id_ct IS NULL AND NEW.sim_red_binding_id_iv IS NULL AND NEW.sim_red_binding_id_tag IS NULL AND NEW.sim_red_binding_id_kv IS NULL)
    OR
    (NEW.sim_red_binding_id_ct IS NOT NULL AND NEW.sim_red_binding_id_iv IS NOT NULL AND NEW.sim_red_binding_id_tag IS NOT NULL AND NEW.sim_red_binding_id_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid sim_red_binding_id bundle'; END IF;

  IF NOT (
    (NEW.sim_red_copy_marking_short_ct IS NULL AND NEW.sim_red_copy_marking_short_iv IS NULL AND NEW.sim_red_copy_marking_short_tag IS NULL AND NEW.sim_red_copy_marking_short_kv IS NULL)
    OR
    (NEW.sim_red_copy_marking_short_ct IS NOT NULL AND NEW.sim_red_copy_marking_short_iv IS NOT NULL AND NEW.sim_red_copy_marking_short_tag IS NOT NULL AND NEW.sim_red_copy_marking_short_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid sim_red_copy_marking_short bundle'; END IF;

  IF NOT (
    (NEW.sim_red_copy_marking_long_ct IS NULL AND NEW.sim_red_copy_marking_long_iv IS NULL AND NEW.sim_red_copy_marking_long_tag IS NULL AND NEW.sim_red_copy_marking_long_kv IS NULL)
    OR
    (NEW.sim_red_copy_marking_long_ct IS NOT NULL AND NEW.sim_red_copy_marking_long_iv IS NOT NULL AND NEW.sim_red_copy_marking_long_tag IS NOT NULL AND NEW.sim_red_copy_marking_long_kv IS NOT NULL)
  ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VOICE: invalid sim_red_copy_marking_long bundle'; END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `user_permission_overrides`
--

DROP TABLE IF EXISTS `user_permission_overrides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_permission_overrides` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission` varchar(100) NOT NULL,
  `effect` enum('ALLOW','DENY') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_permission` (`user_id`,`permission`),
  CONSTRAINT `fk_user_permission_overrides_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_permission_overrides`
--

LOCK TABLES `user_permission_overrides` WRITE;
/*!40000 ALTER TABLE `user_permission_overrides` DISABLE KEYS */;
INSERT INTO `user_permission_overrides` VALUES (1,5,'inventory.count.update','ALLOW','2026-01-03 14:04:15'),(2,5,'devices.update','ALLOW','2026-01-03 15:33:32');
/*!40000 ALTER TABLE `user_permission_overrides` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(200) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('BATTALION_SOLDIER','BATTALION_NCO','BATTALION_DEPUTY_OFFICER','BATTALION_CHIEF_OFFICER','DIVISION_DEPUTY_COMMANDER','DIVISION_COMMANDER','ADMIN') NOT NULL DEFAULT 'BATTALION_SOLDIER',
  `battalion_id` bigint unsigned DEFAULT NULL,
  `division_id` bigint unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_username` (`username`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_username_is_active` (`username`,`is_active`),
  KEY `idx_users_battalion_id` (`battalion_id`),
  KEY `idx_users_division_id` (`division_id`),
  CONSTRAINT `fk_users_battalions` FOREIGN KEY (`battalion_id`) REFERENCES `battalions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_users_divisions` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'◊ê◊ï◊®◊ê◊ú','◊ò◊ï◊ï◊ô◊ò◊ï','twitoorel1','twitoorel1@gmail.com','$2b$12$NBkqd3G/4lamLzsH6JcWselDD5YyUV87M3neOnAXag9EmsytAj0qm','ADMIN',NULL,1,1,NULL,'2025-12-16 15:44:53','2025-12-29 02:51:51'),(2,'◊¢◊ì◊ô','◊ì◊®◊¢◊ô','adi111','adi111@gmail.com','$2b$12$vZs1XtAXPCJ1mn8jgX5imOFAE6ztR4UXK3Sbij.VsscyIBNhTVnTm','DIVISION_COMMANDER',NULL,1,1,NULL,'2025-12-29 02:33:25','2025-12-29 02:51:33'),(3,'◊¢◊ô◊ì◊ï','◊í◊ï◊®◊ü','ido111','ido111@gmail.com','$2b$12$yjG.MxQOFkhI6Sy.qabdBeKC38jSffctqK4WaciyOdnvSRBn94RCG','DIVISION_DEPUTY_COMMANDER',NULL,1,1,NULL,'2025-12-29 02:38:42','2025-12-29 02:51:55'),(4,'◊©◊ï◊ü','◊©◊ï◊ü','shon111','shon111@gmail.com','$2b$12$yjG.MxQOFkhI6Sy.qabdBeKC38jSffctqK4WaciyOdnvSRBn94RCG','BATTALION_CHIEF_OFFICER',1,NULL,1,NULL,'2025-12-29 02:39:42','2025-12-29 02:52:32'),(5,'◊ê◊ô◊™◊ü','◊ë◊® ◊ú◊ë','eitan111','eitan111@gmail.com','$2b$12$yjG.MxQOFkhI6Sy.qabdBeKC38jSffctqK4WaciyOdnvSRBn94RCG','BATTALION_SOLDIER',1,NULL,1,NULL,'2025-12-29 02:40:17','2025-12-29 02:52:36'),(6,'◊ë◊ê◊°◊ú','◊ê◊°◊ê◊ì','basel','basel@gmail.com','$2b$12$B6cbYXb1LYaV6oiRxUbEhuLK726tzDEIuHcxeDHHoDhiEtzlmxLpC','BATTALION_NCO',1,NULL,1,NULL,'2026-01-03 16:00:59','2026-01-03 16:04:37');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'cipher_warehouse'
--

--
-- Dumping routines for database 'cipher_warehouse'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-24 13:07:14
