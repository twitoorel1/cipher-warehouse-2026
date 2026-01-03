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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_device`
--

LOCK TABLES `core_device` WRITE;
/*!40000 ALTER TABLE `core_device` DISABLE KEYS */;
INSERT INTO `core_device` VALUES (1,'490031','310902748','מח 710',1,36,'2024-07-01','NEW',NULL,'2025-12-20 03:28:29','2025-12-26 21:17:41'),(2,'490201','310902748','מח 710',1,36,'2027-03-01','NEW',NULL,'2025-12-20 03:28:29','2025-12-26 21:17:41'),(3,'112101051','319658875','אול\"ר רישתי',3,38,'2026-04-01','ACTIVE',NULL,'2025-12-20 03:28:29','2025-12-27 17:42:26'),(4,'102301011','319658869','אול\"ר רישתי XCOVER',1,39,'2025-10-01','NEW',NULL,'2025-12-20 03:28:29','2025-12-26 20:16:57'),(5,'550751','319653269','מגן מכלול',2,40,'2026-10-01','NEW',NULL,'2025-12-20 03:28:29','2025-12-26 21:17:41'),(6,'353251','319667169','טל 88',3,37,'2027-10-01','NEW',NULL,'2025-12-20 03:28:29','2025-12-26 21:17:41'),(7,'761954','310902683','מב\"ן',3,42,'2028-10-01','NEW',NULL,'2025-12-20 03:28:29','2025-12-26 21:17:41'),(8,'886582','319652817','מחשב 19ה',2,41,'2025-02-01','NEW',NULL,'2025-12-20 03:28:29','2025-12-26 21:17:41');
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
) ENGINE=InnoDB AUTO_INCREMENT=319 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` VALUES (245,1,'8c66b360d0611842d3f44a2d4ba8bd7de4ee1adfe3bb764fd4b3218512592440','2026-01-03 13:38:22','2026-02-02 13:38:22',NULL,'PostmanRuntime/7.51.0','::1'),(246,1,'9bccc92fa3d397c42890d901142dc736153de63487370a495825d34a695509bd','2026-01-03 13:38:31','2026-02-02 13:38:31',NULL,'PostmanRuntime/7.51.0','::1'),(247,1,'4d1c7863f79196be298262b2f4fbf4e32faa24d668889f986846e49c6112995a','2026-01-03 13:41:47','2026-02-02 13:41:47',NULL,'PostmanRuntime/7.51.0','::1'),(248,1,'dca3833fef4542302bdabb5ffc4b5b51330f2e3a6a601f948d1240362d731f90','2026-01-03 13:42:25','2026-02-02 13:42:25',NULL,'PostmanRuntime/7.51.0','::1'),(249,1,'aaac1a31f83949b64603f7cf35b35bb39392439154bd085b434b92a5553b4745','2026-01-03 13:56:05','2026-02-02 13:56:05',NULL,'PostmanRuntime/7.51.0','::1'),(250,1,'f69a1fccdd9d00555facdfd6c7cd547f0f5cde953f4fe82fb236c010ba0812cc','2026-01-03 13:56:50','2026-02-02 13:56:50',NULL,'PostmanRuntime/7.51.0','::1'),(251,1,'36a324b839422c421bd4b9bde3f0af7b25d5a4d79d11db554114dee6748f42a6','2026-01-03 13:58:11','2026-02-02 13:58:11',NULL,'PostmanRuntime/7.51.0','::1'),(252,1,'2f6b4c0adcee141d623b4d9d60a86d53d78d6f7a8dd0a7e05fd0138fb0627bcd','2026-01-03 13:58:12','2026-02-02 13:58:12',NULL,'PostmanRuntime/7.51.0','::1'),(253,4,'4fd17e7c39bff348314ca18c57d0ab006cab4e41dbdd2985ba59d42857e2b130','2026-01-03 13:58:31','2026-02-02 13:58:31',NULL,'PostmanRuntime/7.51.0','::1'),(254,4,'7cce7ae70f9d9ca83429578664293fd550bdb6535c0a5159482781d7e732d4b7','2026-01-03 13:59:38','2026-02-02 13:59:38',NULL,'PostmanRuntime/7.51.0','::1'),(255,5,'191ba43e90dc30c239073ee8574e8b964ebb1a08ecff2fc61a2c388ab9d17c55','2026-01-03 14:00:40','2026-02-02 14:00:40',NULL,'PostmanRuntime/7.51.0','::1'),(256,4,'cb8f54303c2fac1a3a119d8512cc1aeec56afd4125412bbe8412501737e5a723','2026-01-03 14:02:19','2026-02-02 14:02:19',NULL,'PostmanRuntime/7.51.0','::1'),(257,4,'f3ee154adc48fdec92062b7939884b50cf25a1d009daa2bb86d920aca01d8e3b','2026-01-03 14:05:52','2026-02-02 14:05:52',NULL,'PostmanRuntime/7.51.0','::1'),(258,4,'4398478712c30b6a5f600a4d1b537980d5cacd925aaa57bafebc40f344365feb','2026-01-03 16:55:32','2026-02-02 16:55:32',NULL,'PostmanRuntime/7.51.0','::1'),(259,4,'b3996bccab1bd7103cb806e35f60d98d106f063be9f284171794cd7046a6cc73','2026-01-03 16:55:41','2026-02-02 16:55:41',NULL,'PostmanRuntime/7.51.0','::1'),(260,5,'6f8d5ef2166ffe18e98c7882dc0f35e2b8e68989afed550a3df89f1087591941','2026-01-03 16:55:49','2026-02-02 16:55:49',NULL,'PostmanRuntime/7.51.0','::1'),(261,5,'83882ad5712e6d4d8cb7e7790ce0d8e987ef1aeb06362caa81b9d23c8700bf0a','2026-01-03 16:57:03','2026-02-02 16:57:03',NULL,'PostmanRuntime/7.51.0','::1'),(262,5,'ac0dd744fa0370c5c6802cad379645a163b114e04857d3abac62d686a077ae41','2026-01-03 16:59:40','2026-02-02 16:59:40',NULL,'PostmanRuntime/7.51.0','::1'),(263,5,'cd86de0655eb6db6ef84805776d4956dbc08d229edc05b04073e8fc995ae59db','2026-01-03 17:03:56','2026-02-02 17:03:56',NULL,'PostmanRuntime/7.51.0','::1'),(264,5,'82940ddda9754deddc76f0fe9e0084bc004580f29160f395d0023e39f4e9b1c2','2026-01-03 17:04:39','2026-02-02 17:04:39',NULL,'PostmanRuntime/7.51.0','::1'),(265,5,'c5d465d359f4950d5e50f5f66f64c08a139b305a9febc663c4d3318cfc68335d','2026-01-03 17:05:00','2026-02-02 17:05:00',NULL,'PostmanRuntime/7.51.0','::1'),(266,5,'d93c23666e979750cd55c9eddc10018d860c7fa6b5256ad2e4af0288c8ec4d34','2026-01-03 17:05:01','2026-02-02 17:05:01',NULL,'PostmanRuntime/7.51.0','::1'),(267,5,'3e134ebed02fafa36c55f60b86733eda4509e725f3fdd24ba8af8594301f5375','2026-01-03 17:15:38','2026-02-02 17:15:38',NULL,'PostmanRuntime/7.51.0','::1'),(268,4,'96de09b30a7182b3e4faaf47de490b776908c923fd3ce1da081821872ac656ba','2026-01-03 17:15:52','2026-02-02 17:15:52',NULL,'PostmanRuntime/7.51.0','::1'),(269,1,'fa3158b6812d171162885cb2797f8ca42231d0fce70288e3a3ed2007c113d1ca','2026-01-03 17:16:16','2026-02-02 17:16:16',NULL,'PostmanRuntime/7.51.0','::1'),(270,1,'47f2ea868129743793695c7d2c7a8c9880e6e80dc8d44c4b38619f3aa3416311','2026-01-03 17:16:17','2026-02-02 17:16:17',NULL,'PostmanRuntime/7.51.0','::1'),(271,5,'2f2c6625f0911fa21a2d80626cbd14796a8dd1550eca7f3d15066795f68d7c81','2026-01-03 17:16:42','2026-02-02 17:16:42',NULL,'PostmanRuntime/7.51.0','::1'),(272,4,'ce53069e9921dcd052eb065bcb56cde7a6ac1d72cfd0075572ba273a861a3b13','2026-01-03 17:17:56','2026-02-02 17:17:56',NULL,'PostmanRuntime/7.51.0','::1'),(273,1,'c68023e55668f56199ed28782f4d9f6833f088666fdc02662d17e0795cb7c520','2026-01-03 17:18:05','2026-02-02 17:18:05',NULL,'PostmanRuntime/7.51.0','::1'),(274,5,'e2555e241f5b40772f0fcd7bdab90619c4863b4bd23e7eb6b0234b9d44deb5c1','2026-01-03 17:18:22','2026-02-02 17:18:22',NULL,'PostmanRuntime/7.51.0','::1'),(275,5,'5f1d8e5c5ab03daaca296df33c08ee9ac20fbe8e1a8fb83331fb9f9b9903f4b6','2026-01-03 17:33:13','2026-02-02 17:33:13',NULL,'PostmanRuntime/7.51.0','::1'),(276,5,'6e0b86d2b2ece56041d0258fb587b7fb6a1fbf2a1ccbc09653a9ae56d5b7c795','2026-01-03 17:34:07','2026-02-02 17:34:07',NULL,'PostmanRuntime/7.51.0','::1'),(277,5,'c3e22f391fadf3bd97a4d54e574af1fcbd12dd561b8bb365fb847e3ee1f0df29','2026-01-03 17:36:48','2026-02-02 17:36:48',NULL,'PostmanRuntime/7.51.0','::1'),(278,5,'12c4f9216c60d22f629016e7c516eecbfe84a0bdd8f32e74ede6cf46da424459','2026-01-03 17:52:38','2026-02-02 17:52:38',NULL,'PostmanRuntime/7.51.0','::1'),(279,5,'cbc7c389d7e486201bb1bd4330df86449b24528230d5b9607c5dacdfe7e96619','2026-01-03 17:52:47','2026-02-02 17:52:47',NULL,'PostmanRuntime/7.51.0','::1'),(280,6,'c4601b2c4a07a7b88bd17e187656327a76fe3f8092ff94b8dc6b5bc90902245a','2026-01-03 18:04:43','2026-02-02 18:04:43',NULL,'PostmanRuntime/7.51.0','::1'),(281,6,'7becca551ba25fa7b37fe29f53c1a6317c3c22d59a68e2d02234548af55285a5','2026-01-03 18:05:05','2026-02-02 18:05:05',NULL,'PostmanRuntime/7.51.0','::1'),(282,6,'b05422e485aee3d8bb100ea404bf05417f7aa264c9e6597e1242d28cdde2e1bc','2026-01-03 18:06:44','2026-02-02 18:06:44',NULL,'PostmanRuntime/7.51.0','::1'),(283,5,'1c7000e9e96e2ebf7108d7bbd02c72661722a629520cfaefeb87ce2d3e349762','2026-01-03 18:07:55','2026-02-02 18:07:55',NULL,'PostmanRuntime/7.51.0','::1'),(284,5,'72efb09bd37b120b345fa2feb22eb8584b88e9e7f0bcc3a7389d85b5b258bd1e','2026-01-03 18:10:07','2026-02-02 18:10:07',NULL,'PostmanRuntime/7.51.0','::1'),(285,5,'bb38aedd22981ba8920b20713c69bee4ce6b662adbd5250fed5b8a5e681701eb','2026-01-03 18:11:48','2026-02-02 18:11:48',NULL,'PostmanRuntime/7.51.0','::1'),(286,5,'57bdea0d498d5507003b6fd20409ac1642a2a30be7df773b406a4f488b06aa1e','2026-01-03 18:12:15','2026-02-02 18:12:15',NULL,'PostmanRuntime/7.51.0','::1'),(287,4,'7bfaf1628f1a86c6c47212b228f87a5842babd3dd37e83c0e4b25a92282b6863','2026-01-03 18:12:26','2026-02-02 18:12:26',NULL,'PostmanRuntime/7.51.0','::1'),(288,4,'0383be22e3cbb86d9fba6c0516119824d07413a0c4df0ad6441a908f18a3001a','2026-01-03 18:14:19','2026-02-02 18:14:19',NULL,'PostmanRuntime/7.51.0','::1'),(289,5,'0cd8eb0e3c88c2809e153e198f9cf65a50944d76d80027a9f1f1ba961289cbff','2026-01-03 18:14:26','2026-02-02 18:14:26',NULL,'PostmanRuntime/7.51.0','::1'),(290,5,'1bb6499af6351f30dde5402c2acba610f44d9eca29f8970bf8099c2540b21c2b','2026-01-03 18:14:38','2026-02-02 18:14:38',NULL,'PostmanRuntime/7.51.0','::1'),(291,5,'574f1149247f64b4e70ee446806fdf2e3290496e0125d8ea8d374bf9c15c2261','2026-01-03 18:15:27','2026-02-02 18:15:27',NULL,'PostmanRuntime/7.51.0','::1'),(292,6,'c61eb8e83ad3162e1a3b6c51054948832773d74aecd860aa0776a898c0d31c34','2026-01-03 18:15:42','2026-02-02 18:15:42',NULL,'PostmanRuntime/7.51.0','::1'),(293,6,'93f9767191b0db2cd0d289095e55b977139c9c701639a3e990ac96de273926be','2026-01-03 18:15:47','2026-02-02 18:15:47',NULL,'PostmanRuntime/7.51.0','::1'),(294,6,'e22a3b1f03bcfd41232c5e62928e1a87f07ad923ed08a9ac3e9251a147d0b81e','2026-01-03 18:16:09','2026-02-02 18:16:09',NULL,'PostmanRuntime/7.51.0','::1'),(295,6,'fe013e6bee80ff427d7a3cda9d1a9d85b65d631d614f64d6783c6327585c18d1','2026-01-03 18:42:25','2026-02-02 18:42:25',NULL,'PostmanRuntime/7.51.0','::1'),(296,6,'4554fc61ff6b33a588909421ee0b76c72b337965b9bd084d136e49c385bc1749','2026-01-03 18:42:40','2026-02-02 18:42:40',NULL,'PostmanRuntime/7.51.0','::1'),(297,6,'3eeb79fa426a6309ec708cabe50c16a7787c6d3f8c63e84f049ce9f2c0a9eb40','2026-01-03 18:43:05','2026-02-02 18:43:05',NULL,'PostmanRuntime/7.51.0','::1'),(298,6,'53581affa677e9f93b6f79733cd5a9d675b09206e94d0b57c630643acb36f60f','2026-01-03 18:44:16','2026-02-02 18:44:16',NULL,'PostmanRuntime/7.51.0','::1'),(299,6,'41e3fea74c38ebd34fcf2e2ceffb1b47063c3683333a3037024b048f920b2c7c','2026-01-03 18:46:26','2026-02-02 18:46:26',NULL,'PostmanRuntime/7.51.0','::1'),(300,6,'4b0b3b4a5f6e52d542135b0dced67e05263225c54ef46a199d3789c951e831fc','2026-01-03 18:46:40','2026-02-02 18:46:40',NULL,'PostmanRuntime/7.51.0','::1'),(301,6,'3219bc14b4248d7bf2c371b735031a5839c9442ad3e1916b28dccc58647ba980','2026-01-03 19:05:39','2026-02-02 19:05:39',NULL,'PostmanRuntime/7.51.0','::1'),(302,6,'02077a95cf1a1e287ad24c66766a5a88243c7e3e0f3fb38dd9fd12ea601d9263','2026-01-03 19:05:54','2026-02-02 19:05:54',NULL,'PostmanRuntime/7.51.0','::1'),(303,4,'0fccb7ae57d88a7974f6f11ef5eb61ba23248b531ea9c3f5d3d6f126f7b29079','2026-01-03 19:06:26','2026-02-02 19:06:26',NULL,'PostmanRuntime/7.51.0','::1'),(304,4,'a774fc4cb00a22b02d12cfce56d98c8daf011e71408ef16c170580fcd76b2f69','2026-01-03 19:07:21','2026-02-02 19:07:21',NULL,'PostmanRuntime/7.51.0','::1'),(305,1,'c67965a574dcefa29570686d17e2c9b9d114855396bdb20f9d3cd6e409405d9a','2026-01-03 19:07:30','2026-02-02 19:07:30',NULL,'PostmanRuntime/7.51.0','::1'),(306,5,'e663b50abde7cf8c3ebc598a642b92d187989cd79188a01815e191260d028e37','2026-01-03 19:07:39','2026-02-02 19:07:39',NULL,'PostmanRuntime/7.51.0','::1'),(307,6,'a49ed01ceff382029c546d4c768db7934df601f78b97753829692bf7fc5c0f0f','2026-01-03 19:07:59','2026-02-02 19:07:59',NULL,'PostmanRuntime/7.51.0','::1'),(308,6,'25ee035e23292d47f8c3064003038481a57208b0a45aa6734690f85ad8e2d0a5','2026-01-03 19:09:02','2026-02-02 19:09:02',NULL,'PostmanRuntime/7.51.0','::1'),(309,5,'fa583dfb66114549b6e1c777793e98b39927929f598d167d8130a253dde4cb68','2026-01-03 19:09:11','2026-02-02 19:09:11',NULL,'PostmanRuntime/7.51.0','::1'),(310,5,'de5b66d647865210a33fddcc8be46f13e582645b23403aadb24d4db149bf6ba2','2026-01-03 19:24:01','2026-02-02 19:24:01',NULL,'PostmanRuntime/7.51.0','::1'),(311,6,'5ed782fb11bfa1e9d52b9838528283a2f63087b89162b19f5218a9485a4d662a','2026-01-03 19:24:11','2026-02-02 19:24:11',NULL,'PostmanRuntime/7.51.0','::1'),(312,5,'4280ebc5ba028a6990345c3114c57e2845a3b85d33236f944a0d124745fc997f','2026-01-03 19:24:35','2026-02-02 19:24:35',NULL,'PostmanRuntime/7.51.0','::1'),(313,5,'240599601164c3a447f7a5bf9e417dc03b341a1eddea56cb7ec3cddd7003f2d9','2026-01-04 00:35:02','2026-02-03 00:35:02',NULL,'PostmanRuntime/7.51.0','::1'),(314,5,'34d80b89eb5c460828d40948ac4a215206e77dbacc0fc9225ab502089b6499ef','2026-01-04 00:35:03','2026-02-03 00:35:03',NULL,'PostmanRuntime/7.51.0','::1'),(315,5,'d6226695a86c2e99e054b73cb2b0b2b18287c42a8a0f59ed19995213df929621','2026-01-04 00:42:24','2026-02-03 00:42:24',NULL,'PostmanRuntime/7.51.0','::1'),(316,5,'cd78e09933de74220b7319e31d36f375ffc46c31698d78034778d32c87ab9737','2026-01-04 00:43:09','2026-02-03 00:43:09',NULL,'PostmanRuntime/7.51.0','::1'),(317,5,'09a1954642e0ba3f5baa795e26b77c2e144ad593374381e18d5eb776b50d3f68','2026-01-04 00:43:11','2026-02-03 00:43:11',NULL,'PostmanRuntime/7.51.0','::1'),(318,5,'f6ab183e67f4fc4fed2b75f8b5b3bd03e52f059b5e005fdaae7a8a24804ac272','2026-01-04 00:43:12','2026-02-03 00:43:12',NULL,'PostmanRuntime/7.51.0','::1');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storage_units`
--

LOCK TABLES `storage_units` WRITE;
/*!40000 ALTER TABLE `storage_units` DISABLE KEYS */;
INSERT INTO `storage_units` VALUES (1,'פלחיק571/חט828 - 0010/MG01','MG01',NULL,1,1,'2025-12-20 03:28:29','2026-01-03 11:51:07'),(2,'חטיבה828/גדוד450 - 0010/MG32','MG32',2,NULL,1,'2025-12-20 04:23:44','2026-01-03 11:53:17'),(3,'חטיבה828/גדוד17 - 0010/MG72','MG72',1,NULL,1,'2025-12-20 04:23:44','2026-01-03 11:53:33');
/*!40000 ALTER TABLE `storage_units` ENABLE KEYS */;
UNLOCK TABLES;

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

-- Dump completed on 2026-01-04  0:46:00
