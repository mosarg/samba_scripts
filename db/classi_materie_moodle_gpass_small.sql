-- MySQL dump 10.13  Distrib 5.5.32, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: gestione_scuola
-- ------------------------------------------------------
-- Server version	5.5.32-0ubuntu0.13.04.1

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
-- Current Database: `gestione_scuola`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `gestione_scuola` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `gestione_scuola`;

--
-- Table structure for table `account_account`
--

DROP TABLE IF EXISTS `account_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_account` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `accountId` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(30) NOT NULL,
  `active` tinyint(1) NOT NULL,
  `backendUidNumber` int(11) NOT NULL,
  `userId_id` int(11) NOT NULL,
  `backendId_id` int(11) NOT NULL,
  PRIMARY KEY (`accountId`),
  UNIQUE KEY `userId_id` (`userId_id`,`backendId_id`),
  KEY `account_account_c12a3c06` (`userId_id`),
  KEY `account_account_5a2d15c2` (`backendId_id`),
  CONSTRAINT `backendId_id_refs_backendId_dd8512d1` FOREIGN KEY (`backendId_id`) REFERENCES `backend_backend` (`backendId`),
  CONSTRAINT `userId_id_refs_userId_2022461b` FOREIGN KEY (`userId_id`) REFERENCES `sysuser_sysuser` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_account`
--

LOCK TABLES `account_account` WRITE;
/*!40000 ALTER TABLE `account_account` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_assignedpolicy`
--

