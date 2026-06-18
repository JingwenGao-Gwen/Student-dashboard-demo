-- MySQL dump 10.13  Distrib 9.5.0, for macos15.4 (arm64)
--
-- Host: localhost    Database: course_db
-- ------------------------------------------------------
-- Server version	9.5.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'a8c437b6-5332-11f0-81fa-3d8d0a8c9f7a:1-74';

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `student_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `major` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `college` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year_enrolled` int DEFAULT NULL,
  `hometown` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gpa` decimal(4,3) DEFAULT NULL,
  `total_credits` int DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `risk_level` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completion_rate` decimal(5,2) DEFAULT NULL,
  `last_contact_date` date DEFAULT NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES ('122010001','zixuanwang','122010001@link.cuhk.edu.cn','Zixuan','Wang','Accounting Data and Analytics','Harmonia College',2022,'Guangdong',3.672,120,'active',NULL,NULL,NULL),('122040156','michaelchen','122040156@link.cuhk.edu.cn','Michael','Chen','Computer Science and Engineering','Harmonia College',2022,'Beijing',3.111,88,'active',NULL,NULL,NULL),('122040267','sophiawang','122040267@link.cuhk.edu.cn','Sophia','Wang','Data Science and Big Data Technology','Ling College',2022,'Shanghai',3.113,128,'active',NULL,NULL,NULL),('122040384','jamesliu','122040384@link.cuhk.edu.cn','James','Liu','Financial Engineering - Quantitative Finance','Shaw College',2022,'Guangdong',3.348,129,'active',NULL,NULL,NULL),('122040491','jordanellis','122040491@link.cuhk.edu.cn','Jordan','Ellis','Statistics','Diligentia College',2022,'Canada',3.098,100,'active',NULL,NULL,NULL),('123030001','muyangliu','123030001@link.cuhk.edu.cn','Muyang','Liu','Accounting and Financial Reporting','Muse College',2023,'Jiangxi',3.911,66,'active',NULL,NULL,NULL),('124010001','zihanchen','124010001@link.cuhk.edu.cn','Zihan','Chen','Accounting Data and Analytics','Diligentia College',2024,'Zhejiang',3.169,63,'active',NULL,NULL,NULL),('125030003','ruohanzhou','125030003@link.cuhk.edu.cn','Ruohan','Zhou','Accounting and Financial Reporting','Ling College',2025,'Hunan',2.883,32,'active',NULL,NULL,NULL);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrollment`
--

DROP TABLE IF EXISTS `enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enrollment` (
  `enrollment_id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `semester` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grade` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `score_pct` decimal(5,2) DEFAULT NULL,
  `category` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Completed',
  PRIMARY KEY (`enrollment_id`),
  KEY `student_id` (`student_id`),
  KEY `course_code` (`course_code`),
  CONSTRAINT `enrollment_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  CONSTRAINT `enrollment_ibfk_2` FOREIGN KEY (`course_code`) REFERENCES `courses` (`course_code`)
) ENGINE=InnoDB AUTO_INCREMENT=289 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollment`
--

LOCK TABLES `enrollment` WRITE;
/*!40000 ALTER TABLE `enrollment` DISABLE KEYS */;
INSERT INTO `enrollment` VALUES (1,'122040156','ENG2002S','2022-23 Term 1','B-',37.40,'English','Completed'),(2,'122040156','CSC3002','2022-23 Term 1','A-',45.70,'Major','Completed'),(3,'122040156','ITE1000','2022-23 Term 1','B+',42.20,'IT','Completed'),(4,'122040156','GEB2207','2022-23 Term 1','A-',47.30,'GenEd','Completed'),(5,'122040156','GFN1000','2022-23 Term 1','B-',35.70,'GenEd','Completed'),(6,'122040156','CSC1001','2022-23 Term 1','B',41.40,'Major','Completed'),(7,'122040156','GFH1000','2022-23 Term 2','C',32.30,'GenEd','Completed'),(8,'122040156','MAT3007','2022-23 Term 2','B-',37.90,'Major','Completed'),(9,'122040156','GED2107','2022-23 Term 2','B',38.30,'GenEd','Completed'),(10,'122040156','CSC3100','2022-23 Term 2','A',51.20,'Major','Completed'),(11,'122040156','PED1002','2022-23 Term 2','C',33.80,'PE','Completed'),(12,'122040156','ENG1001','2023-24 Term 1','A-',46.70,'English','Completed'),(13,'122040156','CSC4140','2023-24 Term 1','B-',35.70,'Major','Completed'),(14,'122040156','CSC3160','2023-24 Term 1','A',50.10,'Major','Completed'),(15,'122040156','CSC4010','2023-24 Term 1','B+',42.30,'Major','Completed'),(16,'122040156','DDA3020','2023-24 Term 1','B-',36.50,'Major','Completed'),(17,'122040156','DDA4220','2023-24 Term 2','B+',45.00,'Major','Completed'),(18,'122040156','GEA2000','2023-24 Term 2','B',40.40,'GenEd','Completed'),(19,'122040156','ENG2001','2023-24 Term 2','A-',46.00,'English','Completed'),(20,'122040156','MAT1002','2023-24 Term 2','C',34.90,'Major','Completed'),(21,'122040156','CSC3050','2023-24 Term 2','A-',46.80,'Major','Completed'),(22,'122040156','CSC4120','2023-24 Summer','A-',47.70,'Major','Completed'),(23,'122040156','CLC1401','2024-25 Term 1','A',50.70,'Chinese','Completed'),(24,'122040156','MAT3280','2024-25 Term 1','B-',37.30,'Major','Completed'),(25,'122040156','CSC3170','2024-25 Term 1','C',34.80,'Major','Completed'),(26,'122040156','CSC4107','2024-25 Term 1','B+',44.00,'Major','Completed'),(27,'122040156','GEC2403','2024-25 Term 1','B+',43.80,'GenEd','Completed'),(28,'122040156','MAT3040','2024-25 Term 2','B',40.60,'Major','Completed'),(29,'122040156','CSC4170','2024-25 Term 2','B',38.20,'Major','Completed'),(30,'122040156','CSC4100','2024-25 Term 2','C',32.00,'Major','Completed'),(31,'122040156','DDA4210','2024-25 Term 2','B+',42.40,'Major','Completed'),(32,'122040156','PHY1001','2024-25 Term 2','C',33.20,'Major','Completed'),(33,'122040156','CSC1002','2025-26 Term 1','B+',44.70,'Major','Completed'),(34,'122040156','CSC4150','2025-26 Term 1','A-',46.80,'Major','Completed'),(35,'122040156','CSC3001','2025-26 Term 1','A',48.90,'Major','Completed'),(36,'122040156','CSC3150','2025-26 Term 1','C',34.70,'Major','Completed'),(37,'122040156','DDA4010','2025-26 Term 1','A',48.40,'Major','Completed'),(38,'122040156','MAT2040','2025-26 Term 1','A-',46.30,'Major','Completed'),(39,'122040156','CSC4160','2025-26 Term 2','B+',43.80,'Major','Completed'),(40,'122040156','ENG1002','2025-26 Term 2','A-',47.20,'English','Completed'),(41,'122040156','MAT3220','2025-26 Term 2','B',41.00,'Major','Completed'),(42,'122040156','DDA4080','2025-26 Term 2','B',38.70,'Major','Completed'),(43,'122040156','CSC4001','2025-26 Term 2','B',39.60,'Major','Completed'),(44,'122040156','MAT1001','2025-26 Term 2','B',38.10,'Major','Completed'),(45,'122040267','MAT3007','2022-23 Term 1','A',49.70,'Major','Completed'),(46,'122040267','DDA4010','2022-23 Term 1','B+',42.60,'Major','Completed'),(47,'122040267','GEB2207','2022-23 Term 1','B',38.70,'GenEd','Completed'),(48,'122040267','DDA4080','2022-23 Term 1','A-',47.90,'Major','Completed'),(49,'122040267','ENG2002S','2022-23 Term 1','A',48.80,'English','Completed'),(50,'122040267','STA2001H','2022-23 Term 2','B',39.30,'Major','Completed'),(51,'122040267','DDA4320','2022-23 Term 2','A-',45.40,'Major','Completed'),(52,'122040267','CSC3100','2022-23 Term 2','B-',35.70,'Major','Completed'),(53,'122040267','ENG1001','2022-23 Term 2','B+',42.60,'English','Completed'),(54,'122040267','DDA2001','2022-23 Term 2','B',38.90,'Major','Completed'),(55,'122040267','MAT1002','2023-24 Term 1','C',33.80,'Major','Completed'),(56,'122040267','MAT3280','2023-24 Term 1','B',38.30,'Major','Completed'),(57,'122040267','MAT1001','2023-24 Term 1','B',38.60,'Major','Completed'),(58,'122040267','ENG1002','2023-24 Term 1','B-',38.00,'English','Completed'),(59,'122040267','DDA4250','2023-24 Term 1','B+',43.90,'Major','Completed'),(60,'122040267','STA2002H','2023-24 Term 1','B+',43.60,'Major','Completed'),(61,'122040267','PHY1001','2023-24 Term 2','A-',45.50,'Major','Completed'),(62,'122040267','DDA4220','2023-24 Term 2','A',50.00,'Major','Completed'),(63,'122040267','ENG2001','2023-24 Term 2','A-',46.40,'English','Completed'),(64,'122040267','GEA2000','2023-24 Term 2','A-',46.60,'GenEd','Completed'),(65,'122040267','GED2107','2023-24 Term 2','B-',35.90,'GenEd','Completed'),(66,'122040267','STA4001','2023-24 Summer','A-',47.80,'Major','Completed'),(67,'122040267','DDA3003','2023-24 Summer','B',41.00,'Major','Completed'),(68,'122040267','DDA4002','2024-25 Term 1','B-',35.40,'Major','Completed'),(69,'122040267','MAT3040','2024-25 Term 1','A-',47.70,'Major','Completed'),(70,'122040267','DDA4260','2024-25 Term 1','B+',44.00,'Major','Completed'),(71,'122040267','MAT3006','2024-25 Term 1','B',41.50,'Major','Completed'),(72,'122040267','DDA4240','2024-25 Term 2','C',34.20,'Major','Completed'),(73,'122040267','DDA4230','2024-25 Term 2','C',32.90,'Major','Completed'),(74,'122040267','ITE1000','2024-25 Term 2','C',35.00,'IT','Completed'),(75,'122040267','DDA3005','2024-25 Term 2','A-',45.90,'Major','Completed'),(76,'122040267','GFN1000','2024-25 Term 2','A-',45.90,'GenEd','Completed'),(77,'122040267','MAT2050','2024-25 Term 2','B',38.40,'Major','Completed'),(78,'122040267','CSC1002','2024-25 Summer','C',33.20,'Major','Completed'),(79,'122040267','DDA3020','2024-25 Summer','B',41.50,'Major','Completed'),(80,'122040267','PED1002','2025-26 Term 1','C',33.40,'PE','Completed'),(81,'122040267','GFH1000','2025-26 Term 1','A-',47.50,'GenEd','Completed'),(82,'122040267','DDA4310','2025-26 Term 1','B-',36.00,'Major','Completed'),(83,'122040267','DDA4210','2025-26 Term 1','B-',37.30,'Major','Completed'),(84,'122040267','CLC1401','2025-26 Term 1','A',49.30,'Chinese','Completed'),(85,'122040267','MAT3220','2025-26 Term 2','A-',46.20,'Major','Completed'),(86,'122040267','MAT2040','2025-26 Term 2','B+',44.60,'Major','Completed'),(87,'122040267','BIO1008','2025-26 Term 2','C',34.40,'Major','Completed'),(88,'122040267','GEC2403','2025-26 Term 2','B-',37.20,'GenEd','Completed'),(89,'122040267','CSC1001','2025-26 Term 2','A-',45.60,'Major','Completed'),(90,'122040384','GFH1000','2022-23 Term 1','A-',45.20,'GenEd','Completed'),(91,'122040384','STA2002','2022-23 Term 1','A-',47.60,'Major','Completed'),(92,'122040384','FMA4200','2022-23 Term 1','C',33.70,'Major','Completed'),(93,'122040384','STA4020','2022-23 Term 1','A',49.80,'Major','Completed'),(94,'122040384','GEB2207','2022-23 Term 1','B',40.30,'GenEd','Completed'),(95,'122040384','MAT3300','2022-23 Term 2','B-',37.20,'Major','Completed'),(96,'122040384','CSC3170','2022-23 Term 2','A',49.60,'Major','Completed'),(97,'122040384','CSC1001','2022-23 Term 2','A',51.20,'Major','Completed'),(98,'122040384','STA2001','2022-23 Term 2','A-',46.70,'Major','Completed'),(99,'122040384','ENG2002S','2022-23 Term 2','A',51.40,'English','Completed'),(100,'122040384','CSC3100','2023-24 Term 1','C',34.00,'Major','Completed'),(101,'122040384','FMA4800','2023-24 Term 1','B-',35.90,'Major','Completed'),(102,'122040384','FIN2020','2023-24 Term 1','A',50.50,'Major','Completed'),(103,'122040384','CSC3001','2023-24 Term 1','A',49.00,'Major','Completed'),(104,'122040384','ENG2001','2023-24 Term 1','A',49.70,'English','Completed'),(105,'122040384','CSC1002','2023-24 Term 2','B-',37.00,'Major','Completed'),(106,'122040384','STA4003','2023-24 Term 2','A-',47.80,'Major','Completed'),(107,'122040384','PED1001','2023-24 Term 2','A',51.30,'PE','Completed'),(108,'122040384','CSC3180','2023-24 Term 2','A-',46.70,'Major','Completed'),(109,'122040384','GEA2000','2023-24 Term 2','B+',43.60,'GenEd','Completed'),(110,'122040384','FIN4110','2023-24 Term 2','B',38.30,'Major','Completed'),(111,'122040384','DDA3020','2023-24 Term 2','B+',42.40,'Major','Completed'),(112,'122040384','FIN4120','2024-25 Term 1','C',34.80,'Major','Completed'),(113,'122040384','ECO2011','2024-25 Term 1','B+',42.70,'Major','Completed'),(114,'122040384','ACT2111','2024-25 Term 1','A-',47.00,'Major','Completed'),(115,'122040384','PED1002','2024-25 Term 1','A-',46.40,'PE','Completed'),(116,'122040384','ECO3160','2024-25 Term 1','B-',36.90,'Major','Completed'),(117,'122040384','GEC2403','2024-25 Term 2','B',38.30,'GenEd','Completed'),(118,'122040384','ENG1001','2024-25 Term 2','B',40.80,'English','Completed'),(119,'122040384','MAT1001','2024-25 Term 2','B',41.90,'Major','Completed'),(120,'122040384','RMS4060','2024-25 Term 2','B',38.70,'Major','Completed'),(121,'122040384','GED2107','2024-25 Term 2','B+',43.50,'GenEd','Completed'),(122,'122040384','FIN4080','2024-25 Summer','A-',47.40,'Major','Completed'),(123,'122040384','FIN4210','2025-26 Term 1','B',40.30,'Major','Completed'),(124,'122040384','FIN3210','2025-26 Term 1','A-',46.40,'Major','Completed'),(125,'122040384','MAT2040','2025-26 Term 1','A-',45.60,'Major','Completed'),(126,'122040384','FIN3080','2025-26 Term 1','A',48.10,'Major','Completed'),(127,'122040384','FIN4060','2025-26 Term 1','B',41.30,'Major','Completed'),(128,'122040384','MAT1002','2025-26 Term 1','C',34.60,'Major','Completed'),(129,'122040384','ENG1002','2025-26 Term 2','A',48.80,'English','Completed'),(130,'122040384','MAT3280','2025-26 Term 2','B+',43.80,'Major','Completed'),(131,'122040384','ECO3121','2025-26 Term 2','A',49.60,'Major','Completed'),(132,'122040384','CSC3002','2025-26 Term 2','B+',42.30,'Major','Completed'),(133,'122040384','MAT2002','2025-26 Term 2','B+',43.90,'Major','Completed'),(134,'122040384','STA4001','2025-26 Term 2','A',48.60,'Major','Completed'),(135,'122040491','RMS4050','2022-23 Term 1','A-',47.00,'Major','Completed'),(136,'122040491','MAT3040','2022-23 Term 1','B',40.20,'Major','Completed'),(137,'122040491','DDA2001','2022-23 Term 1','B-',36.10,'Major','Completed'),(138,'122040491','ENG1002','2022-23 Term 1','B',38.20,'English','Completed'),(139,'122040491','STA3007','2022-23 Term 1','C',33.70,'Major','Completed'),(140,'122040491','GEA2000','2022-23 Term 1','C',32.60,'GenEd','Completed'),(141,'122040491','STA2001H','2022-23 Term 2','B-',35.10,'Major','Completed'),(142,'122040491','MAT2040','2022-23 Term 2','C',33.60,'Major','Completed'),(143,'122040491','STA4030','2022-23 Term 2','C',32.60,'Major','Completed'),(144,'122040491','MAT3220','2022-23 Term 2','B',38.30,'Major','Completed'),(145,'122040491','STA4002','2022-23 Term 2','A',51.60,'Major','Completed'),(146,'122040491','STA4020','2023-24 Term 1','A-',45.30,'Major','Completed'),(147,'122040491','GEC2403','2023-24 Term 1','A',50.70,'GenEd','Completed'),(148,'122040491','CSC3170','2023-24 Term 1','C',34.80,'Major','Completed'),(149,'122040491','STA3005','2023-24 Term 1','A-',45.60,'Major','Completed'),(150,'122040491','ENG2002S','2023-24 Term 1','B+',42.80,'English','Completed'),(151,'122040491','MAT3280','2023-24 Term 2','B-',35.90,'Major','Completed'),(152,'122040491','CSC3100','2023-24 Term 2','C',32.90,'Major','Completed'),(153,'122040491','DDA4080','2023-24 Term 2','A-',45.20,'Major','Completed'),(154,'122040491','GFH1000','2023-24 Term 2','C',33.10,'GenEd','Completed'),(155,'122040491','DDA4002','2024-25 Term 1','A',48.90,'Major','Completed'),(156,'122040491','MAT1002','2024-25 Term 1','B',40.80,'Major','Completed'),(157,'122040491','RMS4001','2024-25 Term 1','B',38.80,'Major','Completed'),(158,'122040491','PED1002','2024-25 Term 1','A',48.30,'PE','Completed'),(159,'122040491','DDA4010','2024-25 Term 1','B-',38.00,'Major','Completed'),(160,'122040491','CLC1401','2024-25 Term 1','A',48.20,'Chinese','Completed'),(161,'122040491','ENG2001','2024-25 Term 2','B+',44.20,'English','Completed'),(162,'122040491','CSC1001','2024-25 Term 2','B-',37.20,'Major','Completed'),(163,'122040491','PHY1001','2024-25 Term 2','B+',44.30,'Major','Completed'),(164,'122040491','MAT2050','2024-25 Term 2','B-',35.20,'Major','Completed'),(165,'122040491','STA4042','2024-25 Term 2','B+',43.90,'Major','Completed'),(166,'122040491','GFN1000','2024-25 Summer','A-',47.70,'GenEd','Completed'),(167,'122040491','PED1001','2024-25 Summer','B',41.60,'PE','Completed'),(168,'122040491','GEB2207','2025-26 Term 1','C',33.40,'GenEd','Completed'),(169,'122040491','STA4041','2025-26 Term 1','A',50.00,'Major','Completed'),(170,'122040491','BIO1008','2025-26 Term 1','B+',44.70,'Major','Completed'),(171,'122040491','CSC1002','2025-26 Term 1','B-',35.10,'Major','Completed'),(172,'122040491','GED2107','2025-26 Term 1','A-',46.80,'GenEd','Completed'),(173,'122040491','MAT3006','2025-26 Term 2','B+',42.40,'Major','Completed'),(174,'122040491','DDA3020','2025-26 Term 2','A',51.70,'Major','Completed'),(175,'122040491','DDA3005','2025-26 Term 2','B-',37.10,'Major','Completed'),(176,'122040491','MAT3007','2025-26 Term 2','A',49.50,'Major','Completed'),(177,'122040491','STA4001','2025-26 Term 2','A-',45.80,'Major','Completed'),(178,'122040491','MAT1001','2025-26 Term 2','B+',44.50,'Major','Completed'),(179,'122010001','ACT2111','2022-23 Term 1','A',37.00,'Major','Completed'),(180,'122010001','CHI1000','2022-23 Term 1','A',32.60,'GenEd','Completed'),(181,'122010001','ECO2011','2022-23 Term 1','B+',34.30,'Major','Completed'),(182,'122010001','ENG1001','2022-23 Term 1','A-',31.20,'English','Completed'),(183,'122010001','ITE1000','2022-23 Term 1','DI',NULL,'IT','Completed'),(184,'122010001','MAT1005','2022-23 Term 1','A',34.60,'Major','Completed'),(185,'122010001','PED1001','2022-23 Term 1','A-',37.90,'PE','Completed'),(186,'122010001','ECO2121','2022-23 Term 2','A-',39.40,'Major','Completed'),(187,'122010001','ENG1002','2022-23 Term 2','A',34.50,'English','Completed'),(188,'122010001','FIN2010','2022-23 Term 2','A',39.60,'Major','Completed'),(189,'122010001','GFH1000','2022-23 Term 2','B+',35.90,'GenEd','Completed'),(190,'122010001','MKT2010','2022-23 Term 2','A',37.20,'Major','Completed'),(191,'122010001','PED1002','2022-23 Term 2','A-',38.50,'PE','Completed'),(192,'122010001','ACT2121','2023-24 Term 1','A',38.70,'Major','Completed'),(193,'122010001','CSC1001','2023-24 Term 1','B+',39.20,'Major','Completed'),(194,'122010001','ECO2021','2023-24 Term 1','B+',37.80,'Major','Completed'),(195,'122010001','ENG2001','2023-24 Term 1','B+',35.20,'English','Completed'),(196,'122010001','GFN1000','2023-24 Term 1','A',38.20,'GenEd','Completed'),(197,'122010001','MGT2020','2023-24 Term 1','B+',38.90,'Major','Completed'),(198,'122010001','ACT3011','2023-24 Term 2','A-',38.00,'Major','Completed'),(199,'122010001','ACT3121','2023-24 Term 2','A-',38.70,'GenEd','Completed'),(200,'122010001','ENG2002B','2023-24 Term 2','A',35.80,'English','Completed'),(201,'122010001','GEC2404','2023-24 Term 2','A-',40.00,'Major','Completed'),(202,'122010001','MIS2051','2023-24 Term 2','A',39.20,'Major','Completed'),(203,'122010001','ACT3141','2024-25 Term 1','A',39.40,'Major','Completed'),(204,'122010001','ACT3154','2024-25 Term 1','A',38.00,'Major','Completed'),(205,'122010001','ACT4131','2024-25 Term 1','A',40.30,'Major','Completed'),(206,'122010001','DMS2030','2024-25 Term 1','A-',39.30,'Major','Completed'),(207,'122010001','GEB2503','2024-25 Term 1','B+',38.80,'GenEd','Completed'),(208,'122010001','ACT3131','2024-25 Term 2','A',39.60,'Major','Completed'),(209,'122010001','ACT3161','2024-25 Term 2','A',34.60,'Major','Completed'),(210,'122010001','MGT4188','2024-25 Term 2','P',NULL,'Major','Completed'),(211,'122010001','ACT4111','2025-26 Term 1','A-',37.60,'Major','Completed'),(212,'122010001','ACT4321','2025-26 Term 1','A-',40.00,'Major','Completed'),(213,'122010001','ECO3121','2025-26 Term 1','B+',39.30,'Major','Completed'),(214,'122010001','IDE3005','2025-26 Term 1','B+',36.40,'Major','Completed'),(215,'122010001','MIS23012','2025-26 Term 1','B+',38.50,'Major','Completed'),(216,'122010001','ACT3321','2025-26 Term 2','B+',36.40,'Major','Completed'),(217,'122010001','ACT4253','2025-26 Term 2','A-',41.20,'Major','Completed'),(218,'122010001','ACT4311','2025-26 Term 2','B+',38.50,'Major','Completed'),(219,'122010001','GEA2000','2025-26 Term 2','B+',36.70,'GenEd','Completed'),(220,'122010001','GED2113','2025-26 Term 2','B+',39.40,'GenEd','Completed'),(221,'123030001','ACT2111','2023-24 Term 1','A',37.00,'Major','Completed'),(222,'123030001','ECO2011','2023-24 Term 1','A',30.60,'Major','Completed'),(223,'123030001','ENG1001','2023-24 Term 1','A',31.20,'English','Completed'),(224,'123030001','ITE1000','2023-24 Term 1','DI',NULL,'IT','Completed'),(225,'123030001','MAT1001','2023-24 Term 1','A',34.60,'Major','Completed'),(226,'123030001','PED1001','2023-24 Term 1','A',37.90,'PE','Completed'),(227,'123030001','CHI1000','2023-24 Term 2','A',32.60,'GenEd','Completed'),(228,'123030001','ECO2121','2023-24 Term 2','A',39.40,'Major','Completed'),(229,'123030001','ENG1002','2023-24 Term 2','A-',34.50,'English','Completed'),(230,'123030001','FIN2010','2023-24 Term 2','A',39.60,'Major','Completed'),(231,'123030001','GFH1000','2023-24 Term 2','A-',35.90,'GenEd','Completed'),(232,'123030001','MKT2010','2023-24 Term 2','A',37.20,'Major','Completed'),(233,'123030001','GEA2000','2023-24 Summer','A',40.30,'GenEd','Completed'),(234,'123030001','PED1002','2024-25 Term 1','A-',38.50,'PE','Completed'),(235,'123030001','ACT2121','2024-25 Term 1','A',38.70,'Major','Completed'),(236,'123030001','MIS2051','2024-25 Term 1','A',31.50,'Major','Completed'),(237,'123030001','ECO2021','2024-25 Term 1','A',37.80,'Major','Completed'),(238,'123030001','ENG2001','2024-25 Term 1','A-',35.20,'English','Completed'),(239,'123030001','DMS2030','2024-25 Term 1','A',37.20,'Major','Completed'),(240,'123030001','ACT3011','2024-25 Term 2','A-',38.00,'Major','Completed'),(241,'123030001','ACT3121','2024-25 Term 2','A-',38.70,'GenEd','Completed'),(242,'123030001','MGT2020','2024-25 Term 2','A',41.60,'Major','Completed'),(243,'123030001','GEB2103','2024-25 Term 2','A-',32.10,'GenEd','Completed'),(244,'123030001','ENG2002B','2024-25 Term 2','A',35.80,'English','Completed'),(245,'123030001','ACT3141','2025-26 Term 1','A',39.40,'Major','Completed'),(246,'123030001','ACT3154','2025-26 Term 1','A',38.00,'Major','Completed'),(247,'123030001','ACT4131','2025-26 Term 1','A',40.30,'Major','Completed'),(248,'123030001','ACT4121','2025-26 Term 1','A',39.80,'Major','Completed'),(249,'123030001','GEC2106','2025-26 Term 1','A',48.40,'GenEd','Completed'),(250,'123030001','ACT3131','2025-26 Term 2','A',39.60,'Major','Completed'),(251,'123030001','ACT3161','2025-26 Term 2','A',34.60,'Major','Completed'),(252,'123030001','ACT4213','2025-26 Term 2','A-',47.20,'Major','Completed'),(253,'123030001','ACT4111','2025-26 Term 2','A-',41.00,'Major','Completed'),(254,'124010001','ACT2111','2024-25 Term 1','B+',37.00,'Major','Completed'),(255,'124010001','CHI1000','2024-25 Term 1','B',32.60,'Chinese','Completed'),(256,'124010001','ECO2011','2024-25 Term 1','B+',34.30,'Major','Completed'),(257,'124010001','ENG1001','2024-25 Term 1','B',31.20,'English','Completed'),(258,'124010001','MAT1005','2024-25 Term 1','C',34.60,'Major','Completed'),(259,'124010001','PED1001','2024-25 Term 1','A-',37.90,'PE','Completed'),(260,'124010001','ITE1000','2024-25 Term 2','PA',NULL,'IT','Completed'),(261,'124010001','ECO2121','2024-25 Term 2','C+',39.40,'Major','Completed'),(262,'124010001','ENG1002','2024-25 Term 2','B+',34.50,'English','Completed'),(263,'124010001','FIN2010','2024-25 Term 2','B',39.60,'Major','Completed'),(264,'124010001','MKT2010','2024-25 Term 2','A-',37.20,'Major','Completed'),(265,'124010001','PED1002','2024-25 Term 2','A-',38.50,'PE','Completed'),(266,'124010001','GFH1000','2024-25 Term 2','B+',35.90,'GenEd','Completed'),(267,'124010001','ACT2121','2025-26 Term 1','A',38.70,'Major','Completed'),(268,'124010001','CSC1001','2025-26 Term 1','B',39.20,'Major','Completed'),(269,'124010001','ECO2021','2025-26 Term 1','B+',37.80,'Major','Completed'),(270,'124010001','ENG2001','2025-26 Term 1','B-',35.20,'English','Completed'),(271,'124010001','MGT2020','2025-26 Term 1','B+',38.90,'Major','Completed'),(272,'124010001','GFN1000','2025-26 Term 2','C',38.20,'GenEd','Completed'),(273,'124010001','ACT3011','2025-26 Term 2','B+',38.00,'Major','Completed'),(274,'124010001','ACT3121','2025-26 Term 2','B',38.70,'GenEd','Completed'),(275,'124010001','ENG2002B','2025-26 Term 2','B',35.80,'English','Completed'),(276,'124010001','MIS2051','2025-26 Term 2','A-',39.20,'Major','Completed'),(277,'125030003','ACT2111','2025-26 Term 1','B',37.00,'Major','Completed'),(278,'125030003','CHI1000','2025-26 Term 1','C',32.60,'Chinese','Completed'),(279,'125030003','ECO2011','2025-26 Term 1','B+',34.30,'Major','Completed'),(280,'125030003','ENG1001','2025-26 Term 1','C+',31.20,'English','Completed'),(281,'125030003','ITE1000','2025-26 Term 1','PA',NULL,'IT','Completed'),(282,'125030003','MAT1001','2025-26 Term 1','A-',34.60,'Major','Completed'),(283,'125030003','PED1001','2025-26 Term 2','A',37.90,'PE','Completed'),(284,'125030003','ECO2121','2025-26 Term 2','B+',39.40,'Major','Completed'),(285,'125030003','ENG1002','2025-26 Term 2','B-',34.50,'English','Completed'),(286,'125030003','FIN2010','2025-26 Term 2','A-',39.60,'Major','Completed'),(287,'125030003','GFH1000','2025-26 Term 2','B+',35.90,'GenEd','Completed'),(288,'125030003','MKT2010','2025-26 Term 2','B',37.20,'Major','Completed');
/*!40000 ALTER TABLE `enrollment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gpa_history`
--

DROP TABLE IF EXISTS `gpa_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gpa_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `semester` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `units_passed` int DEFAULT NULL,
  `term_gpa` decimal(4,3) DEFAULT NULL,
  `cumulative_units` int DEFAULT NULL,
  `cumulative_gpa` decimal(4,3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `gpa_history_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gpa_history`
--

LOCK TABLES `gpa_history` WRITE;
/*!40000 ALTER TABLE `gpa_history` DISABLE KEYS */;
INSERT INTO `gpa_history` VALUES (1,'122040156','2022-23 Term 1',16,3.183,16,3.183),(2,'122040156','2022-23 Term 2',13,2.740,29,2.962),(3,'122040156','2023-24 Term 1',15,3.280,44,3.068),(4,'122040156','2023-24 Term 2',15,3.140,59,3.086),(5,'122040156','2023-24 Summer',3,3.700,62,3.209),(6,'122040156','2024-25 Term 1',15,3.060,77,3.184),(7,'122040156','2024-25 Term 2',15,2.660,92,3.109),(8,'122040156','2025-26 Term 1',16,3.600,108,3.152),(9,'122040156','2025-26 Term 2',18,2.700,126,3.153),(10,'122040267','2022-23 Term 1',15,3.600,15,3.600),(11,'122040267','2022-23 Term 2',14,3.140,29,3.370),(12,'122040267','2023-24 Term 1',18,2.883,47,3.208),(13,'122040267','2023-24 Term 2',15,3.560,62,3.296),(14,'122040267','2023-24 Summer',6,3.350,68,3.307),(15,'122040267','2024-25 Term 1',12,3.175,80,3.285),(16,'122040267','2024-25 Term 2',16,2.733,96,3.206),(17,'122040267','2024-25 Summer',4,2.500,100,3.118),(18,'122040267','2025-26 Term 1',13,3.020,113,3.107),(19,'122040267','2025-26 Term 2',15,3.080,128,3.104),(20,'122040384','2022-23 Term 1',15,3.280,15,3.280),(21,'122040384','2022-23 Term 2',15,3.680,30,3.480),(22,'122040384','2023-24 Term 1',15,3.340,45,3.433),(23,'122040384','2023-24 Term 2',17,3.394,62,3.423),(24,'122040384','2024-25 Term 1',13,2.985,75,3.347),(25,'122040384','2024-25 Term 2',15,3.060,90,3.299),(26,'122040384','2024-25 Summer',3,3.700,93,3.312),(27,'122040384','2025-26 Term 1',18,3.233,111,3.299),(28,'122040384','2025-26 Term 2',18,3.650,129,3.348),(29,'122040491','2022-23 Term 1',18,2.733,18,2.733),(30,'122040491','2022-23 Term 2',15,2.740,33,2.736),(31,'122040491','2023-24 Term 1',15,3.340,48,2.925),(32,'122040491','2023-24 Term 2',12,2.600,60,2.860),(33,'122040491','2024-25 Term 1',16,3.381,76,2.970),(34,'122040491','2024-25 Term 2',15,3.060,91,2.985),(35,'122040491','2024-25 Summer',4,3.525,95,3.007),(36,'122040491','2025-26 Term 1',13,3.400,108,3.031),(37,'122040491','2025-26 Term 2',18,3.000,126,3.098),(38,'122010001','2022-23 Term 1',17,3.796,17,3.796),(39,'122010001','2022-23 Term 2',16,3.741,33,3.768),(40,'122010001','2023-24 Term 1',18,3.627,51,3.702),(41,'122010001','2023-24 Term 2',15,3.790,66,3.732),(42,'122010001','2024-25 Term 1',15,3.722,81,3.729),(43,'122010001','2024-25 Term 2',9,4.000,90,3.734),(44,'122010001','2025-26 Term 1',15,3.472,105,3.700),(45,'122010001','2025-26 Term 2',15,3.358,120,3.672),(46,'123030001','2023-24 Term 1',14,4.000,14,4.000),(47,'123030001','2023-24 Term 2',18,3.847,32,3.926),(48,'123030001','2023-24 Summer',3,4.000,35,3.930),(49,'123030001','2024-25 Term 1',16,3.794,51,3.864),(50,'123030001','2024-25 Term 2',15,3.762,66,3.801),(51,'123030001','2025-26 Term 1',15,3.900,81,3.902),(52,'123030001','2025-26 Term 2',12,3.400,93,3.911),(53,'124010001','2024-25 Term 1',16,3.251,16,3.251),(54,'124010001','2024-25 Term 2',17,2.965,33,3.176),(55,'124010001','2025-26 Term 1',15,3.304,48,3.242),(56,'124010001','2025-26 Term 2',15,3.156,63,3.169),(57,'125030003','2025-26 Term 1',16,2.672,16,2.672),(58,'125030003','2025-26 Term 2',16,3.094,32,2.883);
/*!40000 ALTER TABLE `gpa_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `advisor_contact_log`
--

DROP TABLE IF EXISTS `advisor_contact_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `advisor_contact_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `advisor_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_date` date NOT NULL,
  `contact_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `advisor_id` (`advisor_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `advisor_contact_log_ibfk_1` FOREIGN KEY (`advisor_id`) REFERENCES `advisors` (`advisor_id`),
  CONSTRAINT `advisor_contact_log_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advisor_contact_log`
--

LOCK TABLES `advisor_contact_log` WRITE;
/*!40000 ALTER TABLE `advisor_contact_log` DISABLE KEYS */;
INSERT INTO `advisor_contact_log` VALUES (43,'SDS001','122040156','2025-11-15','email','Discussed course progress and academic plan'),(45,'SDS001','122040384','2026-04-26','message','Discussed course progress and academic plan'),(46,'SDS001','122040384','2025-12-19','phone','Discussed course progress and academic plan'),(47,'SDS002','122040267','2026-04-22','meeting','Discussed course progress and academic plan'),(48,'SDS002','122040267','2026-04-01','phone','Discussed course progress and academic plan'),(49,'SDS002','122040267','2025-12-13','phone','Discussed course progress and academic plan'),(52,'SME001','122010001','2026-04-18','email','Discussed course progress and academic plan'),(53,'SME001','122010001','2026-02-14','message','Discussed course progress and academic plan'),(54,'SME001','122010001','2026-04-09','email','Discussed course progress and academic plan'),(55,'SME001','124010001','2026-03-30','meeting','Discussed course progress and academic plan'),(56,'SME001','124010001','2026-04-30','phone','Discussed course progress and academic plan'),(57,'SME002','123030001','2025-12-01','phone','Discussed course progress and academic plan'),(58,'SME002','123030001','2025-12-01','email','Discussed course progress and academic plan'),(59,'SME002','123030001','2025-12-01','phone','Discussed course progress and academic plan'),(60,'SME002','125030003','2026-03-14','phone','Discussed course progress and academic plan'),(61,'SME002','125030003','2026-05-02','message','Discussed course progress and academic plan'),(62,'SME002','125030003','2025-12-25','message','Discussed course progress and academic plan'),(63,'SDS001','122040384','2026-05-06','meeting','Follow-up on project and exam plan'),(64,'SME001','124010001','2026-02-04','email','Early semester check-in'),(65,'SME001','124010001','2026-05-08','message','Reminder about registration timeline');
/*!40000 ALTER TABLE `advisor_contact_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `majors`
--

DROP TABLE IF EXISTS `majors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `majors` (
  `major_id` int NOT NULL AUTO_INCREMENT,
  `major_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `school_id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`major_id`),
  UNIQUE KEY `major_name` (`major_name`),
  KEY `school_id` (`school_id`),
  CONSTRAINT `majors_ibfk_1` FOREIGN KEY (`school_id`) REFERENCES `schools` (`school_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `majors`
--

LOCK TABLES `majors` WRITE;
/*!40000 ALTER TABLE `majors` DISABLE KEYS */;
INSERT INTO `majors` VALUES (1,'Accounting Data and Analytics','SME'),(2,'Computer Science and Engineering','SDS'),(3,'Data Science and Big Data Technology','SDS'),(4,'Financial Engineering - Quantitative Finance','SDS'),(5,'Statistics','SDS'),(6,'Accounting and Financial Reporting','SME');
/*!40000 ALTER TABLE `majors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schools`
--

DROP TABLE IF EXISTS `schools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schools` (
  `school_id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `school_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`school_id`),
  UNIQUE KEY `school_name` (`school_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schools`
--

LOCK TABLES `schools` WRITE;
/*!40000 ALTER TABLE `schools` DISABLE KEYS */;
INSERT INTO `schools` VALUES ('SDS','School of Data Science'),('SME','School of Management and Economics');
/*!40000 ALTER TABLE `schools` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-12 17:10:37
