CREATE DATABASE  IF NOT EXISTS `cipher_warehouse` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `cipher_warehouse`;
-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: cipher_warehouse
-- ------------------------------------------------------
-- Server version	8.0.37

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
INSERT INTO `battalions` VALUES (1,1,'BTN-17','גדוד 17','2025-12-27 18:18:42','2025-12-27 18:18:42'),(2,1,'BTN-450','גדוד 450','2025-12-27 18:18:42','2025-12-27 18:18:42'),(3,1,'BTN-906','גדוד 906','2025-12-27 18:18:42','2025-12-27 18:18:42');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_device`
--

LOCK TABLES `core_device` WRITE;
/*!40000 ALTER TABLE `core_device` DISABLE KEYS */;
INSERT INTO `core_device` VALUES (18,'490032','310902748','מח 710',5,36,'2026-05-01','NEW',NULL,'2026-01-12 00:20:37','2026-01-12 01:35:17'),(19,'490201','310902748','מח 710',1,36,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(20,'112101051','319658875','אול\"ר רישתי',3,38,'2027-05-01','NEW',NULL,'2026-01-12 00:20:37','2026-01-12 01:25:18'),(21,'102301011','319658869','אול\"ר רישתי XCOVER',1,39,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(22,'550751','319653269','מגן מכלול',2,40,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(23,'353251','319667169','טל 88',3,37,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(24,'761954','310902683','מב\"ן',3,42,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37'),(25,'886582','319652817','מחשב 19ה',2,41,NULL,'NEW',NULL,'2026-01-12 00:20:37','2026-01-12 00:20:37');
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
INSERT INTO `divisions` VALUES (1,'DIV-1','חטיבה 828','2025-12-27 18:18:42','2025-12-27 18:18:42');
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
INSERT INTO `encryption_device_model` VALUES (36,'310902748','מח 710',1,'751',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(37,'319667169','טל 88',2,'751',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(38,'319658875','אול\"ר רישתי',5,'ללא',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(39,'319658869','אול\"ר רישתי XCOVER',5,'ללא',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(40,'319653269','מגן מכלול',1,'751',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(41,'319652817','מחשב 19ה',3,'656',1,'2025-12-20 02:19:24','2025-12-20 02:19:24'),(42,'310902683','מב\"ן',3,'173',1,'2025-12-20 02:19:24','2025-12-20 02:19:24');
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
INSERT INTO `encryption_family` VALUES (1,'RADIO_ROMACH','רדיו (כולל רומח)',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(2,'RADIO_NO_ROMACH','רדיו (ללא רומח)',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(3,'ZIAD','צי\'ד',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(4,'MOBILITY','מוביליטי',1,1,'2025-12-19 23:38:48','2025-12-19 23:38:48'),(5,'OTHER','אחר',0,1,'2025-12-19 23:38:48','2025-12-19 23:38:48');
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
) ENGINE=InnoDB AUTO_INCREMENT=365 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` VALUES (318,5,'f6ab183e67f4fc4fed2b75f8b5b3bd03e52f059b5e005fdaae7a8a24804ac272','2026-01-04 00:43:12','2026-02-03 00:43:12',NULL,'PostmanRuntime/7.51.0','::1'),(320,5,'8f2a892fa22936065f8f267da34c77f62adf47bf9ba287759e073a088c3ccc9a','2026-01-08 21:52:18','2026-02-07 21:52:18',NULL,'PostmanRuntime/7.51.0','::1'),(321,6,'4c00493c437df7f82db51bfc75677d7bd0f7efae7f21447e8d6084d0a793238a','2026-01-08 21:52:38','2026-02-07 21:52:38',NULL,'PostmanRuntime/7.51.0','::1'),(322,6,'aa8fea23d63ff25cb5df2797e225cacb24d10ab11b96a2556edb55f1582742f5','2026-01-08 22:48:25','2026-02-07 22:48:25',NULL,'PostmanRuntime/7.51.0','::1'),(323,6,'db7a123f40792751d34ed19ea061061af48abebae080076a521623ce8ecf1ce1','2026-01-08 23:01:10','2026-02-07 23:01:10',NULL,'PostmanRuntime/7.51.0','::1'),(330,2,'e4caf8956c87c2c68efa5428291ff8a99c4c0439f13659372346212afcf66409','2026-01-08 23:43:25','2026-02-07 23:43:25',NULL,'PostmanRuntime/7.51.0','::1'),(331,6,'8aed66f19b9627f38dd579ba3e821a6f774be528dacdccf7fdeb6d4899fa7a7b','2026-01-08 23:44:28','2026-02-07 23:44:28',NULL,'PostmanRuntime/7.51.0','::1'),(332,2,'63922f46fedb066246bcde06a54466b467682270285dbb1298bae29fa02402cc','2026-01-08 23:44:49','2026-02-07 23:44:49',NULL,'PostmanRuntime/7.51.0','::1'),(333,4,'fe1ae302765c4920e53b64e1a2d3f7e258b85f47aab23c237a6de1695b7b73e6','2026-01-09 00:11:58','2026-02-08 00:11:58',NULL,'PostmanRuntime/7.51.0','::1'),(337,4,'12ab31a726eef42d93630df09543f4e9406cbd9059d54ee95a23a7497f6cd5c1','2026-01-09 01:02:27','2026-02-08 01:02:27',NULL,'PostmanRuntime/7.51.0','::1'),(338,4,'bc27a8110f2e726e160906e2fe806b94541627a1db42c5e2becb3d006f9605d0','2026-01-09 01:02:29','2026-02-08 01:02:29',NULL,'PostmanRuntime/7.51.0','::1'),(339,4,'59a370f301889dc60e1e0007ccde94c2d385b615ca03a79063bcfda8c527a1e3','2026-01-09 01:14:30','2026-02-08 01:14:30',NULL,'PostmanRuntime/7.51.0','::1'),(340,4,'0ca442155830ca2cbbd36b2fc66c04f09907403edf037f539e84816fff2d0f04','2026-01-09 01:14:31','2026-02-08 01:14:31',NULL,'PostmanRuntime/7.51.0','::1'),(341,2,'5044d3b348bb16d538ef1e31a0114a0d9f980235422224a911ff00e42788d8f1','2026-01-09 01:14:46','2026-02-08 01:14:46',NULL,'PostmanRuntime/7.51.0','::1'),(343,2,'afe8d34f1477cb8beca8a5673a9c55f42d6001dea36b0f4906de2ac2d0c82a03','2026-01-09 01:15:28','2026-02-08 01:15:28',NULL,'PostmanRuntime/7.51.0','::1'),(344,2,'465404e653e1f5ab31b8df6250536c79171b2e07306bd22f304c3328c1e1182d','2026-01-09 01:15:36','2026-02-08 01:15:36',NULL,'PostmanRuntime/7.51.0','::1'),(345,5,'0450d0810cf681900677664d91c0a27539fb8855f73ab378ccfa1b575cbab23d','2026-01-11 19:01:28','2026-02-10 19:01:28',NULL,'PostmanRuntime/7.51.0','::1'),(357,1,'f5d2a58246f66b0af30760041f63567f43f690a8f7a7faa0d52380b55164a803','2026-01-12 00:20:36','2026-02-11 00:20:36',NULL,'PostmanRuntime/7.51.0','::1'),(358,1,'8205c6a8126dbad90097b8450540c8d9e58a13a177f0f6797958b2efd3d181ae','2026-01-12 00:33:13','2026-02-11 00:33:13',NULL,'PostmanRuntime/7.51.0','::1'),(359,1,'79bb7ef55dd035bb14781c4409f6c7df2f8b9a2fcdc6070ff74b9c6c432c5af1','2026-01-12 01:19:22','2026-02-11 01:19:22',NULL,'PostmanRuntime/7.51.0','::1'),(360,1,'366237fa3636fe9b54d61b520fd2325deef1ef3e38090470b509b96a75e4c5e2','2026-01-12 01:22:12','2026-02-11 01:22:12',NULL,'PostmanRuntime/7.51.0','::1'),(361,5,'57a141deb261fdfd81fedc8f89ddd4ee8a85c5243d9544f808eb6a609a99fb58','2026-01-12 01:24:48','2026-02-11 01:24:48',NULL,'PostmanRuntime/7.51.0','::1'),(362,5,'9320b4fde41ef1d6023b0ff2d7191b4add823627bdb1fcd92562e1a9d7d18f28','2026-01-12 01:28:47','2026-02-11 01:28:47',NULL,'PostmanRuntime/7.51.0','::1'),(363,1,'4e17928efc4e6a9caa6b04a8c2086c3b55d1d6eb49942feed12ea8f189d1fbdd','2026-01-12 01:29:00','2026-02-11 01:29:00',NULL,'PostmanRuntime/7.51.0','::1'),(364,6,'a776098e64f73abd94d853c0b5c5aae2f30840ba670f91fab25a6d589c597ce6','2026-01-12 01:37:47','2026-02-11 01:37:47',NULL,'PostmanRuntime/7.51.0','::1');
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
INSERT INTO `storage_units` VALUES (1,'פלחיק571/חט828','MG01',NULL,1,1,'2025-12-20 03:28:29','2026-01-12 00:19:31'),(2,'חטיבה828/גדוד450','MG32',2,1,1,'2025-12-20 04:23:44','2026-01-12 01:33:55'),(3,'חטיבה828/גדוד17','MG72',1,1,1,'2025-12-20 04:23:44','2026-01-12 01:33:55'),(5,'גד 828/906/קשר','MG53',3,1,1,'2026-01-12 01:33:22','2026-01-12 01:34:30');
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
  `user_type` enum('PERMANENT','RESERVE','OTHER') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `personal_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `job_title` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ptt_status` enum('OK','NOT_OK','UNKNOWN') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UNKNOWN',
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
INSERT INTO `users` VALUES (1,'אוראל','טוויטו','twitoorel1','twitoorel1@gmail.com','$2b$12$NBkqd3G/4lamLzsH6JcWselDD5YyUV87M3neOnAXag9EmsytAj0qm','ADMIN',NULL,1,1,NULL,'2025-12-16 15:44:53','2025-12-29 02:51:51'),(2,'עדי','דרעי','adi111','adi111@gmail.com','$2b$12$vZs1XtAXPCJ1mn8jgX5imOFAE6ztR4UXK3Sbij.VsscyIBNhTVnTm','DIVISION_COMMANDER',NULL,1,1,NULL,'2025-12-29 02:33:25','2025-12-29 02:51:33'),(3,'עידו','גורן','ido111','ido111@gmail.com','$2b$12$yjG.MxQOFkhI6Sy.qabdBeKC38jSffctqK4WaciyOdnvSRBn94RCG','DIVISION_DEPUTY_COMMANDER',NULL,1,1,NULL,'2025-12-29 02:38:42','2025-12-29 02:51:55'),(4,'שון','שון','shon111','shon111@gmail.com','$2b$12$yjG.MxQOFkhI6Sy.qabdBeKC38jSffctqK4WaciyOdnvSRBn94RCG','BATTALION_CHIEF_OFFICER',1,NULL,1,NULL,'2025-12-29 02:39:42','2025-12-29 02:52:32'),(5,'איתן','בר לב','eitan111','eitan111@gmail.com','$2b$12$yjG.MxQOFkhI6Sy.qabdBeKC38jSffctqK4WaciyOdnvSRBn94RCG','BATTALION_SOLDIER',1,NULL,1,NULL,'2025-12-29 02:40:17','2025-12-29 02:52:36'),(6,'באסל','אסאד','basel','basel@gmail.com','$2b$12$B6cbYXb1LYaV6oiRxUbEhuLK726tzDEIuHcxeDHHoDhiEtzlmxLpC','BATTALION_NCO',1,NULL,1,NULL,'2026-01-03 16:00:59','2026-01-03 16:04:37');
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

-- Dump completed on 2026-01-12  3:50:44
