/*
Navicat MySQL Data Transfer

Source Server         : root
Source Server Version : 50505
Source Host           : localhost:3306
Source Database       : nuwmhostels

Target Server Type    : MYSQL
Target Server Version : 50505
File Encoding         : 65001

Date: 2022-10-30 20:49:14
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `hostels`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `hostels` (
  `Id_hostel` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Id_manager` int(11) unsigned DEFAULT NULL,
  `number` int(2) unsigned NOT NULL DEFAULT 0,
  `adress` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Id_hostel`),
  KEY `managers` (`Id_manager`),
  CONSTRAINT `managers` FOREIGN KEY (`Id_manager`) REFERENCES `managers` (`Id_manager`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of hostels
-- ----------------------------
INSERT IGNORE INTO `hostels` VALUES ('1', '1', '1', 'St. Chornovola, 51');
INSERT IGNORE INTO `hostels` VALUES ('2', '2', '2', 'St. Chornovola, 55');
INSERT IGNORE INTO `hostels` VALUES ('3', '3', '3', 'St. Miryushchenko, 62');
INSERT IGNORE INTO `hostels` VALUES ('4', '4', '4', 'St. Miryushchenko, 60');
INSERT IGNORE INTO `hostels` VALUES ('5', '5', '5', 'St. Volynsk, 24');
INSERT IGNORE INTO `hostels` VALUES ('6', '6', '6', 'St. Chornovola, 53');
INSERT IGNORE INTO `hostels` VALUES ('7', '1', '7', '1');
INSERT IGNORE INTO `hostels` VALUES ('8', '6', '10', '6666');
INSERT IGNORE INTO `hostels` VALUES ('10', '1', '11', '');

-- ----------------------------
-- Table structure for `instruction_safety`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `instruction_safety` (
  `Id_instruction` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Id_manager` int(11) unsigned DEFAULT NULL,
  `date` date DEFAULT NULL,
  `type_instruction` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Id_instruction`),
  KEY `managerss` (`Id_manager`),
  CONSTRAINT `managerss` FOREIGN KEY (`Id_manager`) REFERENCES `managers` (`Id_manager`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of instruction_safety
-- ----------------------------
INSERT IGNORE INTO `instruction_safety` VALUES ('1', '1', '2020-08-30', 'primary');
INSERT IGNORE INTO `instruction_safety` VALUES ('2', '2', '2020-08-29', 'primary');
INSERT IGNORE INTO `instruction_safety` VALUES ('3', '3', '2020-09-01', 'primary');
INSERT IGNORE INTO `instruction_safety` VALUES ('4', '4', '2020-08-30', 'primary');
INSERT IGNORE INTO `instruction_safety` VALUES ('5', '5', '2020-08-30', 'primary');
INSERT IGNORE INTO `instruction_safety` VALUES ('6', '6', '2020-09-01', 'primary');
INSERT IGNORE INTO `instruction_safety` VALUES ('7', '1', '2021-02-28', 'second');
INSERT IGNORE INTO `instruction_safety` VALUES ('8', '2', '2021-02-27', 'second');
INSERT IGNORE INTO `instruction_safety` VALUES ('9', '3', '2021-03-01', 'second');
INSERT IGNORE INTO `instruction_safety` VALUES ('10', '4', '2021-03-05', 'second');
INSERT IGNORE INTO `instruction_safety` VALUES ('11', '5', '2021-02-25', 'second');
INSERT IGNORE INTO `instruction_safety` VALUES ('12', '6', '2021-02-25', 'second');
INSERT IGNORE INTO `instruction_safety` VALUES ('13', '2', '2022-10-17', 'primary');
INSERT IGNORE INTO `instruction_safety` VALUES ('14', '2', '2022-10-17', 'primary');

-- ----------------------------
-- Table structure for `managers`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `managers` (
  `Id_manager` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `pib` varchar(100) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `e_mail` varchar(100) DEFAULT NULL,
  `parol` varchar(255) NOT NULL DEFAULT '',
  `prava` varchar(255) NOT NULL DEFAULT 'admin',
  PRIMARY KEY (`Id_manager`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of managers
-- ----------------------------
INSERT IGNORE INTO `managers` VALUES ('1', 'Maria Karlivna Tsymokh', '0978866502', 'karlivna.manager@nuwm.edu.ua', '1', 'admin');
INSERT IGNORE INTO `managers` VALUES ('2', 'Lyudmila Mykolaivna Sharabura', '0978866740', 'sharabura.manager@nuwm.edu.ua', '2', 'admin');
INSERT IGNORE INTO `managers` VALUES ('3', 'Cherniy Svitlana Ivanovna', '0738086674', 'chernii.manager@nuwm.edu.ua', '3', 'admin');
INSERT IGNORE INTO `managers` VALUES ('4', 'Halyna Mykolaivna Popelnytska', '0678563241', 'popelnytska.manager@nuwm.edu.ua', '4', 'admin');
INSERT IGNORE INTO `managers` VALUES ('5', 'Yakimov Yaroslava Stepanivna', '0671563248', 'yakymiv.manager@nuwm.edu.ua', '5', 'admin');
INSERT IGNORE INTO `managers` VALUES ('6', 'Olga Vasylivna Chemakina', '0978563214', 'chemakina.manager@nuwm.edu.ua', '6', 'admin');
INSERT IGNORE INTO `managers` VALUES ('7', 'Full name', '123123', 'E-ee', '7', 'admin');

-- ----------------------------
-- Table structure for `payment`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `payment` (
  `Id_payment` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Id_student` int(11) unsigned DEFAULT NULL,
  `date_payment` date DEFAULT NULL,
  `amount` float(6,0) DEFAULT NULL,
  `appointment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id_payment`),
  KEY `payment` (`Id_student`),
  CONSTRAINT `payment` FOREIGN KEY (`Id_student`) REFERENCES `students` (`Id_student`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of payment
-- ----------------------------
INSERT IGNORE INTO `payment` VALUES ('1', '1', '2020-08-31', '7080', 'payment per year');
INSERT IGNORE INTO `payment` VALUES ('2', '2', '2020-08-30', '3540', 'payment for six months');
INSERT IGNORE INTO `payment` VALUES ('3', '3', '2020-08-30', '590', 'payment for September');
INSERT IGNORE INTO `payment` VALUES ('4', '4', '2020-08-31', '3540', 'payment for six months');
INSERT IGNORE INTO `payment` VALUES ('5', '5', '2020-08-25', '7080', 'payment per year');
INSERT IGNORE INTO `payment` VALUES ('6', '6', '2020-08-27', '590', 'payment for September');
INSERT IGNORE INTO `payment` VALUES ('7', '3', '2020-09-30', '590', 'payment for October');
INSERT IGNORE INTO `payment` VALUES ('8', '6', '2020-09-27', '590', 'payment for October');
INSERT IGNORE INTO `payment` VALUES ('9', '7', '2020-09-30', '200', 'property compensation');

-- ----------------------------
-- Table structure for `profit`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `profit` (
  `Id_profit` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Id_student` int(11) unsigned DEFAULT NULL,
  `date_profit` date DEFAULT NULL,
  `amount` float(6,0) DEFAULT NULL,
  `type_profit` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Id_profit`),
  KEY `profit` (`Id_student`),
  CONSTRAINT `profit` FOREIGN KEY (`Id_student`) REFERENCES `students` (`Id_student`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of profit
-- ----------------------------
INSERT IGNORE INTO `profit` VALUES ('1', '1', '2020-08-31', '7080', 'residence');
INSERT IGNORE INTO `profit` VALUES ('2', '2', '2020-08-30', '3540', 'residence');
INSERT IGNORE INTO `profit` VALUES ('3', '3', '2020-08-30', '590', 'residence');
INSERT IGNORE INTO `profit` VALUES ('4', '4', '2020-08-31', '3540', 'residence');
INSERT IGNORE INTO `profit` VALUES ('5', '1', '2022-10-04', '6000', 'repair');
INSERT IGNORE INTO `profit` VALUES ('8', '1', '2022-10-05', '30000', 'repair');

-- ----------------------------
-- Table structure for `rooms`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `rooms` (
  `Id_room` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Id_hostel` int(11) unsigned DEFAULT NULL,
  `number_room` varchar(10) DEFAULT NULL,
  `number_seats` int(11) unsigned DEFAULT NULL,
  `characteristic` varchar(255) DEFAULT NULL,
  `date_last_repair` date DEFAULT NULL,
  PRIMARY KEY (`Id_room`),
  KEY `hostels` (`Id_hostel`),
  CONSTRAINT `hostels` FOREIGN KEY (`Id_hostel`) REFERENCES `hostels` (`Id_hostel`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of rooms
-- ----------------------------
INSERT IGNORE INTO `rooms` VALUES ('1', '1', '1101', '3', '3 beds, 2 tables, 3 chairs', '2020-08-29');
INSERT IGNORE INTO `rooms` VALUES ('2', '1', '1102', '3', '3 beds, 1 стіл, 3 chairs', '2019-08-30');
INSERT IGNORE INTO `rooms` VALUES ('3', '1', '1103', '3', '3 beds, 1 стіл, 3 chairs, a shelf', '2017-08-17');
INSERT IGNORE INTO `rooms` VALUES ('4', '1', '1201', '3', '3 beds, 2 tables, 3 chairs', '2020-08-29');
INSERT IGNORE INTO `rooms` VALUES ('5', '1', '1202', '3', '3 beds, 1 стіл, 3 chairs', '2019-08-27');
INSERT IGNORE INTO `rooms` VALUES ('6', '10', '6', '5', '3 beds, 1 стіл, 3 chairs, a shelf aaaa', '2022-08-31');
INSERT IGNORE INTO `rooms` VALUES ('7', '2', '2101', '3', '3 beds, 1 стіл, 3 chairs', '2018-09-02');
INSERT IGNORE INTO `rooms` VALUES ('8', '2', '2102', '3', '3 beds, 1 стіл, 3 chairs, a shelf', '2020-08-01');
INSERT IGNORE INTO `rooms` VALUES ('9', '2', '2103', '3', '3 beds, 2 tables, 3 chairs', '2019-09-02');
INSERT IGNORE INTO `rooms` VALUES ('10', '2', '2201', '3', '3 beds, 2 tables, 3 chairs', '2019-08-27');
INSERT IGNORE INTO `rooms` VALUES ('11', '2', '2202', '3', '3 beds, 1 стіл, 3 chairs', '2020-08-17');
INSERT IGNORE INTO `rooms` VALUES ('12', '2', '2203', '3', '3 beds, 1 стіл, 3 chairs, a shelf', '2019-08-04');
INSERT IGNORE INTO `rooms` VALUES ('13', '3', '3101', '3', '3 beds, 1 стіл, 3 chairs', '2019-08-28');
INSERT IGNORE INTO `rooms` VALUES ('14', '3', '3102', '3', '3 beds, 1 стіл, 3 chairs', '2020-08-28');
INSERT IGNORE INTO `rooms` VALUES ('15', '3', '3201', '3', '3 beds, 1 стіл, 3 chairs, a shelf', '2019-08-01');
INSERT IGNORE INTO `rooms` VALUES ('16', '3', '3202', '3', '3 beds, 2 tables, 3 chairs', '2018-09-03');
INSERT IGNORE INTO `rooms` VALUES ('17', '4', '4101', '3', '3 beds, 2 tables, 3 chairs', '2017-09-01');
INSERT IGNORE INTO `rooms` VALUES ('18', '4', '4102', '3', '3 beds, 1 стіл, 3 chairs, a shelf', '2019-08-28');
INSERT IGNORE INTO `rooms` VALUES ('19', '4', '4201', '3', '3 beds, 2 tables, 3 chairs', '2020-07-30');
INSERT IGNORE INTO `rooms` VALUES ('20', '4', '4202', '3', '3 beds, 1 стіл, 3 chairs, a shelf', '2015-07-26');
INSERT IGNORE INTO `rooms` VALUES ('21', '5', '5101', '3', '3 beds, 2 tables, 3 chairs', '2019-08-21');
INSERT IGNORE INTO `rooms` VALUES ('22', '5', '5102', '3', '3 beds, 1 стіл, 3 chairs, a shelf', '2020-09-11');
INSERT IGNORE INTO `rooms` VALUES ('23', '5', '5201', '3', '3 beds, 1 стіл, 3 chairs', '2020-09-18');
INSERT IGNORE INTO `rooms` VALUES ('24', '5', '5202', '3', '3 beds, 1 стіл, 3 chairs, a shelf', '2019-08-15');
INSERT IGNORE INTO `rooms` VALUES ('25', '6', '6101', '4', '4 beds, 1 стіл, 3 chairs, a shelf', '2018-08-14');
INSERT IGNORE INTO `rooms` VALUES ('26', '6', '6102', '4', '3 beds, 1 стіл, 4 chairs, a shelf', '2018-07-29');
INSERT IGNORE INTO `rooms` VALUES ('27', '6', '6201', '4', '4 beds, 2 стіл, 3 chairs', '2016-09-01');
INSERT IGNORE INTO `rooms` VALUES ('28', '6', '6202', '4', '4 beds, 1 стіл, 3 chairs, a shelf', '2015-08-02');
INSERT IGNORE INTO `rooms` VALUES ('30', '4', '111', '511', '-1', '2022-08-29');

-- ----------------------------
-- Table structure for `specialties`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `specialties` (
  `Id_specialty` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `code_specialty` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Id_specialty`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of specialties
-- ----------------------------
INSERT IGNORE INTO `specialties` VALUES ('1', '051', 'Economy');
INSERT IGNORE INTO `specialties` VALUES ('2', '061', 'Journalism');
INSERT IGNORE INTO `specialties` VALUES ('3', '073', 'Management');
INSERT IGNORE INTO `specialties` VALUES ('4', '075', 'Marketing');
INSERT IGNORE INTO `specialties` VALUES ('5', '081', 'Right');
INSERT IGNORE INTO `specialties` VALUES ('6', '101', 'Ecology');
INSERT IGNORE INTO `specialties` VALUES ('7', '113', 'Applied Mathematics');
INSERT IGNORE INTO `specialties` VALUES ('9', '122', 'Computer Science');
INSERT IGNORE INTO `specialties` VALUES ('10', '123', 'Computer Engineering');
INSERT IGNORE INTO `specialties` VALUES ('11', '126', 'Information systems and technologies');
INSERT IGNORE INTO `specialties` VALUES ('12', '133', 'Industrial engineering');
INSERT IGNORE INTO `specialties` VALUES ('13', '141', 'Electric power engineering, electrical engineering and electromechanics');
INSERT IGNORE INTO `specialties` VALUES ('14', '144', 'Thermal power engineering');
INSERT IGNORE INTO `specialties` VALUES ('15', '151', 'Automation and computer-integrated technologies');
INSERT IGNORE INTO `specialties` VALUES ('16', '171', 'Electronics');
INSERT IGNORE INTO `specialties` VALUES ('17', '184', 'Mining');
INSERT IGNORE INTO `specialties` VALUES ('18', '227', 'Physical therapy, occupational therapy');
INSERT IGNORE INTO `specialties` VALUES ('19', '281', 'Public management and administration');
INSERT IGNORE INTO `specialties` VALUES ('21', '015', 'Specialty');

-- ----------------------------
-- Table structure for `students`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `students` (
  `Id_student` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Id_room` int(11) unsigned DEFAULT NULL,
  `Id_specialty` int(11) unsigned DEFAULT NULL,
  `pib` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `e_mail` varchar(100) DEFAULT NULL,
  `adress` varchar(255) DEFAULT NULL,
  `foreigner` tinyint(1) DEFAULT NULL,
  `year_entry` varchar(4) DEFAULT NULL,
  `date_leave` date DEFAULT NULL,
  PRIMARY KEY (`Id_student`),
  KEY `specialty` (`Id_specialty`),
  KEY `rooms` (`Id_room`),
  CONSTRAINT `rooms` FOREIGN KEY (`Id_room`) REFERENCES `rooms` (`Id_room`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `specialty` FOREIGN KEY (`Id_specialty`) REFERENCES `specialties` (`Id_specialty`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of students
-- ----------------------------
INSERT IGNORE INTO `students` VALUES ('1', '1', '14', 'Petro Dmytrovych Morochenets', '0654789214', 'mischenko_bg17.nuwm.edu.ua', 'm. Netishyn str. Soborna 31', '0', '2017', '2022-12-25');
INSERT IGNORE INTO `students` VALUES ('2', '1', '14', 'Oleksandr Leonidovych Onishchuk', '0974789214', 'onischyk_bg17.nuwm.edu.ua', 'm. Slavuta str. Kyivska 2', '0', '2017', '2022-10-02');
INSERT IGNORE INTO `students` VALUES ('3', '1', '14', 'Leonid Volodymyrovych Petrenko', '0970789211', 'petrenko_bg17.nuwm.edu.ua', 'with. Belka str. Sports 89', '0', '2017', '2022-10-02');
INSERT IGNORE INTO `students` VALUES ('4', '2', '14', 'Olena Mykolayivna Derun', '0678541258', 'deryn_bg20.nuwm.edu.ua', 'Zdolbuniv str. Mir 45', '0', '2020', '2022-12-24');
INSERT IGNORE INTO `students` VALUES ('5', '2', '14', 'Larisa Vasylivna Snake', '0678541295', 'zmii_bg19.nuwm.edu.ua', 'Zdolbuniv str. Derevyana 31', '0', '2019', null);
INSERT IGNORE INTO `students` VALUES ('6', '7', '1', 'Tagay Tagay Tygranovych', '0987452143', 'tagaev_em18.nuwm.edu.ua', 'Istanbul', '1', '2018', null);
INSERT IGNORE INTO `students` VALUES ('7', '7', '1', 'Sargsyan Mykhael Mukhamedovych', '0963257400', 'sargsyan_em19.nuwm.edu.ua', 'Istanbul', '1', '2017', null);
INSERT IGNORE INTO `students` VALUES ('8', '8', '3', 'Iryna Fedorivna Kryvko', '0678514589', 'kruvko_em19.nuwm.edu.ua', 'c. Netreba st. Victories 4', '0', '2019', null);
INSERT IGNORE INTO `students` VALUES ('9', '8', '4', 'Rivna Diana Timofievna', '0731102258', 'rivna_em17.nuwm.edu.ua', 'Lviv, st. Nova 56', '0', '2017', null);
INSERT IGNORE INTO `students` VALUES ('10', null, '1', null, null, 'holovko@ukr.net', 'klkjl', '0', '2020', '2022-10-04');
INSERT IGNORE INTO `students` VALUES ('11', '1', '1', 'Nakonechna Yu.A.', '123123', 'email@mail', '1', '0', '2020', '2022-10-20');
INSERT IGNORE INTO `students` VALUES ('12', '1', '2', 'Nakonechna Yu.A.', '123', 'email@mail', 'klkjl', null, '2020', '2022-10-21');

-- ----------------------------
-- Table structure for `students_instruction`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `students_instruction` (
  `Id_st_instruction` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Id_instruction` int(11) unsigned DEFAULT NULL,
  `Id_student` int(11) unsigned DEFAULT NULL,
  `additionally` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id_st_instruction`),
  KEY `instruction` (`Id_instruction`),
  KEY `srudents` (`Id_student`),
  CONSTRAINT `instruction` FOREIGN KEY (`Id_instruction`) REFERENCES `instruction_safety` (`Id_instruction`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `srudents` FOREIGN KEY (`Id_student`) REFERENCES `students` (`Id_student`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of students_instruction
-- ----------------------------
INSERT IGNORE INTO `students_instruction` VALUES ('1', '1', '1', 'instructed');
INSERT IGNORE INTO `students_instruction` VALUES ('2', '1', '2', 'instructed');
INSERT IGNORE INTO `students_instruction` VALUES ('3', '1', '3', 'instructed');
INSERT IGNORE INTO `students_instruction` VALUES ('4', '1', '4', 'instructed');
INSERT IGNORE INTO `students_instruction` VALUES ('5', '1', '5', 'instructed');
INSERT IGNORE INTO `students_instruction` VALUES ('6', '2', '6', 'instructed');
INSERT IGNORE INTO `students_instruction` VALUES ('7', '2', '7', 'instructed');
INSERT IGNORE INTO `students_instruction` VALUES ('8', '2', '10', '');
INSERT IGNORE INTO `students_instruction` VALUES ('9', '1', '7', 'instructed');
INSERT IGNORE INTO `students_instruction` VALUES ('12', '1', '4', 'instructed');

-- ----------------------------
-- Table structure for `visiting`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `visiting` (
  `Id_visiting` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Id_student` int(11) unsigned DEFAULT NULL,
  `data_visitor` varchar(100) DEFAULT NULL,
  `time_e` datetime DEFAULT NULL,
  `exit_entrance` tinyint(3) DEFAULT NULL,
  PRIMARY KEY (`Id_visiting`),
  KEY `students` (`Id_student`),
  CONSTRAINT `students` FOREIGN KEY (`Id_student`) REFERENCES `students` (`Id_student`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of visiting
-- ----------------------------
INSERT IGNORE INTO `visiting` VALUES ('1', '1', null, '2021-02-01 10:20:56', '1');
INSERT IGNORE INTO `visiting` VALUES ('2', '2', null, '2021-02-01 09:00:56', '1');
INSERT IGNORE INTO `visiting` VALUES ('3', null, 'Electrician Oleksandr', '2021-02-01 08:00:00', '1');
INSERT IGNORE INTO `visiting` VALUES ('4', '3', null, '2021-02-01 16:00:00', '0');
INSERT IGNORE INTO `visiting` VALUES ('5', '4', null, '2021-03-04 13:24:13', '0');
INSERT IGNORE INTO `visiting` VALUES ('6', null, 'Plumber Petro', '2021-04-08 18:26:15', '0');
INSERT IGNORE INTO `visiting` VALUES ('7', '1', null, '2021-04-14 13:26:50', '0');
INSERT IGNORE INTO `visiting` VALUES ('8', '7', null, '2021-04-15 01:57:29', '1');
INSERT IGNORE INTO `visiting` VALUES ('9', '5', null, '2021-04-18 14:28:01', '1');
INSERT IGNORE INTO `visiting` VALUES ('10', '1', '', '2022-10-16 15:50:00', '1');
