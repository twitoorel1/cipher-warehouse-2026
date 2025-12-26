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
INSERT INTO `core_device` VALUES (1,'490031','310902748','מח 710',1,36,'NEW',NULL,'2025-12-20 03:28:29','2025-12-20 04:23:44'),(2,'490201','310902748','מח 710',1,36,'NEW',NULL,'2025-12-20 03:28:29','2025-12-20 04:23:44'),(3,'112101051','319658875','אול\"ר רישתי',1,38,'NEW',NULL,'2025-12-20 03:28:29','2025-12-20 04:23:44'),(4,'102301011','319658869','אול\"ר רישתי XCOVER',1,39,'NEW',NULL,'2025-12-20 03:28:29','2025-12-20 04:23:44'),(5,'550751','319653269','מגן מכלול',2,40,'NEW',NULL,'2025-12-20 03:28:29','2025-12-20 04:23:44'),(6,'353251','319667169','טל 88',3,37,'NEW',NULL,'2025-12-20 03:28:29','2025-12-20 06:09:38'),(7,'761954','310902683','מב\"ן',3,42,'NEW',NULL,'2025-12-20 03:28:29','2025-12-20 04:23:44'),(8,'886582','319652817','מחשב 19ה',2,41,'NEW',NULL,'2025-12-20 03:28:29','2025-12-20 06:09:38');
/*!40000 ALTER TABLE `core_device` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=167 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` VALUES (154,1,'78764fd6fd2e87abdbd80bde4ab9020dca9c3d89555746f8e69a0651f29c62d4','2025-12-20 03:28:26','2026-01-19 03:28:26',NULL,'PostmanRuntime/7.51.0','::1'),(155,1,'367beaa7d7a81fa59d5b561cbd54c9755d2238471ef85763d63a0928210528d1','2025-12-20 03:46:27','2026-01-19 03:46:27',NULL,'PostmanRuntime/7.51.0','::1'),(156,1,'dd473cb139b6f172c6853c3b434ae3fb8be227b185359841e7d284cbc7c9db59','2025-12-20 03:46:34','2026-01-19 03:46:34',NULL,'PostmanRuntime/7.51.0','::1'),(157,1,'33e534253d51eda955bc5be583fde04f58b67244233d4f614064c3e3ae2e19d0','2025-12-20 04:13:50','2026-01-19 04:13:50',NULL,'PostmanRuntime/7.51.0','::1'),(158,1,'d7aa0220c5eb30896b9e16f0353c36eb0275854c3bcb031295f90d17806bab5e','2025-12-20 04:23:26','2026-01-19 04:23:26',NULL,'PostmanRuntime/7.51.0','::1'),(159,1,'c1af4b75556fe28b2dea0eab96b53e5745f15e47f8e5714f6bd0411362d886a9','2025-12-20 04:45:34','2026-01-19 04:45:34',NULL,'PostmanRuntime/7.51.0','::1'),(160,1,'cdee0e76b31575bcd73eb0fd00f132410382965bd533444f178e30801d0221e6','2025-12-20 05:06:02','2026-01-19 05:06:02',NULL,'PostmanRuntime/7.51.0','::1'),(161,1,'fadf972bd7d5b8936e2ff7fd8dff7419c4b441678e0106e36a8e72b0f856bd1b','2025-12-20 05:08:03','2026-01-19 05:08:03',NULL,'PostmanRuntime/7.51.0','::1'),(162,1,'1fe0917df74c766961abd0b845d1e6b0f214ad0830a4bcf1b3324cf95771d091','2025-12-20 05:23:10','2026-01-19 05:23:10',NULL,'PostmanRuntime/7.51.0','::1'),(163,1,'b137d3e0132b7e53fe72e06b7598642b9429dbcd1cbf1c5cb3a95edf55393bf2','2025-12-20 05:38:18','2026-01-19 05:38:18',NULL,'PostmanRuntime/7.51.0','::1'),(164,1,'e82b5738e612b4eabd881a7b9eba62ce41fcd97f74a46ef0333b07669ed25a0f','2025-12-20 05:44:02','2026-01-19 05:44:02',NULL,'PostmanRuntime/7.51.0','::1'),(165,1,'2b4d22048bb9f27ed506b60e4fbd17cd36e74a1670f778accabc75195aca585a','2025-12-20 05:59:07','2026-01-19 05:59:07',NULL,'PostmanRuntime/7.51.0','::1'),(166,1,'56a159e96b43094ee314f831c0acf90d056e1f4c836b06619fe940d728ee64e7','2025-12-20 13:44:02','2026-01-19 13:44:02',NULL,'PostmanRuntime/7.51.0','::1');
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
  `role` enum('VIEWER','EDITOR','ADMIN') NOT NULL DEFAULT 'VIEWER',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_username` (`username`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_username_is_active` (`username`,`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Orel','Twito','twitoorel1','twitoorel1@example.com','$2b$12$NBkqd3G/4lamLzsH6JcWselDD5YyUV87M3neOnAXag9EmsytAj0qm','ADMIN',1,NULL,'2025-12-16 15:44:53','2025-12-17 17:58:33');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'cipher_warehouse'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-20 22:26:38
