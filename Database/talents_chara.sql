-- --------------------------------------------------------
-- Host:                         149.202.89.145
-- Server version:               8.0.46-0ubuntu0.22.04.4 - (Ubuntu)
-- Server OS:                    Linux
-- HeidiSQL Version:             12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table characters_felskorn_test.felskorn_talent_builds
DROP TABLE IF EXISTS `felskorn_talent_builds`;
CREATE TABLE IF NOT EXISTS `felskorn_talent_builds` (
  `guid` int unsigned NOT NULL,
  `active_build` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table characters_felskorn_test.felskorn_talent_builds: ~5 rows (approximately)
INSERT INTO `felskorn_talent_builds` (`guid`, `active_build`) VALUES
	(1, 1),
	(70, 1),
	(71, 1),
	(72, 1),
	(73, 1);

-- Dumping structure for table characters_felskorn_test.felskorn_talent_build_spells
DROP TABLE IF EXISTS `felskorn_talent_build_spells`;
CREATE TABLE IF NOT EXISTS `felskorn_talent_build_spells` (
  `guid` int unsigned NOT NULL,
  `build_id` tinyint unsigned NOT NULL,
  `spell_id` int unsigned NOT NULL,
  PRIMARY KEY (`guid`,`build_id`,`spell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table characters_felskorn_test.felskorn_talent_build_spells: ~20 rows (approximately)
INSERT INTO `felskorn_talent_build_spells` (`guid`, `build_id`, `spell_id`) VALUES
	(70, 1, 17780),
	(70, 1, 17792),
	(70, 1, 18699),
	(70, 1, 18707),
	(70, 1, 18708),
	(70, 1, 18710),
	(70, 1, 18744),
	(70, 1, 18768),
	(70, 1, 18773),
	(70, 1, 19028),
	(70, 1, 23825),
	(70, 1, 30145),
	(70, 1, 30146),
	(70, 1, 30248),
	(70, 1, 35693),
	(70, 1, 47193),
	(70, 1, 47231),
	(70, 1, 47247),
	(70, 1, 63158),
	(70, 1, 63351);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