DROP TABLE IF EXISTS `account_assignedpolicy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_assignedpolicy` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `assignedPolicyId` int(11) NOT NULL AUTO_INCREMENT,
  `accountId_id` int(11) NOT NULL,
  `policyId_id` int(11) NOT NULL,
  PRIMARY KEY (`assignedPolicyId`),
  UNIQUE KEY `accountId_id` (`accountId_id`,`policyId_id`),
  KEY `account_assignedpolicy_2a58654f` (`accountId_id`),
  KEY `account_assignedpolicy_9cb6c456` (`policyId_id`),
  CONSTRAINT `accountId_id_refs_accountId_4b99913f` FOREIGN KEY (`accountId_id`) REFERENCES `account_account` (`accountId`),
  CONSTRAINT `policyId_id_refs_policyId_689e84d1` FOREIGN KEY (`policyId_id`) REFERENCES `account_policy` (`policyId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_assignedpolicy`
--

LOCK TABLES `account_assignedpolicy` WRITE;
/*!40000 ALTER TABLE `account_assignedpolicy` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_assignedpolicy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_policy`
--

DROP TABLE IF EXISTS `account_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_policy` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `policyId` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(300) NOT NULL,
  `backendId_id` int(11) NOT NULL,
  PRIMARY KEY (`policyId`),
  UNIQUE KEY `name` (`name`,`backendId_id`),
  KEY `account_policy_5a2d15c2` (`backendId_id`),
  CONSTRAINT `backendId_id_refs_backendId_071745fa` FOREIGN KEY (`backendId_id`) REFERENCES `backend_backend` (`backendId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_policy`
--

LOCK TABLES `account_policy` WRITE;
/*!40000 ALTER TABLE `account_policy` DISABLE KEYS */;
INSERT INTO `account_policy` VALUES ('2013-07-28 21:26:29','2013-07-28 21:26:29',1,'baseStudent','Policy base studenti',1),('2013-07-28 21:29:54','2013-07-28 21:29:54',2,'baseTeacher','base insegnanti',1),('2013-07-28 21:30:59','2013-08-07 08:52:32',3,'baseAta','Base ata',1),('2013-08-04 12:26:35','2013-08-04 12:26:35',4,'moodleStudenti','Policy base moodle studenti',2),('2013-08-04 12:27:03','2013-08-04 12:27:03',5,'moodleDocenti','base docenti per moodle',2);
/*!40000 ALTER TABLE `account_policy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `allocation_allocation`
--

DROP TABLE IF EXISTS `allocation_allocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allocation_allocation` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `allocationId` int(11) NOT NULL AUTO_INCREMENT,
  `yearId_id` int(11) NOT NULL,
  `userId_id` int(11) NOT NULL,
  `roleId_id` int(11) NOT NULL,
  `ou` varchar(50) NOT NULL,
  PRIMARY KEY (`allocationId`),
  UNIQUE KEY `yearId_id` (`yearId_id`,`userId_id`),
  KEY `allocation_allocation_03d85c48` (`yearId_id`),
  KEY `allocation_allocation_c12a3c06` (`userId_id`),
  KEY `allocation_allocation_349376d4` (`roleId_id`),
  CONSTRAINT `userId_id_refs_userId_18317730` FOREIGN KEY (`userId_id`) REFERENCES `sysuser_sysuser` (`userId`),
  CONSTRAINT `roleId_id_refs_roleId_e7db9ddc` FOREIGN KEY (`roleId_id`) REFERENCES `allocation_role` (`roleId`),
  CONSTRAINT `yearId_id_refs_schoolYearId_02dce3d2` FOREIGN KEY (`yearId_id`) REFERENCES `allocation_schoolyear` (`schoolYearId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allocation_allocation`
--

LOCK TABLES `allocation_allocation` WRITE;
/*!40000 ALTER TABLE `allocation_allocation` DISABLE KEYS */;
/*!40000 ALTER TABLE `allocation_allocation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `allocation_didacticalallocation`
--

DROP TABLE IF EXISTS `allocation_didacticalallocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allocation_didacticalallocation` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `didacticalAllocationId` int(11) NOT NULL AUTO_INCREMENT,
  `allocationId_id` int(11) NOT NULL,
  `classId_id` int(11) NOT NULL,
  `subjectId_id` int(11) NOT NULL,
  PRIMARY KEY (`didacticalAllocationId`),
  UNIQUE KEY `classId_id` (`classId_id`,`subjectId_id`,`allocationId_id`),
  KEY `allocation_didacticalallocation_97d93122` (`allocationId_id`),
  KEY `allocation_didacticalallocation_f46e0075` (`classId_id`),
  KEY `allocation_didacticalallocation_17aa2e87` (`subjectId_id`),
  CONSTRAINT `classId_id_refs_classId_c6e81f28` FOREIGN KEY (`classId_id`) REFERENCES `school_class` (`classId`),
  CONSTRAINT `allocationId_id_refs_allocationId_146f30af` FOREIGN KEY (`allocationId_id`) REFERENCES `allocation_allocation` (`allocationId`),
  CONSTRAINT `subjectId_id_refs_subjectId_ad8ccf04` FOREIGN KEY (`subjectId_id`) REFERENCES `school_subject` (`subjectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allocation_didacticalallocation`
--

LOCK TABLES `allocation_didacticalallocation` WRITE;
/*!40000 ALTER TABLE `allocation_didacticalallocation` DISABLE KEYS */;
/*!40000 ALTER TABLE `allocation_didacticalallocation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `allocation_nondidacticalallocation`
--

DROP TABLE IF EXISTS `allocation_nondidacticalallocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allocation_nondidacticalallocation` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `nonDidacticalAllocationId` int(11) NOT NULL AUTO_INCREMENT,
  `allocationId_id` int(11) NOT NULL,
  `schoolId_id` int(11) NOT NULL,
  PRIMARY KEY (`nonDidacticalAllocationId`),
  KEY `allocation_nondidacticalallocation_97d93122` (`allocationId_id`),
  KEY `allocation_nondidacticalallocation_ac7f7401` (`schoolId_id`),
  CONSTRAINT `schoolId_id_refs_schoolId_26b97c90` FOREIGN KEY (`schoolId_id`) REFERENCES `school_school` (`schoolId`),
  CONSTRAINT `allocationId_id_refs_allocationId_e8d9984b` FOREIGN KEY (`allocationId_id`) REFERENCES `allocation_allocation` (`allocationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allocation_nondidacticalallocation`
--

LOCK TABLES `allocation_nondidacticalallocation` WRITE;
/*!40000 ALTER TABLE `allocation_nondidacticalallocation` DISABLE KEYS */;
/*!40000 ALTER TABLE `allocation_nondidacticalallocation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `allocation_role`
--

DROP TABLE IF EXISTS `allocation_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allocation_role` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `roleId` int(11) NOT NULL AUTO_INCREMENT,
  `role` varchar(20) NOT NULL,
  `description` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `ou` varchar(45) NOT NULL,
  PRIMARY KEY (`roleId`),
  UNIQUE KEY `role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allocation_role`
--

LOCK TABLES `allocation_role` WRITE;
/*!40000 ALTER TABLE `allocation_role` DISABLE KEYS */;
INSERT INTO `allocation_role` VALUES ('2013-07-28 19:49:39','2013-07-28 19:49:39',1,'student','student base','studenti','students'),('2013-07-28 21:29:05','2013-07-28 21:29:05',2,'teacher','Teacher','teacher','teachers'),('2013-07-28 21:30:36','2013-07-28 21:30:36',3,'ata','ata','ata','ata');
/*!40000 ALTER TABLE `allocation_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `allocation_schoolyear`
--

DROP TABLE IF EXISTS `allocation_schoolyear`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allocation_schoolyear` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `schoolYearId` int(11) NOT NULL AUTO_INCREMENT,
  `year` int(10) unsigned NOT NULL,
  `description` varchar(200) NOT NULL,
  `active` tinyint(1) NOT NULL,
  PRIMARY KEY (`schoolYearId`),
  UNIQUE KEY `year` (`year`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allocation_schoolyear`
--

LOCK TABLES `allocation_schoolyear` WRITE;
/*!40000 ALTER TABLE `allocation_schoolyear` DISABLE KEYS */;
/*!40000 ALTER TABLE `allocation_schoolyear` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_id` (`group_id`,`permission_id`),
  KEY `auth_group_permissions_5f412f9a` (`group_id`),
  KEY `auth_group_permissions_83d7f98b` (`permission_id`),
  CONSTRAINT `group_id_refs_id_f4b32aac` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `permission_id_refs_id_6ba0f519` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `content_type_id` (`content_type_id`,`codename`),
  KEY `auth_permission_37ef4eb4` (`content_type_id`),
  CONSTRAINT `content_type_id_refs_id_d043b34a` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add permission',1,'add_permission'),(2,'Can change permission',1,'change_permission'),(3,'Can delete permission',1,'delete_permission'),(4,'Can add group',2,'add_group'),(5,'Can change group',2,'change_group'),(6,'Can delete group',2,'delete_group'),(7,'Can add user',3,'add_user'),(8,'Can change user',3,'change_user'),(9,'Can delete user',3,'delete_user'),(10,'Can add content type',4,'add_contenttype'),(11,'Can change content type',4,'change_contenttype'),(12,'Can delete content type',4,'delete_contenttype'),(13,'Can add session',5,'add_session'),(14,'Can change session',5,'change_session'),(15,'Can delete session',5,'delete_session'),(16,'Can add site',6,'add_site'),(17,'Can change site',6,'change_site'),(18,'Can delete site',6,'delete_site'),(19,'Can add log entry',7,'add_logentry'),(20,'Can change log entry',7,'change_logentry'),(21,'Can delete log entry',7,'delete_logentry'),(22,'Can add sys user',8,'add_sysuser'),(23,'Can change sys user',8,'change_sysuser'),(24,'Can delete sys user',8,'delete_sysuser'),(25,'Can add migration history',9,'add_migrationhistory'),(26,'Can change migration history',9,'change_migrationhistory'),(27,'Can delete migration history',9,'delete_migrationhistory'),(28,'Can add school',10,'add_school'),(29,'Can change school',10,'change_school'),(30,'Can delete school',10,'delete_school'),(31,'Can add class',11,'add_class'),(32,'Can change class',11,'change_class'),(33,'Can delete class',11,'delete_class'),(34,'Can add subject',12,'add_subject'),(35,'Can change subject',12,'change_subject'),(36,'Can delete subject',12,'delete_subject'),(37,'Can add role',13,'add_role'),(38,'Can change role',13,'change_role'),(39,'Can delete role',13,'delete_role'),(40,'Can add school year',14,'add_schoolyear'),(41,'Can change school year',14,'change_schoolyear'),(42,'Can delete school year',14,'delete_schoolyear'),(43,'Can add allocation',15,'add_allocation'),(44,'Can change allocation',15,'change_allocation'),(45,'Can delete allocation',15,'delete_allocation'),(46,'Can add non didactical allocation',16,'add_nondidacticalallocation'),(47,'Can change non didactical allocation',16,'change_nondidacticalallocation'),(48,'Can delete non didactical allocation',16,'delete_nondidacticalallocation'),(49,'Can add didactical allocation',17,'add_didacticalallocation'),(50,'Can change didactical allocation',17,'change_didacticalallocation'),(51,'Can delete didactical allocation',17,'delete_didacticalallocation'),(52,'Can add policy',18,'add_policy'),(53,'Can change policy',18,'change_policy'),(54,'Can delete policy',18,'delete_policy'),(55,'Can add account',19,'add_account'),(56,'Can change account',19,'change_account'),(57,'Can delete account',19,'delete_account'),(58,'Can add assigned policy',20,'add_assignedpolicy'),(59,'Can change assigned policy',20,'change_assignedpolicy'),(60,'Can delete assigned policy',20,'delete_assignedpolicy'),(61,'Can add group',21,'add_group'),(62,'Can change group',21,'change_group'),(63,'Can delete group',21,'delete_group'),(64,'Can add group policy',22,'add_grouppolicy'),(65,'Can change group policy',22,'change_grouppolicy'),(66,'Can delete group policy',22,'delete_grouppolicy'),(67,'Can add backend',23,'add_backend'),(68,'Can change backend',23,'change_backend'),(69,'Can delete backend',23,'delete_backend'),(70,'Can add profile',24,'add_profile'),(71,'Can change profile',24,'change_profile'),(72,'Can delete profile',24,'delete_profile');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime NOT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(30) NOT NULL,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `email` varchar(75) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$10000$0TCZ32ggRpp0$Pmim3t1289/vuyCF0i+2HA7b9L3RqQ/ChQlG9wYdhQk=','2013-08-04 12:24:29',1,'mosa','','','mosarg@gmail.com',1,1,'2013-07-28 19:48:58');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`group_id`),
  KEY `auth_user_groups_6340c63c` (`user_id`),
  KEY `auth_user_groups_5f412f9a` (`group_id`),
  CONSTRAINT `user_id_refs_id_40c41112` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `group_id_refs_id_274b862c` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`permission_id`),
  KEY `auth_user_user_permissions_6340c63c` (`user_id`),
  KEY `auth_user_user_permissions_83d7f98b` (`permission_id`),
  CONSTRAINT `user_id_refs_id_4dc23c39` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `permission_id_refs_id_35d9ac25` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backend_backend`
--

DROP TABLE IF EXISTS `backend_backend`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `backend_backend` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `backendId` int(11) NOT NULL AUTO_INCREMENT,
  `kind` varchar(20) NOT NULL,
  `description` varchar(1000) NOT NULL,
  `serverIp` char(39) NOT NULL,
  `serverFqdn` varchar(200) NOT NULL,
  PRIMARY KEY (`backendId`),
  UNIQUE KEY `kind` (`kind`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backend_backend`
--

LOCK TABLES `backend_backend` WRITE;
/*!40000 ALTER TABLE `backend_backend` DISABLE KEYS */;
INSERT INTO `backend_backend` VALUES ('2013-07-28 21:26:03','2013-07-28 21:26:03',1,'samba4','Db','192.168.0.89','bellatrix.hell.pit'),('2013-08-04 12:24:47','2013-08-04 12:24:47',2,'moodle','Moodle','192.168.0.89','bellatrix.hell.pit');
/*!40000 ALTER TABLE `backend_backend` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuration_profile`
--

DROP TABLE IF EXISTS `configuration_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configuration_profile` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `profileId` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `defaultPolicy_id` int(11) NOT NULL,
  `mainGroup_id` int(11) NOT NULL,
  `backendId_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`profileId`),
  UNIQUE KEY `role_id` (`role_id`,`backendId_id`),
  KEY `configuration_profile_278213e1` (`role_id`),
  KEY `configuration_profile_98854ca4` (`defaultPolicy_id`),
  KEY `configuration_profile_25099871` (`mainGroup_id`),
  KEY `configuration_profile_5a2d15c2` (`backendId_id`),
  CONSTRAINT `mainGroup_id_refs_groupId_c20dfb61` FOREIGN KEY (`mainGroup_id`) REFERENCES `group_group` (`groupId`),
  CONSTRAINT `backendId_id_refs_backendId_8396cfef` FOREIGN KEY (`backendId_id`) REFERENCES `backend_backend` (`backendId`),
  CONSTRAINT `defaultPolicy_id_refs_policyId_711a1219` FOREIGN KEY (`defaultPolicy_id`) REFERENCES `account_policy` (`policyId`),
  CONSTRAINT `role_id_refs_roleId_8f200851` FOREIGN KEY (`role_id`) REFERENCES `allocation_role` (`roleId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuration_profile`
--

LOCK TABLES `configuration_profile` WRITE;
/*!40000 ALTER TABLE `configuration_profile` DISABLE KEYS */;
INSERT INTO `configuration_profile` VALUES ('2013-07-28 21:27:00','2013-07-28 21:27:00',1,1,1,1,1,'studentiBase'),('2013-07-28 21:30:15','2013-07-28 21:30:15',2,2,2,3,1,'profile docenti'),('2013-07-28 21:31:16','2013-07-28 21:31:16',3,3,3,5,1,'profile Ata'),('2013-08-04 12:28:05','2013-08-04 12:28:05',4,2,5,3,2,'moodleDocenti'),('2013-08-04 12:28:23','2013-08-04 12:28:23',5,1,4,1,2,'moodleAlunni');
/*!40000 ALTER TABLE `configuration_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime NOT NULL,
  `user_id` int(11) NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_6340c63c` (`user_id`),
  KEY `django_admin_log_37ef4eb4` (`content_type_id`),
  CONSTRAINT `content_type_id_refs_id_93d2d1f8` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `user_id_refs_id_c0d12874` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2013-07-28 19:49:39',1,13,'1','studenti',1,''),(2,'2013-07-28 21:26:03',1,23,'1','samba4',1,''),(3,'2013-07-28 21:26:16',1,21,'1','alunni',1,''),(4,'2013-07-28 21:26:26',1,21,'2','utenti',1,''),(5,'2013-07-28 21:26:29',1,18,'1','baseStudent',1,''),(6,'2013-07-28 21:27:00',1,24,'1','studentiBase',1,''),(7,'2013-07-28 21:29:05',1,13,'2','teacher',1,''),(8,'2013-07-28 21:29:35',1,21,'3','docenti',1,''),(9,'2013-07-28 21:29:48',1,21,'4','liceo',1,''),(10,'2013-07-28 21:29:54',1,18,'2','baseTeacher',1,''),(11,'2013-07-28 21:30:15',1,24,'2','profile docenti',1,''),(12,'2013-07-28 21:30:36',1,13,'3','ata',1,''),(13,'2013-07-28 21:30:53',1,21,'5','ata',1,''),(14,'2013-07-28 21:30:59',1,18,'3','baseAta',1,''),(15,'2013-07-28 21:31:16',1,24,'3','profile Ata',1,''),(16,'2013-07-28 21:32:07',1,10,'1','liceo',1,''),(17,'2013-07-28 21:32:24',1,10,'2','ipsaa',1,''),(18,'2013-07-28 21:32:45',1,10,'3','ipsc',1,''),(19,'2013-07-28 21:33:03',1,10,'4','ipsia',1,''),(20,'2013-07-28 21:33:33',1,10,'5','sede',1,''),(21,'2013-07-28 21:33:52',1,10,'6','itc',1,''),(22,'2013-07-28 21:34:21',1,14,'1','2012',1,''),(23,'2013-07-28 21:34:30',1,14,'2','2011',1,''),(24,'2013-08-04 12:24:47',1,23,'2','moodle',1,''),(25,'2013-08-04 12:25:41',1,21,'4','liceo',3,''),(26,'2013-08-04 12:26:35',1,18,'4','moodleStudenti',1,''),(27,'2013-08-04 12:27:03',1,18,'5','moodleDocenti',1,''),(28,'2013-08-04 12:27:27',1,14,'2','2011',3,''),(29,'2013-08-04 12:27:27',1,14,'1','2012',3,''),(30,'2013-08-04 12:28:05',1,24,'4','moodleDocenti',1,''),(31,'2013-08-04 12:28:23',1,24,'5','moodleAlunni',1,''),(32,'2013-08-07 08:51:51',1,21,'6','gapps',1,''),(33,'2013-08-07 08:52:32',1,18,'3','baseAta',2,'Aggiunto/a group policy \"GroupPolicy object\".');
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_label` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'permission','auth','permission'),(2,'group','auth','group'),(3,'user','auth','user'),(4,'content type','contenttypes','contenttype'),(5,'session','sessions','session'),(6,'site','sites','site'),(7,'log entry','admin','logentry'),(8,'sys user','sysuser','sysuser'),(9,'migration history','south','migrationhistory'),(10,'school','school','school'),(11,'class','school','class'),(12,'subject','school','subject'),(13,'role','allocation','role'),(14,'school year','allocation','schoolyear'),(15,'allocation','allocation','allocation'),(16,'non didactical allocation','allocation','nondidacticalallocation'),(17,'didactical allocation','allocation','didacticalallocation'),(18,'policy','account','policy'),(19,'account','account','account'),(20,'assigned policy','account','assignedpolicy'),(21,'group','group','group'),(22,'group policy','group','grouppolicy'),(23,'backend','backend','backend'),(24,'profile','configuration','profile');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_b7b81f0c` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('6l4pmpuvwv5esu6acpj7vs3b6b9hg5k0','YWIwNzNkYjMxNDZhZjA3YTYyZDQ5Mzc0YzZlODA0MjY2MTYzZDExODqAAn1xAShVEl9hdXRoX3VzZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEDVQ1fYXV0aF91c2VyX2lkcQSKAQF1Lg==','2013-08-18 12:24:29'),('yj0jzof5w6zz67kt4hf7wp1afnhfqtbf','YWIwNzNkYjMxNDZhZjA3YTYyZDQ5Mzc0YzZlODA0MjY2MTYzZDExODqAAn1xAShVEl9hdXRoX3VzZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEDVQ1fYXV0aF91c2VyX2lkcQSKAQF1Lg==','2013-08-11 19:49:18');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_site`
--

DROP TABLE IF EXISTS `django_site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_site` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(100) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_site`
--

LOCK TABLES `django_site` WRITE;
/*!40000 ALTER TABLE `django_site` DISABLE KEYS */;
INSERT INTO `django_site` VALUES (1,'example.com','example.com');
/*!40000 ALTER TABLE `django_site` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_group`
--

DROP TABLE IF EXISTS `group_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_group` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `groupId` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY (`groupId`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_group`
--

LOCK TABLES `group_group` WRITE;
/*!40000 ALTER TABLE `group_group` DISABLE KEYS */;
INSERT INTO `group_group` VALUES ('2013-07-28 21:26:16','2013-07-28 21:26:16',1,'alunni','Alunni base'),('2013-07-28 21:26:26','2013-07-28 21:26:26',2,'utenti','Utenti Base'),('2013-07-28 21:29:35','2013-07-28 21:29:35',3,'docenti','Docenti'),('2013-07-28 21:30:53','2013-07-28 21:30:53',5,'ata','ata'),('2013-08-07 08:51:51','2013-08-07 08:51:51',6,'gapps','Google apps default group');
/*!40000 ALTER TABLE `group_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_grouppolicy`
--

DROP TABLE IF EXISTS `group_grouppolicy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_grouppolicy` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `groupPolicyId` int(11) NOT NULL AUTO_INCREMENT,
  `groupId_id` int(11) NOT NULL,
  `policyId_id` int(11) NOT NULL,
  `principalGroup` tinyint(1) NOT NULL,
  PRIMARY KEY (`groupPolicyId`),
  UNIQUE KEY `groupId_id` (`groupId_id`,`policyId_id`),
  KEY `group_grouppolicy_e0c5286b` (`groupId_id`),
  KEY `group_grouppolicy_9cb6c456` (`policyId_id`),
  CONSTRAINT `groupId_id_refs_groupId_3ab1ce08` FOREIGN KEY (`groupId_id`) REFERENCES `group_group` (`groupId`),
  CONSTRAINT `policyId_id_refs_policyId_2b90ff36` FOREIGN KEY (`policyId_id`) REFERENCES `account_policy` (`policyId`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_grouppolicy`
--

LOCK TABLES `group_grouppolicy` WRITE;
/*!40000 ALTER TABLE `group_grouppolicy` DISABLE KEYS */;
INSERT INTO `group_grouppolicy` VALUES ('2013-07-28 21:26:29','2013-07-28 21:26:29',1,1,1,1),('2013-07-28 21:26:29','2013-07-28 21:26:29',2,2,1,0),('2013-07-28 21:29:54','2013-07-28 21:29:54',3,3,2,1),('2013-07-28 21:29:54','2013-07-28 21:29:54',4,2,2,0),('2013-07-28 21:30:59','2013-07-28 21:30:59',6,5,3,1),('2013-07-28 21:30:59','2013-07-28 21:30:59',7,2,3,0),('2013-08-04 12:26:35','2013-08-04 12:26:35',8,1,4,0),('2013-08-04 12:26:35','2013-08-04 12:26:35',9,2,4,0),('2013-08-04 12:27:03','2013-08-04 12:27:03',10,3,5,1),('2013-08-04 12:27:03','2013-08-04 12:27:03',11,2,5,0),('2013-08-07 08:52:32','2013-08-07 08:52:32',12,6,3,0);
/*!40000 ALTER TABLE `group_grouppolicy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `school_class`
--

DROP TABLE IF EXISTS `school_class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `school_class` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `classId` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `description` varchar(100) NOT NULL,
  `ou` varchar(30) NOT NULL,
  `capacity` int(10) unsigned NOT NULL,
  `schoolId_id` int(11) NOT NULL,
  `aggregate` tinyint(1) NOT NULL,
  PRIMARY KEY (`classId`),
  UNIQUE KEY `name` (`name`),
  KEY `school_class_ac7f7401` (`schoolId_id`),
  CONSTRAINT `schoolId_id_refs_schoolId_4da08913` FOREIGN KEY (`schoolId_id`) REFERENCES `school_school` (`schoolId`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `school_class`
--

LOCK TABLES `school_class` WRITE;
/*!40000 ALTER TABLE `school_class` DISABLE KEYS */;
INSERT INTO `school_class` VALUES ('2013-07-28 21:46:31','2013-07-28 21:46:31',1,'1acr','Ipsia \"ceconi\" codroipo','1acr',30,4,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',2,'1als','Liceo  scientifico','1als',30,1,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',3,'1apar','Ipsaa \"sabbatini\" - pozzuolo','1apar',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',4,'1apsc','Ipsc  \"linusso\" codroipo','1apsc',30,3,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',5,'1ate','Itc \"linussio\" codroipo','1ate',30,6,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',6,'1bpar','Ipsaa \"sabbatini\" - pozzuolo','1bpar',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',7,'2acr','Ipsia \"ceconi\" codroipo','2acr',30,4,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',8,'2als','Liceo  scientifico','2als',30,1,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',9,'2apar','Ipsaa \"sabbatini\" - pozzuolo','2apar',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',10,'2apsc','Ipsc  \"linusso\" codroipo','2apsc',30,3,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',11,'2ate','Itc \"linussio\" codroipo','2ate',30,6,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',12,'2bpar','Ipsaa \"sabbatini\" - pozzuolo','2bpar',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',13,'2bpsc','Ipsc  \"linusso\" codroipo','2bpsc',30,3,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',14,'3als','Liceo  scientifico','3als',30,1,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',15,'3apar','Ipsaa \"sabbatini\" - pozzuolo','3apar',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',16,'3apsc','Ipsc  \"linusso\" codroipo','3apsc',30,3,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',17,'3ate','Itc \"linussio\" codroipo','3ate',30,6,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',18,'3bls','Liceo  scientifico','3bls',30,1,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',19,'3bpar','Ipsaa \"sabbatini\" - pozzuolo','3bpar',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',20,'3bpsc','Ipsc  \"linusso\" codroipo','3bpsc',30,3,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',21,'4a','Itc \"linussio\" codroipo','4a',30,6,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',22,'4aa','Ipsaa \"sabbatini\" - pozzuolo','4aa',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',23,'4al','Liceo  scientifico','4al',30,1,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',24,'4ao','Ipsc  \"linusso\" codroipo','4ao',30,3,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',25,'4ba','Ipsaa \"sabbatini\" - pozzuolo','4ba',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',26,'4bl','Liceo  scientifico','4bl',30,1,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',27,'4bt','Ipsc  \"linusso\" codroipo','4bt',30,3,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',28,'5aa','Ipsaa \"sabbatini\" - pozzuolo','5aa',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',29,'5ac','Ipsia \"ceconi\" codroipo','5ac',30,4,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',30,'5al','Liceo  scientifico','5al',30,1,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',31,'5ao','Ipsc  \"linusso\" codroipo','5ao',30,3,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',32,'5ba','Ipsaa \"sabbatini\" - pozzuolo','5ba',30,2,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',33,'5bl','Liceo  scientifico','5bl',30,1,0),('2013-07-28 21:46:31','2013-07-28 21:46:31',34,'5bt','Ipsc  \"linusso\" codroipo','5bt',30,3,0);
/*!40000 ALTER TABLE `school_class` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `school_school`
--

DROP TABLE IF EXISTS `school_school`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `school_school` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `schoolId` int(11) NOT NULL AUTO_INCREMENT,
  `meccanographic` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `ou` varchar(100) NOT NULL,
  `description` varchar(300) NOT NULL,
  `active` tinyint(1) NOT NULL,
  PRIMARY KEY (`schoolId`),
  UNIQUE KEY `meccanographic` (`meccanographic`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `school_school`
--

LOCK TABLES `school_school` WRITE;
/*!40000 ALTER TABLE `school_school` DISABLE KEYS */;
INSERT INTO `school_school` VALUES ('2013-07-28 21:32:07','2013-07-28 21:32:07',1,'UDPS011015','liceo','liceo','Liceo scientifico Codroipo',0),('2013-07-28 21:32:24','2013-07-28 21:32:24',2,'UDRA01101P','ipsaa','ipsaa','Ipsaa Pozzuolo',0),('2013-07-28 21:32:45','2013-07-28 21:32:45',3,'UDRC01101N','ipsc','ipsc','Ipsc Cecconi',0),('2013-07-28 21:33:03','2013-07-28 21:33:03',4,'UDRI01101A','ipsia','ipsia','Cecconi',0),('2013-07-28 21:33:33','2013-07-28 21:33:33',5,'UDSSC817F0','sede','sede','Sede centrale',0),('2013-07-28 21:33:52','2013-07-28 21:33:52',6,'UDTD011011','itc','itc','Itc Linussio',1);
/*!40000 ALTER TABLE `school_school` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `school_subject`
--

DROP TABLE IF EXISTS `school_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `school_subject` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `subjectId` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(10) unsigned NOT NULL,
  `description` varchar(200) NOT NULL,
  `shortDescription` varchar(100) NOT NULL,
  `niceName` varchar(50) NOT NULL,
  PRIMARY KEY (`subjectId`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=285 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `school_subject`
--

LOCK TABLES `school_subject` WRITE;
/*!40000 ALTER TABLE `school_subject` DISABLE KEYS */;
INSERT INTO `school_subject` VALUES ('2013-07-28 21:46:22','2013-07-28 21:46:22',1,1000666,'Nessuna Materia','Nessuna materia','No subject'),('2013-07-28 21:46:22','2013-07-28 21:46:22',2,1,'Religione cattolica','Religione cattolica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',3,2,'Condotta','Condotta',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',4,1000001,'Lingua e lettere italiane','Lingua e lettere italiane',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',5,1000002,'Storia ed educazione civica','Storia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',6,1000003,'Prima lingua straniera','1^ lingua straniera',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',7,1000004,'Seconda lingua straniera','2^ lingua straniera',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',8,1000005,'Matematica','Matematica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',9,1000006,'Fisica','Fisica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',10,1000007,'Scienze naturali','Scienze nat.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',11,1000008,'Chimica','Chimica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',12,1000009,'Merceologia','Merceologia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',13,1000010,'Geografia generale','Geografia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',14,1000013,'Tecnica','Tecnica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',15,1000015,'Scienza delle finanze','Scienza delle finanze',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',16,1000017,'Dattilografia','Dattilografia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',17,1000018,'Stenografia','Stenografia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',18,1000019,'Educazione fisica','Educazione fisica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',19,1000021,'Matematica informatica e laboratorio','Matem.inform.lab.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',20,1000024,'Elementi di diritto ed economia','El. dir. ec.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',21,1000025,'Matematica applicata e laboratorio','Mat. appl.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',22,1000026,'Geografia economica','Geografia economica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',23,1000027,'Elementi di tecnica amministrativa','El. tecn. amm.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',24,1000028,'Economia aziendale e laboratorio','Ec. az.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',25,1000029,'Laboratorio per il trattamento di testi','Lab. tratt. test.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',26,1000032,'Lingua e letteratura italiana','Lin. lett. it.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',27,1000138,'Storia','Storia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',28,1000034,'Inglese 1^ lingua','Inglese 1^ l.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',29,1000035,'Inglese 2^ lingua','Inglese 2^ l.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',30,1000036,'Francese 1^ lingua','Francese 1^ l.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',31,1000037,'Francese 2^ lingua','Francese 2^ l.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',32,1000038,'Tedesco 1^ lingua','Tedesco 1^ l.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',33,1000039,'Tedesco 2^ lingua','Tedesco 2^ l.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',34,1000040,'Cultura generale ed educazione civica','Cult. gen. ed. civ.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',35,1000041,'Matematica generale','Matem. gen.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',36,1000042,'Geografia generale ed economica','Geogr.gen.econ.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',37,1000043,'Economia politica e scienza d. finanze','Econ.pol.sc.fin.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',38,1000044,'Calcolo a macchina','Calcolo a macchina',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',39,1000046,'Legislazione sociale e tributaria','Leg.soc.trib.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',40,1000047,'Tecn.amm.az.: tecnica commerciale','Tecn.comm.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',41,1000048,'Ragioneria','Ragioneria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',42,1000049,'Computisteria','Computisteria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',43,1000050,'Tecnica d\'ufficio','Tecnica d\'ufficio',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',44,1000051,'Diritto e legislazione sociale','Diritto e legislazione sociale',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',45,1000052,'Educazione civica','Ed. civica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',46,1000054,'Tecnica del commercio internazionale','Tecn.comm.int.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',47,1000055,'Organizz.,gestione az. e mercatistica','Org.gest.az.merc.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',48,1000056,'Informatica e statistica aziendale','Inf.stat.az.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',49,1000058,'Tecnica amministrativa aziendale','Tecn.ammin.aziendale',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',50,1000060,'Tecnica mercantile, dogane e trasporti','Tecn. mercantile',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',51,1000061,'Tecnica commerciale - computisteria','Tecn.comm.-computisteria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',52,1000062,'Matematica applicata','Matematica applicata',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',53,1000063,'Informatica gestionale','Informatica gestionale',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',54,1000064,'Matematica ed informatica','Matematica e informatica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',55,1000065,'Economia aziendale','Economia aziendale',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',56,1000066,'Tec.amm.az.: tecnica commerciale','Tecnica commerciale',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',57,1000067,'Tec.amm.az.: ragioneria','Ragioneria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',58,1000068,'Tec.amm.az.: computisteria','Computisteria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',59,1000069,'Tec.amm.az.: tecnica d\'ufficio','Tecnica d\'ufficio',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',60,1000070,'Organizzazione, gest.az. e mercatistica','Organizzazione gest.az.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',61,1000071,'Tec.comm./rag./tecnica ufficio','Tec.comm./rag./tec.uff.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',62,1000072,'Diritto ed economia','Diritto ed economia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',63,1000073,'Economia politica','Economia politica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',64,1000074,'Trattamento testi e dati','Trattamento testi e dati',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',65,1000075,'Dattilografia e tec. della duplicazione','Dattilografia e tec.dup.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',66,1000076,'Italiano','Italiano',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',67,1000077,'Scienze della terra e biologia','Scienze d.terra e biol.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',68,1000078,'Lingua inglese','Lingua inglese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',69,1000079,'Laboratorio tratt.testi e contabilita\'','Lab.tratt.testi e contab',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',70,1000080,'Lingua e lettere latine','Lingua e lettere latine',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',71,1000081,'Filosofia','Filosofia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',72,1000082,'Scienze naturali, chimica e geografia','Scienze nat.chim.geogr.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',73,1000083,'Disegno','Disegno',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',74,1000084,'Geografia economica e turistica','Geografia econ. e tur.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',75,1000085,'Storia dell\'arte','Storia dell\'arte',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',76,1000086,'Geografia','Geografia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',77,1000087,'Tecnica turistica e amministrativa','Tecnica turist. e ammin.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',78,1000088,'Economia e tecnica dell\'az. turistica','Economia tecnica az.tur.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',79,1000089,'Geografia turistica','Geografia turistica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',80,1000090,'Storia dell\'arte e dei beni culturali','Storia arte e beni cult.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',81,1000091,'Tecniche di comunicazione e relazione','Tecniche comun. e relaz.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',82,1000092,'Economia d\'azienda','Economia d\'azienda',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',83,1000093,'Geografia delle risorse','Geografia delle risorse',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',84,1000094,'Diritto-economia','Diritto-economia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',85,1000095,'Inglese','Inglese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',86,1000096,'Francese','Francese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',87,1000097,'Tedesco','Tedesco',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',88,1000098,'Debito scolastico','Debito scolastico',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',89,1000099,'Credito scolastico','Credito scolastico',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',90,1000100,'Principi di agricoltura e t.p.a.','Principi di agr.e t.p.a.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',91,1000101,'Principi di chimica e pedologia','Chimica e pedologia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',92,1000102,'Contabilita\' agraria','Contabilita\' agraria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',93,1000103,'Elementi di disegno professionale','Elementi di disegno prof',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',94,1000104,'Ecologia agraria e tutela dell\'ambiente','Elem.di ecologia agraria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',95,1000105,'Fisica e laboratorio','Fisica e laboratorio',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',96,1000106,'Genio rurale','Genio rurale',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',97,1000107,'Economia dell\'azienda agraria','Econ.dell\'azienda agr.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',98,1000108,'Ecologia agraria e tutela ambiente','Ecol.agraria e tut.amb.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',99,1000109,'Tecnologie chimiche agrarie','Tecnologie chimico agr.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',100,1000110,'Tecniche delle produzioni','Tecniche delle produz.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',101,1000111,'Esercitazioni ecologia applicata','Esercitaz. ecologia appl',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',102,1000112,'Biochimica microbiologia t.p.a.','Biochim.microbiol. t.p.a',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',103,1000113,'Elementi di biotecnologie gen. agr.','Elementi di biotec. g.a.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',104,1000114,'Ecologia agraria','Ecologia agraria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',105,1000115,'Econ.agroal.elementi di diritto','Econ.agr.elem.diritto',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',106,1000116,'Laboratorio tecn.agroalimentari','Lab.tecn.agroalim.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',107,1000117,'Ecologia applicata','Ecologia applicata',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',108,1000118,'Tecniche di produzione, t.v.p.','Tecniche produzione, tvp',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',109,1000119,'Contabilita\' e tecnica amministrativa','Contabilita\' agraria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',110,1000120,'Economia agraria','Economia agraria',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',111,1000121,'Economia dei mercati agricoli','Economia mercati agric.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',112,1000122,'Diritto e legislazione','Diritto e legislazione',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',113,1000123,'Tecnologia meccanica e laboratorio','Tecn.meccanica e labor.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',114,1000124,'Esercitazioni pratiche','Esercitazioni pratiche',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',115,1000164,'1° prova','1° prova',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',116,1000125,'Elementi di meccanica','Elem. di meccanica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',117,1000126,'Sistemi ed automazioni','Sistemi ed automaz.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',118,1000127,'Disegno tecnico','Disegno tecnico',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',119,1000128,'Media dei voti','Media dei voti',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',120,1000129,'Tecnica della prod. e labor.','Tecn.prod. e labor.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',121,1000130,'Meccanica applicata alle macchine','Meccanica appl. macchine',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',122,1000131,'Macchine a fluido','Macchine a fluido',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',123,1000132,'Elettrotecnica ed elettronica','Elettrotecnica-elettron.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',124,1000133,'Tecnica della produzione e laboratorio','Tecn.produz. e laborat.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',125,1000134,'Credito a.s.precedente','Credito a.s. precedente',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',126,1000137,'Totale credito scolastico','Tot.credito',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',127,1000139,'Prima lingua straniera inglese','Inglese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',128,1000140,'Prima lingua straniera francese','Francese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',129,1000141,'Prima lingua straniera tedesco','Tedesco',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',130,1000142,'Seconda lingua straniera inglese','Inglese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',131,1000143,'Seconda lingua straniera francese','Francese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',132,1000144,'Seconda lingua straniera tedesco','Tedesco',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',133,1000145,'Scienza della materia e laboratorio','Scienza della materia e laboratorio',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',134,1000146,'Scienze della natura','Scienze della natura',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',135,1000147,'Lingua italiana','Italiano',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',136,1000148,'Lingua e letteratura straniera inglese','Lingua e letteratura straniera inglese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',137,1000149,'1^ lingua e lett. straniera inglese','Inglese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',138,1000150,'2^ lingua e lett. straniera tedesco','Tedesco',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',139,1000151,'Area di approfondimento','',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',140,1000152,'Area di professionalizzazione','',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',141,1000153,'Discipline econom/agrarie','Discipline econom/agrarie',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',142,1000154,'Diritto','Diritto',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',143,1000155,'Scienza delle finanze','Scienza delle finanze',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',144,1000156,'Economia aziendale e laboratorio','Economia aziendale',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',145,1000157,'Diritto-economia-legislazione','Diritto-economia-legislazione',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',146,1000158,'Economia agroalimentare ed elem.','Economia agroalimentare ed elem.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',147,1000159,'Tecniche chimico-agrarie e labor.','Tecniche chimico-agrarie',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',148,1000160,'Tecn.prod.trasf.val.pr.-pr.agrari e','Tecn.prod.trasf.val.pr.-pr.agrari',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',149,1000161,'Biochimica e microbiologia','Biochimica e microbiologia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',150,1000162,'Diritto-economia-legislazione','Diritto-economia-legislazione',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',151,1000163,'Biologia e laboratorio','Biologia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',152,1000165,'2° prova','2° prova',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',153,1000166,'Prova orale','Prova orale',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',154,1000167,'Voto di qualifica','Voto di qualifica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',155,1000168,'Voto di ammissione','Voto di ammissione',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',156,1000169,'2^ lingua e lett. straniera francese','Francese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',157,1000170,'3° prova','3° prova',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',158,1000171,'Seconda lingua straniera spagnolo','Spagnolo',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',159,1000172,'Storia e geografia','Storia geo',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',160,1000173,'Disegno e storia dell\'arte','Dis. storia dell\'arte',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',161,1000174,'Scienze motorie e sportive','Sci. mot. sportive',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',162,1000175,'2^ lingua e lett. straniera spagnolo','Spagnolo',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',163,1000176,'Scienze integrate (scienze della terra e biologia)','Scienze',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',164,1000185,'Sostegno','Sostegno',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',165,1000177,'Scienze integrate (fisica)','Fisica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',166,1000186,'Lingua e cultura latina','Lingua e cultura latina',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',167,1000178,'Informatica','Informatica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',168,1000179,'Informatica e laboratorio','Informatica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',169,1000180,'Tecniche professionali dei servizi commerciali','Tecniche professionali dei servizi commerciali',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',170,1000181,'Scienze integrate (chimica)','Chimica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',171,1000182,'Tecnologie dell\'informazione e della comunicazione','Tecnologie dell\'informazione e della comunicazione',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',172,1000183,'Ecologia e pedologia','Ecologia e pedologia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',173,1000184,'Laboratori tecnologici ed esercitazioni','Laboratori tecnologici ed esercitazioni',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',174,1000187,'Lingua e cultura straniera inglese','Lingua e cultura straniera inglese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',175,1000188,'Tecnologie e tecniche di rappresentazione grafica','Tecnologie e tecniche rappr. grafica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',176,3,'Lingua e letteratura italiana','Ling. let. italiana',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',177,4,'Lingua e lettere italiane','Ling. let. italiane',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',178,5,'Lingua e cultura italiana','Ling. cult. italiana',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',179,6,'Sloveno','Sloveno',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',180,7,'Lingua e cultura latina','Ling. cult. latina',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',181,8,'Lingua e cultura greca','Ling. cult. greca',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',182,9,'Lingua latina','Lingua latina',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',183,10,'Lingua e letteratura classica','Ling. let. classica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',184,11,'Lingua e letteratura classica (latino)','Ling. let.cl. latino',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',185,12,'Lingua e letteratura classica (greco)','Ling. let.cl. greco',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',186,13,'Lettere classiche (latino)','Let. cla. latino',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',187,1000200,'Spagnolo','Spagnolo',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',188,14,'Lettere classiche (greco)','Let. cla. greco',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',189,15,'Scienze umane e sociali','Sc. uma. soc.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',190,16,'Scienze umane (antropologia, pedagogia, psicologia e sociologia)','Sc. ant.ped.psi.soc',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',191,17,'Lingua e cultura straniera','Ling. cult. stra.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',192,18,'Lingua e cultura straniera 1','Ling. cult. stra.1',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',193,19,'Lingua e cultura straniera 2','Ling. cult. stra.2',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',194,20,'Lingua inglese','Lingua inglese',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',195,21,'Seconda lingua straniera','Sec. lin. straniera',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',196,22,'Seconda lingua comunitaria','Sec. lin. comunit.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',197,23,'Lingua e cultura straniera 1 e conversazione con docente madrelingua','Li.cult.stra. 1 conv',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',198,24,'Lingua e cultura straniera 2 e conversazione con docente madrelingua','Li.cult.stra. 2 conv',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',199,25,'Lingua e cultura straniera 3 e conversazione con docente madrelingua','Li.cult.stra. 3 conv',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',200,26,'Lingua europea 1','Lingua europea 1',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',201,27,'Lingua europea 2','Lingua europea 2',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',202,28,'Lingua straniera 1','Lingua straniera 1',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',203,29,'Lingua straniera 2','Lingua straniera 2',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',204,30,'Lingua straniera 3','Lingua straniera 3',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',205,31,'Storia e geografia','Storia e geografia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',206,32,'Storia','Storia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',207,33,'Geografia','Geografia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',208,34,'Matematica con informatica al primo biennio','Mat. info. i biennio',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',209,35,'Matematica','Matematica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',210,36,'Informatica','Informatica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',211,37,'Informatica e laboratorio','Informatica lab.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',212,38,'Matematica e informatica','Mat. info.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',213,39,'Fisica','Fisica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',214,40,'Scienze naturali (biologia, chimica, scienze della terra)','Sc.bio.chi.sc.ter.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',215,41,'Scienze integrate (scienze della terra e biologia)','Sc.int.se.ter.bio.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',216,42,'Scienze integrate (fisica)','Sc.int.fisica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',217,43,'Scienze integrate (chimica)','Sc.int.chimica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',218,44,'Scienze della terra e geografia, chimica, biologia','Sc.ter.geo.chi.bio',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',219,45,'Scienze','Scienze',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',220,46,'Disegno e storia dell\'arte','Dis. e st.arte',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',221,47,'Storia dell\'arte','Storia dell\'arte',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',222,48,'Discipline grafiche e pittoriche','Disc.gra.pit.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',223,49,'Discipline geometriche','Disc. geom.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',224,50,'Discipline plastiche e scultoree','Disc. plast. scult.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',225,51,'Laboratorio artistico','Lab. artistico',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',226,52,'Musica','Musica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',227,53,'Esecuzione e interpretazione','Esec. interp.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',228,54,'Teoria, analisi e composizione','Teo. ana. comp.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',229,55,'Storia della musica','Storia della musica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',230,56,'Laboratorio di musica d\'insieme','Lab. mus. insieme',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',231,57,'Tecnologie musicali','Tecnologie musicali',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',232,58,'Tecniche della danza','Tec. della danza',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',233,59,'Laboratorio coreutico','Lab. coreutico',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',234,60,'Teoria e pratica musicale per la danza','Teo.pra.mus.danza',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',235,61,'Educazione civica, giuridica e economica','Ed.civ.giu.eco.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',236,62,'Diritto ed economia','Diritto ed economia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',237,63,'Diritto ed economia politica','Dir. ec. politica',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',238,64,'Economia aziendale','Economia aziendale',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',239,65,'Tecnologie e tecniche di rappresentazione grafica','Tecnol. tec.rap.gra.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',240,66,'Tecnologie informatiche','Tecn. informatico',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',241,67,'Tecnologie dell\'informazione e della comunicazione','Tecn. inf. com.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',242,68,'Ecologia e pedologia','Ecologia e pedologia',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',243,69,'Laboratori tecnologici ed esercitazioni','Lab. tec. eserc.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',244,70,'Elementi di storia dell\'arte ed espressioni grafiche','El.st.arte esp.gra.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',245,71,'Metodologie operative','Metod. operative',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',246,72,'Anatomia fisiologia igiene','Anat. fisio. igie.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',247,73,'Rappresentazione e modellazione odontotecnica','Rap. mod. odonto.',''),('2013-07-28 21:46:22','2013-07-28 21:46:22',248,74,'Esercitazioni di laboratorio di odontotecnica','Es. lab. odonto.',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',249,75,'Discipline sanitarie (anatomia, fisiopatologia oculare e igiene)','Disc, sanitarie',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',250,76,'Ottica, ottica applicata','Ott. ott. applicata',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',251,77,'Esercitazioni di lenti oftalmiche','Es. lenti oft.',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',252,78,'Scienza degli alimenti','Sc. alimenti',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',253,79,'Laboratorio di servizi enogastronomici - settore cucina','Lab.ser.enoga.cucina',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',254,80,'Laboratorio di servizi enogastronomici - settore sala e vendita','Lab.ser.enoga.sala',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',255,81,'Laboratorio di servizi di accoglienza turistica','Lab.ser. acc. tur.',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',256,82,'Tecniche professionali dei servizi commerciali','Tec.prof.serv.com.',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',257,83,'Scienze motorie e sportive','Sc. mot. sport.',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',258,84,'Religione cattolica o attivita\' alternative','Rel.cat.att.alt',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',259,85,'Materia autonomia','Materia autonomia',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',260,86,'Materia flessibilita\'','Materia flex',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',261,87,'Comportamento','Comportamento',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',262,1000189,'Tecniche di comunicazione','Tecniche di comunicazione',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',263,1000190,'Biologia applicata','Biologia applicata',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',264,1000191,'Chimica applicata e processi di trasformazione','Chimica applicata e processi di trasformazione',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',265,1000192,'Tecniche di allevamento vegetale e animale','Tecniche di allevamento vegetale e animale',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',266,1000193,'Agronomia territoriale ed ecosistemi forestali','Agronomia territoriale ed ecosistemi forestali',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',267,1000194,'Economia agraria e dello sviluppo territoriale','Economia agraria e dello sviluppo territoriale',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',268,1000195,'Agronomia del territorio e sist. idrauliche','Agronomia del territorio e sist. idrauliche',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',269,1000196,'Silvicoltura e utilizzazioni forestali','Silvicoltura e utilizzazioni forestali',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',270,1000197,'Economia agraria e leg. di settore','Economia agraria e leg. di settore',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',271,1000201,'Inglese potenziato','Inglese potenziato',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',272,1000198,'Agronomia territoriale','Agronomia territoriale',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',273,1000199,'Valorizzazione delle attivita produttive','Valorizzazione delle attivita produttive',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',274,1000202,'Tecnologie meccaniche e applicazioni','Tecnologie meccaniche e applicazioni',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',275,1000203,'Tecnologie elettrico-elettroniche e applicazioni','Tecnologie elettrico-elettroniche e applicazioni',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',276,1000204,'Tecnologie e tecniche di installazione e di manutenzione','Tecnologie e tecniche di install e di manutenz.',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',277,1000205,'Sociologia rurale, valorizzazione e sviluppo del territorio montano ','Sociologia rurale, valor. e svil. del terr. mont. ',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',278,1000206,'Gestione di parchi, aree protette e assestamento forestale','Gestione di parchi, aree protette e assest  for.',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',279,1000207,'Economia dei mercati e marketing agroalimentare ed elementi di logistica','Economia dei mercati e marketing agroal. elem.log.',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',280,1000208,'Sociologia rurale e storia dell\'agricoltura','Sociologia rurale e storia dell\'agricoltura',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',281,1000209,'Scienza degli alimenti','Scienza degli alimenti',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',282,1000210,'Laboratorio di servizi enogastronomici - settore cucina','Laboratorio serv. enogastronomici - settore cucina',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',283,1000211,'Laboratorio di servizi enogastronomici - settore sala e vendita','Laboratorio serv. enogast - settore sala e vendita',''),('2013-07-28 21:46:23','2013-07-28 21:46:23',284,1000212,'Laboratorio di servizi di accoglienza turistica','Laboratorio di servizi di accoglienza turistica','');
/*!40000 ALTER TABLE `school_subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `south_migrationhistory`
--

DROP TABLE IF EXISTS `south_migrationhistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `south_migrationhistory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_name` varchar(255) NOT NULL,
  `migration` varchar(255) NOT NULL,
  `applied` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `south_migrationhistory`
--

LOCK TABLES `south_migrationhistory` WRITE;
/*!40000 ALTER TABLE `south_migrationhistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `south_migrationhistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sysuser_sysuser`
--

DROP TABLE IF EXISTS `sysuser_sysuser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sysuser_sysuser` (
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `userId` int(11) NOT NULL AUTO_INCREMENT,
  `sidiId` int(10) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `surname` varchar(100) NOT NULL,
  `origin` varchar(45) NOT NULL,
  `insertOrder` int(11) NOT NULL,
  PRIMARY KEY (`userId`),
  UNIQUE KEY `sidiId` (`sidiId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sysuser_sysuser`
--

LOCK TABLES `sysuser_sysuser` WRITE;
/*!40000 ALTER TABLE `sysuser_sysuser` DISABLE KEYS */;
/*!40000 ALTER TABLE `sysuser_sysuser` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-08-07 10:54:11
