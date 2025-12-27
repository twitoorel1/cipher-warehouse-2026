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
  `serial` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `makat` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `current_unit_id` bigint unsigned DEFAULT NULL,
  `encryption_model_id` bigint unsigned DEFAULT NULL,
  `battery_life` date DEFAULT NULL,
  `lifecycle_status` enum('NEW','PENDING_CARD','ACTIVE','NOT_ELIGIBLE','TRANSFERRED','REMOVED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NEW',
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
  `makat` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `family_id` bigint unsigned NOT NULL,
  `carrier_code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `symbol_scope` enum('GLOBAL','PER_UNIT') COLLATE utf8mb4_unicode_ci NOT NULL,
  `symbol_global` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `period_code` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `unit_symbol` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=215 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` VALUES (191,1,'de7a1280972f04dedd76208fe09034864cc16892dc3544f495f34aac438b3796','2025-12-27 16:55:26','2026-01-26 16:55:26','2025-12-27 16:55:40','PostmanRuntime/7.51.0','::1'),(192,1,'17353801508d2ec7b868f286c5c684f96e1328b9911c8bd5d10c73dd2b5b68c1','2025-12-27 16:56:27','2026-01-26 16:56:27',NULL,'PostmanRuntime/7.51.0','::1'),(193,1,'1efa93e1e31e50b4c7916ca8e9826ed95c9693ee8bb35ce6bc70b19b7ee0e0fc','2025-12-27 16:58:01','2026-01-26 16:58:01',NULL,'PostmanRuntime/7.51.0','::1'),(194,1,'94ffc3c18afd5c0a0bc6f57555fa41a2fe2cc24f1ce24557420c5b425caa081a','2025-12-27 17:41:51','2026-01-26 17:41:51',NULL,'PostmanRuntime/7.51.0','::1'),(195,1,'bc12f9292f670cdf1652faff66cb01cfa7f4f759af37705ecf466b19b28375b9','2025-12-27 17:42:25','2026-01-26 17:42:25',NULL,'PostmanRuntime/7.51.0','::1'),(196,1,'1f4bc36a8bf7a1b55380939b05ece06363de042a85cb07aacefa6acf10a649b0','2025-12-27 17:48:19','2026-01-26 17:48:19',NULL,'PostmanRuntime/7.51.0','::1'),(197,1,'b9dfb36f6aacb0f2377929b14e866a9c604ac0c648844310d68e69bb21de25e1','2025-12-27 17:48:24','2026-01-26 17:48:24',NULL,'PostmanRuntime/7.51.0','::1'),(198,1,'70c49331970dba718e94cce7920aae9dc6dca6b3ab46b4630c5227ce44078746','2025-12-27 17:48:52','2026-01-26 17:48:52',NULL,'PostmanRuntime/7.51.0','::1'),(199,1,'7ce4117e43cf0eba9b9f3555b6626c2659b1a2d6f49f9d046b3f4306d644c387','2025-12-27 17:49:25','2026-01-26 17:49:25',NULL,'PostmanRuntime/7.51.0','::1'),(200,1,'2cab70efb905a2c18ebd871cdc620242b82610219e47b85e18375884cf8f964d','2025-12-27 17:51:17','2026-01-26 17:51:17',NULL,'PostmanRuntime/7.51.0','::1'),(201,1,'510d66755e940560f0730745f88a8ea98ff469d04384a33c4488cc3e05b684e9','2025-12-27 17:51:32','2026-01-26 17:51:32',NULL,'PostmanRuntime/7.51.0','::1'),(202,1,'d56014b8d2e49d4b95408b7068afb30f0461f9468e23830bc02d9990db37d200','2025-12-27 17:53:19','2026-01-26 17:53:19',NULL,'PostmanRuntime/7.51.0','::1'),(203,1,'4ca7677972d6c708dd63d2744ef65aa8634bc99e338f24097a7f97e60950db41','2025-12-27 17:56:51','2026-01-26 17:56:51',NULL,'PostmanRuntime/7.51.0','::1'),(204,1,'c83e4c5c1834cb2bdb900a155c470eca612bc391dac50de4132aa5e70bea6f5a','2025-12-27 17:58:21','2026-01-26 17:58:21',NULL,'PostmanRuntime/7.51.0','::1'),(205,1,'5af9739d995402f9131459e6b16724a192a5ba44dbb01cf340618d6eccefdcb3','2025-12-27 17:58:40','2026-01-26 17:58:40',NULL,'PostmanRuntime/7.51.0','::1'),(206,1,'2a026a4a38baa45085b18e22b762ac1c4dbe523d0905508579f157522b757d43','2025-12-27 17:59:55','2026-01-26 17:59:55',NULL,'PostmanRuntime/7.51.0','::1'),(207,1,'637f1fa8ccc57b1eb24df9a2f9d18e2743cfe850eab92319329cca5af614a0ab','2025-12-27 18:01:37','2026-01-26 18:01:37',NULL,'PostmanRuntime/7.51.0','::1'),(208,1,'f5b8b5ff45980d8e100c42e22b59c2c4935451210691ce886d20ae3bffc821d5','2025-12-27 18:01:52','2026-01-26 18:01:52',NULL,'PostmanRuntime/7.51.0','::1'),(209,1,'b697b0b3877e0d1184cde1cfd29295ab17f9222f1683a27f40ee83d863d4d4a5','2025-12-27 18:02:09','2026-01-26 18:02:09',NULL,'PostmanRuntime/7.51.0','::1'),(210,1,'4db8134486fe147acf605b0f2b66d21265745288634fde32ff86749abe687637','2025-12-27 18:02:11','2026-01-26 18:02:11',NULL,'PostmanRuntime/7.51.0','::1'),(211,1,'c80a5205420316295415a20560bfcaa43ddc24d3437fcf676c4ccf60c0758163','2025-12-27 18:02:24','2026-01-26 18:02:24',NULL,'PostmanRuntime/7.51.0','::1'),(212,1,'5a67f93a1b4fd00a1eabd40ee1d9708b1bc29e264561d1106693880686902279','2025-12-27 18:03:05','2026-01-26 18:03:05',NULL,'PostmanRuntime/7.51.0','::1'),(213,1,'9e73f21fca1223938952340efb5db0d0297cdeab622532c2e86d9a85b679e95f','2025-12-27 18:03:19','2026-01-26 18:03:19',NULL,'PostmanRuntime/7.51.0','::1'),(214,1,'e52da278e5f6b26deddda8e753f3ffdd1ed38e18f794a243ef46de0ce17fee1c','2025-12-27 18:04:00','2026-01-26 18:04:00',NULL,'PostmanRuntime/7.51.0','::1');
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
  `unit_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `storage_site` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_storage_units_storage_site` (`storage_site`),
  KEY `idx_storage_units_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storage_units`
--

LOCK TABLES `storage_units` WRITE;
/*!40000 ALTER TABLE `storage_units` DISABLE KEYS */;
INSERT INTO `storage_units` VALUES (1,'פלחיק571/חט828 - 0010/MG01','MG01',1,'2025-12-20 03:28:29','2025-12-20 03:28:29'),(2,'חטיבה828/גדוד450 - 0010/MG32','MG32',1,'2025-12-20 04:23:44','2025-12-20 04:23:44'),(3,'חטיבה828/גדוד17 - 0010/MG72','MG72',1,'2025-12-20 04:23:44','2025-12-20 04:23:44');
/*!40000 ALTER TABLE `storage_units` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Orel','Twito','twitoorel1','twitoorel1@example.com','$2b$12$NBkqd3G/4lamLzsH6JcWselDD5YyUV87M3neOnAXag9EmsytAj0qm','ADMIN',NULL,NULL,1,NULL,'2025-12-16 15:44:53','2025-12-27 18:03:15');
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

-- Dump completed on 2025-12-27 19:22:04
