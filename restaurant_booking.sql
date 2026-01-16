-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- 主機： 127.0.0.1
-- 產生時間： 2026-01-16 06:27:19
-- 伺服器版本： 10.4.32-MariaDB
-- PHP 版本： 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 資料庫： `restaurant_booking`
--

-- --------------------------------------------------------

--
-- 資料表結構 `customer`
--

CREATE TABLE `customer` (
  `id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `customer`
--

INSERT INTO `customer` (`id`, `name`, `phone`) VALUES
(7, '蟹湯圓先生', '0905989963'),
(8, '月月先生', '0909182282'),
(9, '月月先生', '0909728187'),
(10, '87', '0987878787'),
(11, '78先生', '0978787878'),
(12, '張小姐先生', '0936578489'),
(13, '123456先生', '0912345678'),
(14, '123先生', '0918282330'),
(15, '789先生', '0955787963'),
(16, 'HippoSheepPig先生', '0963636363'),
(17, '741先生', '0918555666'),
(18, '楊雅君先生', '0958333234'),
(19, '吳安婷先生', '0908787963'),
(20, '楊雅君先生', '0988787414'),
(21, '呂先生', '0977744155'),
(22, '123先生', '0988888888');

-- --------------------------------------------------------

--
-- 資料表結構 `reservation`
--

CREATE TABLE `reservation` (
  `id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `party_size` int(11) DEFAULT NULL,
  `date_time` datetime DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `table_ids` text DEFAULT NULL,
  `note` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `reservation`
--

INSERT INTO `reservation` (`id`, `customer_id`, `party_size`, `date_time`, `status`, `table_ids`, `note`) VALUES
(44, 8, 10, '2026-01-03 11:00:00', 'Confirmed', '[3, 4]', ''),
(45, 14, 2, '2026-01-05 11:00:00', 'Confirmed', '[1]', ''),
(51, 8, 10, '2026-01-02 11:00:00', 'Confirmed', '[3, 4]', ''),
(52, 8, 2, '2026-01-02 11:00:00', 'Confirmed', '[1]', ''),
(53, 8, 2, '2026-01-02 11:00:00', 'Confirmed', '[2]', ''),
(56, 14, 2, '2026-01-11 12:30:00', 'Confirmed', '[1]', ''),
(58, 22, 2, '2026-01-09 11:00:00', 'Confirmed', '[1]', '');

-- --------------------------------------------------------

--
-- 資料表結構 `reservation_assignment`
--

CREATE TABLE `reservation_assignment` (
  `id` int(11) NOT NULL,
  `reservation_id` int(11) NOT NULL,
  `table_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 傾印資料表的資料 `reservation_assignment`
--

INSERT INTO `reservation_assignment` (`id`, `reservation_id`, `table_id`, `created_at`) VALUES
(1, 17, 1, '2025-12-30 15:16:42'),
(4, 20, 4, '2025-12-30 15:17:30'),
(5, 20, 5, '2025-12-30 15:17:30');

-- --------------------------------------------------------

--
-- 資料表結構 `restaurant_table`
--

CREATE TABLE `restaurant_table` (
  `id` int(11) NOT NULL,
  `capacity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `restaurant_table`
--

INSERT INTO `restaurant_table` (`id`, `capacity`) VALUES
(1, 2),
(2, 4),
(3, 4),
(4, 6),
(5, 6);

--
-- 已傾印資料表的索引
--

--
-- 資料表索引 `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone` (`phone`);

--
-- 資料表索引 `reservation`
--
ALTER TABLE `reservation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- 資料表索引 `reservation_assignment`
--
ALTER TABLE `reservation_assignment`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_res_table` (`reservation_id`,`table_id`);

--
-- 資料表索引 `restaurant_table`
--
ALTER TABLE `restaurant_table`
  ADD PRIMARY KEY (`id`);

--
-- 在傾印的資料表使用自動遞增(AUTO_INCREMENT)
--

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `customer`
--
ALTER TABLE `customer`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `reservation`
--
ALTER TABLE `reservation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `reservation_assignment`
--
ALTER TABLE `reservation_assignment`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `restaurant_table`
--
ALTER TABLE `restaurant_table`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- 已傾印資料表的限制式
--

--
-- 資料表的限制式 `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
