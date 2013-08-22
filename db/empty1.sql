-- MySQL dump 10.13  Distrib 5.5.31, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: gestione_scuola
-- ------------------------------------------------------
-- Server version	5.5.31-0ubuntu0.13.04.1

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_policy`
--

LOCK TABLES `account_policy` WRITE;
/*!40000 ALTER TABLE `account_policy` DISABLE KEYS */;
INSERT INTO `account_policy` VALUES ('2013-07-28 21:26:29','2013-07-28 21:26:29',1,'baseStudent','Policy base studenti',1),('2013-07-28 21:29:54','2013-07-28 21:29:54',2,'baseTeacher','base insegnanti',1),('2013-07-28 21:30:59','2013-07-28 21:30:59',3,'baseAta','Base ata',1);
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
INSERT INTO `allocation_schoolyear` VALUES ('2013-07-28 21:34:21','2013-07-28 21:34:21',1,2012,'Current year',1),('2013-07-28 21:34:30','2013-07-28 21:34:30',2,2011,'Last year',0);
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
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$10000$0TCZ32ggRpp0$Pmim3t1289/vuyCF0i+2HA7b9L3RqQ/ChQlG9wYdhQk=','2013-07-28 19:49:18',1,'mosa','','','mosarg@gmail.com',1,1,'2013-07-28 19:48:58');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backend_backend`
--

LOCK TABLES `backend_backend` WRITE;
/*!40000 ALTER TABLE `backend_backend` DISABLE KEYS */;
INSERT INTO `backend_backend` VALUES ('2013-07-28 21:26:03','2013-07-28 21:26:03',1,'samba4','Db','192.168.0.89','bellatrix.hell.pit');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuration_profile`
--

LOCK TABLES `configuration_profile` WRITE;
/*!40000 ALTER TABLE `configuration_profile` DISABLE KEYS */;
INSERT INTO `configuration_profile` VALUES ('2013-07-28 21:27:00','2013-07-28 21:27:00',1,1,1,1,1,'studentiBase'),('2013-07-28 21:30:15','2013-07-28 21:30:15',2,2,2,3,1,'profile docenti'),('2013-07-28 21:31:16','2013-07-28 21:31:16',3,3,3,5,1,'profile Ata');
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
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2013-07-28 19:49:39',1,13,'1','studenti',1,''),(2,'2013-07-28 21:26:03',1,23,'1','samba4',1,''),(3,'2013-07-28 21:26:16',1,21,'1','alunni',1,''),(4,'2013-07-28 21:26:26',1,21,'2','utenti',1,''),(5,'2013-07-28 21:26:29',1,18,'1','baseStudent',1,''),(6,'2013-07-28 21:27:00',1,24,'1','studentiBase',1,''),(7,'2013-07-28 21:29:05',1,13,'2','teacher',1,''),(8,'2013-07-28 21:29:35',1,21,'3','docenti',1,''),(9,'2013-07-28 21:29:48',1,21,'4','liceo',1,''),(10,'2013-07-28 21:29:54',1,18,'2','baseTeacher',1,''),(11,'2013-07-28 21:30:15',1,24,'2','profile docenti',1,''),(12,'2013-07-28 21:30:36',1,13,'3','ata',1,''),(13,'2013-07-28 21:30:53',1,21,'5','ata',1,''),(14,'2013-07-28 21:30:59',1,18,'3','baseAta',1,''),(15,'2013-07-28 21:31:16',1,24,'3','profile Ata',1,''),(16,'2013-07-28 21:32:07',1,10,'1','liceo',1,''),(17,'2013-07-28 21:32:24',1,10,'2','ipsaa',1,''),(18,'2013-07-28 21:32:45',1,10,'3','ipsc',1,''),(19,'2013-07-28 21:33:03',1,10,'4','ipsia',1,''),(20,'2013-07-28 21:33:33',1,10,'5','sede',1,''),(21,'2013-07-28 21:33:52',1,10,'6','itc',1,''),(22,'2013-07-28 21:34:21',1,14,'1','2012',1,''),(23,'2013-07-28 21:34:30',1,14,'2','2011',1,'');
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
INSERT INTO `django_session` VALUES ('yj0jzof5w6zz67kt4hf7wp1afnhfqtbf','YWIwNzNkYjMxNDZhZjA3YTYyZDQ5Mzc0YzZlODA0MjY2MTYzZDExODqAAn1xAShVEl9hdXRoX3VzZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEDVQ1fYXV0aF91c2VyX2lkcQSKAQF1Lg==','2013-08-11 19:49:18');
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_group`
--

LOCK TABLES `group_group` WRITE;
/*!40000 ALTER TABLE `group_group` DISABLE KEYS */;
INSERT INTO `group_group` VALUES ('2013-07-28 21:26:16','2013-07-28 21:26:16',1,'alunni','Alunni base'),('2013-07-28 21:26:26','2013-07-28 21:26:26',2,'utenti','Utenti Base'),('2013-07-28 21:29:35','2013-07-28 21:29:35',3,'docenti','Docenti'),('2013-07-28 21:29:48','2013-07-28 21:29:48',4,'liceo','Liceo'),('2013-07-28 21:30:53','2013-07-28 21:30:53',5,'ata','ata');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_grouppolicy`
--

LOCK TABLES `group_grouppolicy` WRITE;
/*!40000 ALTER TABLE `group_grouppolicy` DISABLE KEYS */;
INSERT INTO `group_grouppolicy` VALUES ('2013-07-28 21:26:29','2013-07-28 21:26:29',1,1,1,1),('2013-07-28 21:26:29','2013-07-28 21:26:29',2,2,1,0),('2013-07-28 21:29:54','2013-07-28 21:29:54',3,3,2,1),('2013-07-28 21:29:54','2013-07-28 21:29:54',4,2,2,0),('2013-07-28 21:29:54','2013-07-28 21:29:54',5,4,2,0),('2013-07-28 21:30:59','2013-07-28 21:30:59',6,5,3,1),('2013-07-28 21:30:59','2013-07-28 21:30:59',7,2,3,0);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `school_class`
--

LOCK TABLES `school_class` WRITE;
/*!40000 ALTER TABLE `school_class` DISABLE KEYS */;
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
INSERT INTO `school_school` VALUES ('2013-07-28 21:32:07','2013-07-28 21:32:07',1,'UDPS011015','liceo','liceo','Liceo scientifico Codroipo',1),('2013-07-28 21:32:24','2013-07-28 21:32:24',2,'UDRA01101P','ipsaa','ipsaa','Ipsaa Pozzuolo',1),('2013-07-28 21:32:45','2013-07-28 21:32:45',3,'UDRC01101N','ipsc','ipsc','Ipsc Cecconi',1),('2013-07-28 21:33:03','2013-07-28 21:33:03',4,'UDRI01101A','ipsia','ipsia','Cecconi',1),('2013-07-28 21:33:33','2013-07-28 21:33:33',5,'UDSSC817F0','sede','sede','Sede centrale',1),('2013-07-28 21:33:52','2013-07-28 21:33:52',6,'UDTD011011','itc','itc','Itc Linussio',1);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `school_subject`
--

LOCK TABLES `school_subject` WRITE;
/*!40000 ALTER TABLE `school_subject` DISABLE KEYS */;
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

-- Dump completed on 2013-07-28 23:36:33
