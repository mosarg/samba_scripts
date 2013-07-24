-- MySQL dump 10.13  Distrib 5.5.31, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: schoolManagement
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
-- Current Database: `schoolManagement`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `schoolManagement` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `schoolManagement`;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `username` varchar(45) NOT NULL,
  `active` tinyint(1) NOT NULL,
  `userIdNumber` int(11) NOT NULL,
  `backendUidNumber` int(11) NOT NULL DEFAULT '0',
  `type` varchar(45) NOT NULL,
  PRIMARY KEY (`userIdNumber`,`type`),
  KEY `fk_account_user1` (`userIdNumber`),
  KEY `fk_account_backends1` (`type`),
  CONSTRAINT `fk_account_backends1` FOREIGN KEY (`type`) REFERENCES `backends` (`type`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_account_user1` FOREIGN KEY (`userIdNumber`) REFERENCES `user` (`userIdNumber`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignedPolicy`
--

DROP TABLE IF EXISTS `assignedPolicy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignedPolicy` (
  `userIdNumber` int(11) NOT NULL,
  `type` varchar(45) NOT NULL,
  `policyId` int(11) NOT NULL,
  `start` timestamp NULL DEFAULT NULL,
  `end` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`userIdNumber`,`type`,`policyId`),
  KEY `fk_account_has_policy_policy1` (`policyId`),
  KEY `fk_account_has_policy_account1` (`userIdNumber`,`type`),
  CONSTRAINT `fk_account_has_policy_account1` FOREIGN KEY (`userIdNumber`, `type`) REFERENCES `account` (`userIdNumber`, `type`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_account_has_policy_policy1` FOREIGN KEY (`policyId`) REFERENCES `policy` (`policyId`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignedPolicy`
--

LOCK TABLES `assignedPolicy` WRITE;
/*!40000 ALTER TABLE `assignedPolicy` DISABLE KEYS */;
/*!40000 ALTER TABLE `assignedPolicy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ataAllocation`
--

DROP TABLE IF EXISTS `ataAllocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ataAllocation` (
  `userIdNumber` int(11) NOT NULL,
  `meccanographic` char(100) NOT NULL,
  `year` year(4) NOT NULL,
  `ou` varchar(45) NOT NULL DEFAULT 'default',
  PRIMARY KEY (`userIdNumber`,`year`),
  KEY `fk_user_has_school_school1` (`meccanographic`),
  KEY `fk_user_has_school_user1` (`userIdNumber`),
  KEY `fk_ataAllocation_schoolYear1` (`year`),
  CONSTRAINT `fk_ataAllocation_schoolYear1` FOREIGN KEY (`year`) REFERENCES `schoolYear` (`year`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_has_school_school1` FOREIGN KEY (`meccanographic`) REFERENCES `school` (`meccanographic`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_has_school_user1` FOREIGN KEY (`userIdNumber`) REFERENCES `user` (`userIdNumber`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ataAllocation`
--

LOCK TABLES `ataAllocation` WRITE;
/*!40000 ALTER TABLE `ataAllocation` DISABLE KEYS */;
/*!40000 ALTER TABLE `ataAllocation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backends`
--

DROP TABLE IF EXISTS `backends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `backends` (
  `type` varchar(45) NOT NULL,
  `description` varchar(45) DEFAULT NULL,
  `serverIp` varchar(45) DEFAULT NULL,
  `serverFqdn` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backends`
--

LOCK TABLES `backends` WRITE;
/*!40000 ALTER TABLE `backends` DISABLE KEYS */;
INSERT INTO `backends` VALUES ('gapps','Account Google Apps','1.25.8.45','apps.google.com'),('moodle','Account Moodle','192.168.0.75','moodle.hell.pit'),('samba4','Account ad ','192.168.0.89','bellatrix.hell.pit');
/*!40000 ALTER TABLE `backends` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `class`
--

DROP TABLE IF EXISTS `class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `class` (
  `classId` char(20) NOT NULL,
  `classDescription` varchar(45) NOT NULL,
  `classOu` varchar(45) NOT NULL,
  `classCapacity` varchar(45) NOT NULL,
  `meccanographic` char(100) NOT NULL,
  PRIMARY KEY (`classId`),
  KEY `fk_class_school1` (`meccanographic`),
  CONSTRAINT `fk_class_school1` FOREIGN KEY (`meccanographic`) REFERENCES `school` (`meccanographic`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `class`
--

LOCK TABLES `class` WRITE;
/*!40000 ALTER TABLE `class` DISABLE KEYS */;
/*!40000 ALTER TABLE `class` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group`
--

DROP TABLE IF EXISTS `group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group` (
  `groupId` int(11) NOT NULL AUTO_INCREMENT,
  `groupName` varchar(45) NOT NULL,
  `groupDescription` varchar(45) NOT NULL,
  PRIMARY KEY (`groupId`),
  UNIQUE KEY `groupName_UNIQUE` (`groupName`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group`
--

LOCK TABLES `group` WRITE;
/*!40000 ALTER TABLE `group` DISABLE KEYS */;
INSERT INTO `group` VALUES (1,'studenti','Base student group'),(2,'professori','Base teacher group'),(3,'ata','Base ata group'),(4,'sostegno','H'),(5,'liceo','Utenti Liceo'),(6,'ipsc','Utenti Ipsc'),(7,'itc','Utenti Itc'),(8,'ipsaa','Utenti Ipsaa'),(9,'ipsia','Utenti Ipsia'),(10,'tecnici','Assistenti tecnici'),(15,'hell','generic description');
/*!40000 ALTER TABLE `group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groupPolicy`
--

DROP TABLE IF EXISTS `groupPolicy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groupPolicy` (
  `policyId` int(11) NOT NULL,
  `groupId` int(11) NOT NULL,
  `start` timestamp NULL DEFAULT NULL,
  `end` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`policyId`,`groupId`),
  KEY `fk_policy_has_group_group1` (`groupId`),
  KEY `fk_policy_has_group_policy1` (`policyId`),
  CONSTRAINT `fk_policy_has_group_group1` FOREIGN KEY (`groupId`) REFERENCES `group` (`groupId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_policy_has_group_policy1` FOREIGN KEY (`policyId`) REFERENCES `policy` (`policyId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groupPolicy`
--

LOCK TABLES `groupPolicy` WRITE;
/*!40000 ALTER TABLE `groupPolicy` DISABLE KEYS */;
INSERT INTO `groupPolicy` VALUES (1,1,NULL,NULL),(1,2,NULL,NULL),(1,5,NULL,NULL),(1,6,NULL,NULL),(1,7,NULL,NULL),(1,8,NULL,NULL),(1,9,NULL,NULL),(1,10,NULL,NULL),(2,1,NULL,NULL),(2,15,'2013-07-10 15:13:31',NULL),(3,3,NULL,NULL);
/*!40000 ALTER TABLE `groupPolicy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `policy`
--

DROP TABLE IF EXISTS `policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy` (
  `policyId` int(11) NOT NULL AUTO_INCREMENT,
  `policyName` varchar(45) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `type` varchar(45) NOT NULL,
  PRIMARY KEY (`policyId`),
  KEY `fk_policy_backends1` (`type`),
  CONSTRAINT `fk_policy_backends1` FOREIGN KEY (`type`) REFERENCES `backends` (`type`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `policy`
--

LOCK TABLES `policy` WRITE;
/*!40000 ALTER TABLE `policy` DISABLE KEYS */;
INSERT INTO `policy` VALUES (1,'baseTeacher','Professore Base','samba4'),(2,'baseStudent','Studente Base','samba4'),(3,'baseAta','Ata Base','samba4');
/*!40000 ALTER TABLE `policy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `role` char(20) NOT NULL,
  `description` varchar(45) DEFAULT NULL,
  `defaultOu` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `mainGroup` int(11) NOT NULL,
  PRIMARY KEY (`role`),
  KEY `fk_role_group1` (`mainGroup`),
  CONSTRAINT `fk_role_group1` FOREIGN KEY (`mainGroup`) REFERENCES `group` (`groupId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES ('ata','Ruolo Ata','ata','Ata',3),('student','Ruolo Studente','student','Studente',1),('teacher','Ruolo docente','teacher','Insegnante',2);
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `school`
--

DROP TABLE IF EXISTS `school`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `school` (
  `meccanographic` char(100) NOT NULL,
  `name` varchar(45) NOT NULL,
  `schoolOu` varchar(45) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`meccanographic`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `school`
--

LOCK TABLES `school` WRITE;
/*!40000 ALTER TABLE `school` DISABLE KEYS */;
INSERT INTO `school` VALUES ('UDPS011015','liceo','liceo','Liceo Scientifico Codroipo',1),('UDRA01101P','ipsaa','ipsaa','Ipsaa Sabbatini Pozzuolo',0),('UDRC01101N','ipsc','ipsc','',0),('UDRI01101A','ipsia','ipsia','Ipsia Cecconi Codroipo',0),('UDSSC817F0','sede','personale','Sede principale',0),('UDTD011011','itc','itc','Itc Linussio Codroipo',0);
/*!40000 ALTER TABLE `school` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schoolYear`
--

DROP TABLE IF EXISTS `schoolYear`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schoolYear` (
  `year` year(4) NOT NULL,
  `description` varchar(45) NOT NULL DEFAULT 'nothing new',
  `current` tinyint(1) NOT NULL,
  PRIMARY KEY (`year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schoolYear`
--

LOCK TABLES `schoolYear` WRITE;
/*!40000 ALTER TABLE `schoolYear` DISABLE KEYS */;
/*!40000 ALTER TABLE `schoolYear` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `studentAllocation`
--

DROP TABLE IF EXISTS `studentAllocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `studentAllocation` (
  `userIdNumber` int(11) NOT NULL,
  `classId` char(20) NOT NULL,
  `year` year(4) NOT NULL,
  PRIMARY KEY (`userIdNumber`,`year`),
  KEY `fk_alunno_has_class_class1` (`classId`),
  KEY `fk_alunno_has_class_alunno` (`userIdNumber`),
  KEY `fk_studentAllocation_schoolYear1` (`year`),
  CONSTRAINT `fk_alunno_has_class_alunno` FOREIGN KEY (`userIdNumber`) REFERENCES `user` (`userIdNumber`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_alunno_has_class_class1` FOREIGN KEY (`classId`) REFERENCES `class` (`classId`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_studentAllocation_schoolYear1` FOREIGN KEY (`year`) REFERENCES `schoolYear` (`year`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `studentAllocation`
--

LOCK TABLES `studentAllocation` WRITE;
/*!40000 ALTER TABLE `studentAllocation` DISABLE KEYS */;
/*!40000 ALTER TABLE `studentAllocation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subject`
--

DROP TABLE IF EXISTS `subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subject` (
  `subjectId` int(11) NOT NULL,
  `description` varchar(200) NOT NULL,
  `shortDesc` varchar(45) NOT NULL,
  `niceName` varchar(60) NOT NULL DEFAULT 'Substitute me',
  PRIMARY KEY (`subjectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subject`
--

LOCK TABLES `subject` WRITE;
/*!40000 ALTER TABLE `subject` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacherAllocation`
--

DROP TABLE IF EXISTS `teacherAllocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teacherAllocation` (
  `userIdNumber` int(11) NOT NULL,
  `classId` char(20) NOT NULL,
  `year` year(4) NOT NULL,
  `subjectId` int(11) NOT NULL,
  `ou` varchar(45) NOT NULL DEFAULT 'default',
  PRIMARY KEY (`userIdNumber`,`classId`,`year`,`subjectId`),
  KEY `fk_teaches_class1` (`classId`),
  KEY `fk_teacherAllocation_schoolYear1` (`year`),
  KEY `fk_teacherAllocation_subject1` (`subjectId`),
  CONSTRAINT `fk_teacherAllocation_schoolYear1` FOREIGN KEY (`year`) REFERENCES `schoolYear` (`year`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_teacherAllocation_subject1` FOREIGN KEY (`subjectId`) REFERENCES `subject` (`subjectId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_teacher_user1` FOREIGN KEY (`userIdNumber`) REFERENCES `user` (`userIdNumber`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_teaches_class1` FOREIGN KEY (`classId`) REFERENCES `class` (`classId`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacherAllocation`
--

LOCK TABLES `teacherAllocation` WRITE;
/*!40000 ALTER TABLE `teacherAllocation` DISABLE KEYS */;
/*!40000 ALTER TABLE `teacherAllocation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `userIdNumber` int(11) NOT NULL,
  `name` char(100) NOT NULL,
  `surname` char(100) NOT NULL,
  `role` char(20) NOT NULL,
  `origin` varchar(45) NOT NULL DEFAULT 'automatic',
  `creation` timestamp NULL DEFAULT NULL,
  `insertOrder` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`userIdNumber`),
  KEY `fk_user_role1` (`role`),
  CONSTRAINT `fk_user_role1` FOREIGN KEY (`role`) REFERENCES `role` (`role`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-07-18 16:34:33
