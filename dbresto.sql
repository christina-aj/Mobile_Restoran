-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.32-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for dbresto
CREATE DATABASE IF NOT EXISTS `dbresto` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `dbresto`;

-- Dumping structure for table dbresto.detail_barang
CREATE TABLE IF NOT EXISTS `detail_barang` (
  `id_detail_barang` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `id_barang` bigint(20) unsigned NOT NULL,
  `nama_varian` varchar(100) NOT NULL,
  `kode_varian` varchar(50) NOT NULL,
  `harga_jual` decimal(15,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_detail_barang`),
  UNIQUE KEY `detail_barang_id_barang_kode_varian_unique` (`id_barang`,`kode_varian`),
  CONSTRAINT `detail_barang_id_barang_foreign` FOREIGN KEY (`id_barang`) REFERENCES `master_barang` (`id_barang`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.detail_barang: ~0 rows (approximately)
DELETE FROM `detail_barang`;

-- Dumping structure for table dbresto.detail_transaksi
CREATE TABLE IF NOT EXISTS `detail_transaksi` (
  `id_detail_transaksi` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `id_transaksi` bigint(20) unsigned NOT NULL,
  `id_barang` bigint(20) unsigned NOT NULL,
  `qty` int(10) unsigned NOT NULL,
  `harga_satuan` decimal(15,2) NOT NULL,
  `subtotal` decimal(15,2) NOT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_detail_transaksi`),
  KEY `detail_transaksi_id_transaksi_index` (`id_transaksi`),
  KEY `detail_transaksi_id_barang_foreign` (`id_barang`),
  CONSTRAINT `detail_transaksi_id_barang_foreign` FOREIGN KEY (`id_barang`) REFERENCES `master_barang` (`id_barang`),
  CONSTRAINT `detail_transaksi_id_transaksi_foreign` FOREIGN KEY (`id_transaksi`) REFERENCES `master_transaksi` (`id_transaksi`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.detail_transaksi: ~3 rows (approximately)
DELETE FROM `detail_transaksi`;
INSERT INTO `detail_transaksi` (`id_detail_transaksi`, `id_transaksi`, `id_barang`, `qty`, `harga_satuan`, `subtotal`, `catatan`, `created_at`, `updated_at`) VALUES
	(1, 1, 1, 1, 10000.00, 10000.00, NULL, '2025-12-09 21:09:37', '2025-12-09 21:09:37'),
	(2, 1, 3, 1, 13000.00, 13000.00, NULL, '2025-12-09 21:09:37', '2025-12-09 21:09:37'),
	(4, 3, 1, 1, 10000.00, 10000.00, NULL, '2025-12-09 21:16:10', '2025-12-09 21:16:10');

-- Dumping structure for table dbresto.master_barang
CREATE TABLE IF NOT EXISTS `master_barang` (
  `id_barang` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `id_tenant` bigint(20) unsigned NOT NULL,
  `id_satuan` bigint(20) unsigned DEFAULT NULL,
  `id_kategori` bigint(20) unsigned DEFAULT NULL,
  `kode_barang` varchar(50) NOT NULL,
  `nama_barang` varchar(255) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `harga_default` decimal(15,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_barang`),
  UNIQUE KEY `master_barang_id_tenant_kode_barang_unique` (`id_tenant`,`kode_barang`),
  KEY `master_barang_id_satuan_foreign` (`id_satuan`),
  KEY `master_barang_id_kategori_foreign` (`id_kategori`),
  CONSTRAINT `master_barang_id_kategori_foreign` FOREIGN KEY (`id_kategori`) REFERENCES `master_kategori` (`id_kategori`) ON DELETE SET NULL,
  CONSTRAINT `master_barang_id_satuan_foreign` FOREIGN KEY (`id_satuan`) REFERENCES `master_satuan` (`id_satuan`) ON DELETE SET NULL,
  CONSTRAINT `master_barang_id_tenant_foreign` FOREIGN KEY (`id_tenant`) REFERENCES `master_tenant` (`id_tenant`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.master_barang: ~5 rows (approximately)
DELETE FROM `master_barang`;
INSERT INTO `master_barang` (`id_barang`, `id_tenant`, `id_satuan`, `id_kategori`, `kode_barang`, `nama_barang`, `deskripsi`, `foto`, `harga_default`, `created_at`, `updated_at`) VALUES
	(1, 1, NULL, 13, 'B1', 'bakso urat', NULL, 'barang/qRcEY1CPSiBGK7DSDx6sbSZdzcPkt1MiqeDHGECT.jpg', 10000.00, NULL, '2025-12-10 01:22:12'),
	(3, 1, NULL, 13, 'BRG0001', 'bakso campur', NULL, 'barang/xb8kEGajbohqcg0QkenaKK7JWCCYoGocTmgp2TS9.jpg', 13000.00, '2025-12-08 15:18:18', '2025-12-10 01:22:24'),
	(5, 1, NULL, 13, 'BRG0002', 'bakso mie ayam', NULL, 'barang/7Y9tRo3vuCEmLqJsHAWwXy3CjIU3QSGxOtLJEU34.jpg', 16000.00, '2025-12-09 23:19:39', '2025-12-10 01:22:05'),
	(7, 1, NULL, NULL, 'BRG0004', 'es teh', NULL, 'barang/iWoQNT7dXwAyHKXX48evmJJ1Xdk7AFFn1hcL4t3c.jpg', 6000.00, '2025-12-10 01:07:16', '2025-12-10 01:07:16');

-- Dumping structure for table dbresto.master_kategori
CREATE TABLE IF NOT EXISTS `master_kategori` (
  `id_kategori` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL COMMENT 'User pembuat satuan',
  `kode_kategori` varchar(20) NOT NULL,
  `nama_kategori` varchar(100) NOT NULL,
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_kategori`),
  UNIQUE KEY `master_kategori_kode_kategori_unique` (`kode_kategori`),
  KEY `master_kategori_user_id_foreign` (`user_id`),
  CONSTRAINT `master_kategori_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.master_kategori: ~1 rows (approximately)
DELETE FROM `master_kategori`;
INSERT INTO `master_kategori` (`id_kategori`, `user_id`, `kode_kategori`, `nama_kategori`, `keterangan`, `created_at`, `updated_at`) VALUES
	(13, 2, 'KTG0001', 'Makanan', NULL, '2025-12-09 23:42:08', '2025-12-10 00:11:56'),
	(14, 2, 'KTG0002', 'Minuman', NULL, '2025-12-10 00:12:04', '2025-12-10 00:12:04');

-- Dumping structure for table dbresto.master_satuan
CREATE TABLE IF NOT EXISTS `master_satuan` (
  `id_satuan` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL COMMENT 'User pembuat satuan',
  `kode_satuan` varchar(20) NOT NULL,
  `nama_satuan` varchar(50) NOT NULL,
  `keterangan` varchar(150) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_satuan`),
  UNIQUE KEY `master_satuan_kode_satuan_unique` (`kode_satuan`),
  KEY `master_satuan_user_id_foreign` (`user_id`),
  CONSTRAINT `master_satuan_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.master_satuan: ~0 rows (approximately)
DELETE FROM `master_satuan`;

-- Dumping structure for table dbresto.master_tenant
CREATE TABLE IF NOT EXISTS `master_tenant` (
  `id_tenant` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_by` bigint(20) unsigned DEFAULT NULL COMMENT 'User yang pertama kali mendaftarkan tenant',
  `kode_tenant` varchar(50) NOT NULL COMMENT 'Kode unik tenant, contoh: T-001',
  `nama_tenant` varchar(255) NOT NULL,
  `lokasi` varchar(255) DEFAULT NULL,
  `notelp` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_tenant`),
  UNIQUE KEY `master_tenant_kode_tenant_unique` (`kode_tenant`),
  KEY `master_tenant_created_by_foreign` (`created_by`),
  CONSTRAINT `master_tenant_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.master_tenant: ~1 rows (approximately)
DELETE FROM `master_tenant`;
INSERT INTO `master_tenant` (`id_tenant`, `created_by`, `kode_tenant`, `nama_tenant`, `lokasi`, `notelp`, `created_at`, `updated_at`) VALUES
	(1, 1, 'T1', 'Bakso Ali', 'Jalan Sudirman', '08123456789', NULL, NULL);

-- Dumping structure for table dbresto.master_transaksi
CREATE TABLE IF NOT EXISTS `master_transaksi` (
  `id_transaksi` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `id_tenant` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `kode_transaksi` varchar(50) NOT NULL,
  `tanggal_transaksi` datetime NOT NULL,
  `total_bayar` decimal(15,2) NOT NULL DEFAULT 0.00,
  `payment_gateway` varchar(20) NOT NULL DEFAULT 'CASH',
  `status_pembayaran` varchar(20) NOT NULL DEFAULT 'PAID',
  `dibayar_pada` timestamp NULL DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_transaksi`),
  UNIQUE KEY `master_transaksi_id_tenant_kode_transaksi_unique` (`id_tenant`,`kode_transaksi`),
  KEY `master_transaksi_user_id_foreign` (`user_id`),
  CONSTRAINT `master_transaksi_id_tenant_foreign` FOREIGN KEY (`id_tenant`) REFERENCES `master_tenant` (`id_tenant`) ON DELETE CASCADE,
  CONSTRAINT `master_transaksi_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.master_transaksi: ~2 rows (approximately)
DELETE FROM `master_transaksi`;
INSERT INTO `master_transaksi` (`id_transaksi`, `id_tenant`, `user_id`, `kode_transaksi`, `tanggal_transaksi`, `total_bayar`, `payment_gateway`, `status_pembayaran`, `dibayar_pada`, `catatan`, `created_at`, `updated_at`) VALUES
	(1, 1, 3, 'TRX0001', '2025-12-10 04:09:37', 23000.00, 'CASH', 'PAID', '2025-12-09 21:09:37', 'testung', '2025-12-09 21:09:37', '2025-12-09 21:09:37'),
	(3, 1, 3, 'TRX0003', '2025-12-10 04:16:10', 10000.00, 'CASH', 'PAID', '2025-12-09 21:16:10', 'mmmm', '2025-12-09 21:16:10', '2025-12-09 21:16:10');

-- Dumping structure for table dbresto.migrations
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.migrations: ~17 rows (approximately)
DELETE FROM `migrations`;
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
	(1, '2025_11_14_090633_create_oauth_auth_codes_table', 1),
	(2, '2025_11_14_090634_create_oauth_access_tokens_table', 1),
	(3, '2025_11_14_090635_create_oauth_refresh_tokens_table', 1),
	(4, '2025_11_14_090636_create_oauth_clients_table', 1),
	(5, '2025_11_14_090637_create_oauth_device_codes_table', 1),
	(6, '2025_11_14_145536_create_user_table', 1),
	(7, '2025_11_14_154051_create_sessions_table', 1),
	(8, '2025_11_17_083749_create_tenant_table', 1),
	(9, '2025_11_17_083758_create_kategori_table', 1),
	(10, '2025_11_17_083815_create_satuan_table', 1),
	(11, '2025_11_17_085500_update_users_add_id_tenant', 1),
	(12, '2025_11_19_121038_update_tenant_table', 1),
	(13, '2025_11_19_154411_create_master_barang_table', 1),
	(14, '2025_11_25_105520_create_detail_barang', 1),
	(15, '2025_11_27_125612_create_master_transaksi', 1),
	(16, '2025_11_27_130352_create_detail_transaksi', 1),
	(17, '2025_12_02_161703_add_foto_to_master_barang_table', 1),
	(18, '2025_12_09_130436_replace_id_detail_barang_with_id_barang_on_detail_transaksi', 2);

-- Dumping structure for table dbresto.oauth_access_tokens
CREATE TABLE IF NOT EXISTS `oauth_access_tokens` (
  `id` char(80) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `client_id` char(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `scopes` text DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oauth_access_tokens_user_id_index` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.oauth_access_tokens: ~30 rows (approximately)
DELETE FROM `oauth_access_tokens`;
INSERT INTO `oauth_access_tokens` (`id`, `user_id`, `client_id`, `name`, `scopes`, `revoked`, `created_at`, `updated_at`, `expires_at`) VALUES
	('00b91ce31167f8d30dcad199ed1978ee0b96aa9e4f8364a2ddf1dc00d1d6fac6236ac4b1cd3b33b8', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 23:09:24', '2025-12-09 23:09:24', '2025-12-10 08:09:24'),
	('01aebe30b4f89cd34a36bb3f5d08183e732665e18dffa8a556e972a4958dd965edd2eb81fc57abb7', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 16:52:41', '2025-12-09 16:52:42', '2025-12-10 01:52:42'),
	('03a59de4ccf2eb7376a96240ebf5e1120fbbe88e761c4c0264d51caa474846e988d0884c1f9f8047', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 21:40:20', '2025-12-09 21:40:20', '2025-12-10 06:40:20'),
	('043a6fcc9b52e5bc23061880f67ecd2fb308d9a53b55168bb5fa9bb36bbe40682dd9677c6d3d5e02', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 07:05:57', '2025-12-09 07:05:57', '2025-12-09 16:05:57'),
	('06eaa9e44588f3473dde0c0c8ce7f82e3ed28e2e57e313c9cf164756c5b3fafbda1923bf18512550', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 18:18:24', '2025-12-09 18:18:24', '2025-12-10 03:18:24'),
	('0b96ddca939acab2b485df8bbb0fa499b26dfa40c77308daa2ae407282fa96cfff9cee980c9e2b68', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 21:21:44', '2025-12-09 21:21:44', '2025-12-10 06:21:44'),
	('0be9eb1c3cff6fd9c5264ffef99240be912c7499ddfa71d55420e6ac0d62781e1ced18407979b664', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 22:41:13', '2025-12-09 22:41:15', '2025-12-10 07:41:15'),
	('0c608207bdfdba65ae6c5048479320c3876f45456a5db1d29b06e127a0e6cb3a2c3cacbadf52b1c7', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 16:30:45', '2025-12-09 16:30:50', '2025-12-10 01:30:50'),
	('0d082dca7f153fa99e5cedc0c151096b211d3c992b9ba25834ad12b347e3a858244e1b18bb276c1f', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-10 00:11:29', '2025-12-10 00:11:30', '2025-12-10 09:11:30'),
	('12adb2ff0d96fe16568192d8578d511346a55c9857e6c05cf04269cfe0528e7c67fb9c71a0bfc4c8', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:43:40', '2025-12-09 17:43:40', '2025-12-10 02:43:40'),
	('12b0eca50a918fe5e017848661dcd3ed2133fa5e7b03f11abb3d84e91ad03664c0612feca330f254', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 21:48:23', '2025-12-09 21:48:23', '2025-12-10 06:48:23'),
	('137e42c57c296f7c4d6e97808dae088acc596fb6c9fd5b340af40183012b20b204f070ba565876e7', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 06:54:16', '2025-12-09 06:54:16', '2025-12-09 15:54:16'),
	('14773435d9da440cbcec617222d667e5eb320fbcc151d0348e1695d45244db0c02fe7e08bbab1454', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:37:29', '2025-12-08 14:37:29', '2025-12-08 23:37:29'),
	('16f2f389384ae53e76981d63519bd25eca27992f4502c672d3d00a4788a346278c1bc4158e53590c', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 15:50:39', '2025-12-08 15:50:39', '2025-12-09 00:50:39'),
	('29387153ee41994bc3d4abc40c97f5969b851acf65ce3947e840053919de31b2359bc6c3d4226164', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 16:42:33', '2025-12-09 16:42:34', '2025-12-10 01:42:34'),
	('29b0062cbb4dc81595f1ca70f8ee2c43fc85c142d257219f4d2aa662b5505702c1816b46d16d8773', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 16:37:50', '2025-12-09 16:37:50', '2025-12-10 01:37:50'),
	('304bca79aa011bf9afeea27ec34a451b15c1612bf7f7fb8808ba54d231fe21b1b466ed64e5ee64a0', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 15:16:43', '2025-12-08 15:16:43', '2025-12-09 00:16:43'),
	('391c69aff0f89b4de809cfbc13415f6085084cf66777248bec14a49eb24b4d3820046e348579db7d', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:36:00', '2025-12-08 14:36:00', '2025-12-08 23:36:00'),
	('3bca93767c5a9c359b699009779254ecd79e3e2344d3909271aec1d1afb7a9349ac594d9de17213b', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 21:09:18', '2025-12-09 21:09:18', '2025-12-10 06:09:18'),
	('3da2a40ed8663bca0bfe2294c46a0cd6cdcb32b3b08cdccf5408b54c2396409d67d3ca23e3260cbd', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:46:34', '2025-12-08 14:46:34', '2025-12-08 23:46:34'),
	('4c33a6197c542a8e578c8de6b206fe3bd61eb97d637b270cb20a05f1d229f5016321b4e116183d31', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-10 01:07:00', '2025-12-10 01:07:00', '2025-12-10 10:07:00'),
	('4c6f04ae177cd043380ea9bb2c325aeff381a44af4d4a87929c7eac6d0c05c3767ded5e577142aa4', 1, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 02:26:20', '2025-12-08 02:26:21', '2025-12-08 11:26:21'),
	('4cacc126c69e605230e30a3c41a8e45666c8b479007bcce41e433e49eef3aa29bfad927788572678', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:39:23', '2025-12-09 17:39:23', '2025-12-10 02:39:23'),
	('5061361660a0567e8e8fe72213650c6199826b52739328d412bca75c31a71881e6c95905d3b76743', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:50:57', '2025-12-09 17:50:57', '2025-12-10 02:50:57'),
	('533c4f4d9c9883099e09d6e11cc7298dc261fcefe0d3ffc96c765a7ed2b775a980d4368afccaa668', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 18:45:56', '2025-12-09 18:45:56', '2025-12-10 03:45:56'),
	('599f16d4b8b335d2dcfcb722f567a2c7fa7506cee042dfe4f1db5394029a0b6c02978e9a4b418002', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 07:01:28', '2025-12-09 07:01:28', '2025-12-09 16:01:28'),
	('5d9f087d12e13383e82a7a3e2e9e657f0fe33d4fc4e21820c09a784f3468441bbcc693dcdc00b517', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 07:30:40', '2025-12-09 07:30:40', '2025-12-09 16:30:40'),
	('616bf3526f27f0e5086d8bf00a81f8aa37710374c4afa65e2a29d20bd8369db2f53d815a0f8833d1', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 20:44:18', '2025-12-09 20:44:18', '2025-12-10 05:44:18'),
	('66c8481ff8c586dbb0f6f17d9e83df146061cdaad7ad4a1f001066394b591deb2c7a3716dd8b0568', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:52:04', '2025-12-08 14:52:04', '2025-12-08 23:52:04'),
	('6c175b958f35340816140c3b18897983004b8e2764b674ddf22973fb4433ea1cfe43a00ce2513ee3', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:33:48', '2025-12-09 00:33:48', '2025-12-09 09:33:48'),
	('708c1759c829c372889c37ae6ef265511049607c4ae4f46c96bfc9b546359d6b63eb805d2a663bd1', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 21:11:57', '2025-12-09 21:11:57', '2025-12-10 06:11:57'),
	('74d20e95b097369c589db03d5508013181461fe9f12da41fef3e865f7b51555a6aa3d4cdc5d85051', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 16:46:23', '2025-12-09 16:46:23', '2025-12-10 01:46:23'),
	('78a7b40a6cb0b6578fe640e984d1bda2543485860cba000e5d3b3e30207f1e9825a26a1f841bed5d', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 16:58:54', '2025-12-09 16:58:54', '2025-12-10 01:58:54'),
	('7f638a99dae6b24419bd4b05039b45e79524511661e5be9867449fbaede4ba3c271a152a320ca195', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 22:47:49', '2025-12-09 22:47:49', '2025-12-10 07:47:49'),
	('80f47ad820eee03aa69a99adea84344d09e1655feddfe38241acb1a490c17c3a4f0ce13c839dccd6', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:30:12', '2025-12-08 14:30:12', '2025-12-08 23:30:12'),
	('8134ddcaf55bb1a6f36452dea51328d266c1c7d296ecb404b1cc963045ec174752684dc9530b7968', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 16:36:32', '2025-12-09 16:36:32', '2025-12-10 01:36:32'),
	('843a9087a6ba4d41d71648f0ceb31aa6bad1b7c6c76f41a4c3d8c28bb48ae382a7a1f1d5da0a0a27', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 06:43:00', '2025-12-09 06:43:02', '2025-12-09 15:43:02'),
	('8646863e25e52c592053b323c71aa8ffa18bd47a0058fd047e01ed867f8320a21bff64c9e64c41ff', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 23:10:46', '2025-12-09 23:10:46', '2025-12-10 08:10:46'),
	('89683a5c7c652f3cd26d17a48c954c5746a56475341703f5514c0abe51caaafffaa5d0109731506a', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-10 00:39:23', '2025-12-10 00:39:23', '2025-12-10 09:39:23'),
	('8a0fed99ced79fec286e4d525ddc59bbee94080daff59a22fba47d85d6e31606d473c60e8dd54b5d', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 23:19:24', '2025-12-09 23:19:24', '2025-12-10 08:19:24'),
	('8a18a23fc331bf2b0371b08b3298243d1261b03d493d99190ba421ef0141f550445d636f70994995', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:24:45', '2025-12-09 17:24:45', '2025-12-10 02:24:45'),
	('8b6120b9daec97e4944a011ea9f18801bc2ba2dbe26512ca9c970485e385b98845557e42e3dee865', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 22:20:21', '2025-12-08 22:20:21', '2025-12-09 07:20:21'),
	('9136f0fbdd2085786c3c8353f495ae96a054ab46cdce673199620097ab55ec858164599ea8aa8ecf', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:42:24', '2025-12-09 17:42:24', '2025-12-10 02:42:24'),
	('95f1975999023216ea194aa197f4d7e5aa87b15fbf28d830023168360fa3755aa8f1de3ad12bf520', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 01:01:13', '2025-12-09 01:01:13', '2025-12-09 10:01:13'),
	('97829f19f7897adb93f91b85a3d315b511cbec999797ee1055e0dc3dcd81e62739f2891faf2a7ec5', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-10 00:21:25', '2025-12-10 00:21:25', '2025-12-10 09:21:25'),
	('9b5ef64fe0e8590f0c521682a585e39f13d0162af394b1ead361c5f262b36342aa7857a46b46831d', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-10 01:26:28', '2025-12-10 01:26:28', '2025-12-10 10:26:28'),
	('9bfd32257cd4e6d95025097e777d1c65af3f6497716c1227e255988f1d2c6d7bd17349d4a46c6186', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:31:13', '2025-12-09 00:31:14', '2025-12-09 09:31:14'),
	('9e04a61e3585db97ba2d34c0edb27424e54a1c731fd0f8bbc0805a198ca93acbdbab9c57707741fd', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 15:30:27', '2025-12-08 15:30:28', '2025-12-09 00:30:28'),
	('9efe1d7fa30d67ee134cd64efe7b52d8b2fc1d979be17d976ad31c62399fdcb011c92f3b4dabd5c0', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 18:22:26', '2025-12-09 18:22:26', '2025-12-10 03:22:26'),
	('a1fd3ec4ae55e325cea0bc4bdadc9d86885edb5015b9eed7bf4ff8d7ac53d648a8e3adf992bc335f', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:13:59', '2025-12-08 14:13:59', '2025-12-08 23:13:59'),
	('a92fd56d500a6befbba270fe475f498fbb512d2d387fb47660b1cfa241141da2494d0171d5d5dfff', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 19:08:20', '2025-12-09 19:08:20', '2025-12-10 04:08:20'),
	('aa2f5948b79ef8cbbf4b3ee608fb9a0a9912ec56692b87e7e3d0ae32985a72083fd368a44fdf8a1c', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:53:05', '2025-12-09 00:53:05', '2025-12-09 09:53:05'),
	('ae2b686558acf6f20f4e1a6d5a14b29e9d3fdd39ba3fc7456b8051806b333115305b96d707fe7089', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 07:04:50', '2025-12-09 07:04:50', '2025-12-09 16:04:50'),
	('afe8dbd3662889d81b0fbabc68db4efc0816d44041e09f09cf46a2f016163a1801a32e76c096143f', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:18:05', '2025-12-09 17:18:05', '2025-12-10 02:18:05'),
	('b0f75d9078e67066bd5cddd38caa77226c23944cd717fd810497a9b5f639ef60fc0df244f6b9a0a5', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 18:53:12', '2025-12-09 18:53:12', '2025-12-10 03:53:12'),
	('b2ae9aad990305729c124708f67064def8b352893a0fbe35de3556efbd0240d0bf0bf76740105c70', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 20:20:32', '2025-12-09 20:20:33', '2025-12-10 05:20:33'),
	('b7bc538e9110925b9389fcc6170bf12363a51c6212087b987a1eb20a7d4c04c5a3973c725128e1f8', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:34:20', '2025-12-09 17:34:20', '2025-12-10 02:34:20'),
	('bba2453148e07cee00c0e1b5b58674edfcd427a9c7098338ba658e552949f27fbcc02c3f6c986764', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 20:37:02', '2025-12-09 20:37:02', '2025-12-10 05:37:02'),
	('bc5ea526104b62c5b44ef3c0e57846a0ecf8ebe57b3d82ed1452c14e65131e7fa1850865e47e50cc', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 20:42:29', '2025-12-09 20:42:29', '2025-12-10 05:42:29'),
	('bc679a89621148f13a2551a13d9b388add559b1b587c2ca51624920bdd91a1dbd2fc1c1d403e4b75', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 21:15:56', '2025-12-09 21:15:56', '2025-12-10 06:15:56'),
	('c2bcb6af7ced7b002f67afd9d94aaa0c5a8bd56a95a8618996ac53627c95082df904a597788c273f', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 06:59:34', '2025-12-09 06:59:34', '2025-12-09 15:59:34'),
	('c59139560c70e59f0fbbaa1e26481530205ad1e65808c0910b1a83e59d0e654c92bd11bae71967c3', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 01:06:32', '2025-12-09 01:06:32', '2025-12-09 10:06:32'),
	('c97f934a6e12c58c1426e667c38be649a87829408472e9e7b43ebf8a7cd23eb71ac0654a6529ec51', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 22:38:55', '2025-12-08 22:38:55', '2025-12-09 07:38:55'),
	('cc050035433bfeb406539a7ab58a0931d60273e6d77083293ae4767b5e162f826dc0028078617431', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 18:18:58', '2025-12-09 18:18:58', '2025-12-10 03:18:58'),
	('ce301d045c0e93e4a4500f9761c3e789ecd25152f4f68cddcf834b9bbb7d3f783aeff42ca7e4cf1d', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 16:52:13', '2025-12-09 16:52:13', '2025-12-10 01:52:13'),
	('ce93b22a2128f8e9ae585719ed105486dcf34da2e90655ec3a827d5ef8aa0ad77035d8e39d230fad', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 16:15:48', '2025-12-08 16:15:48', '2025-12-09 01:15:48'),
	('d47f571ce72d8adaf790ad5923ee81e2c45e1c3cfb5d02b73c458d0dd95f85d010376ab2b66e48d7', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 20:23:38', '2025-12-09 20:23:38', '2025-12-10 05:23:38'),
	('d53d1e17e0b1422ae40259bc34741cb300683ff442da4cfcc39e205448c58b9f6d41d6741d6d2d35', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 15:54:17', '2025-12-08 15:54:17', '2025-12-09 00:54:17'),
	('d56a8c61cdd0ab9f5736696b91dc6bb23f085f9fa33d3b35b64d0b74acc98d8d504cb2eb1de5fffa', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 22:08:11', '2025-12-08 22:08:13', '2025-12-09 07:08:13'),
	('d72087dbaed3c0842344111520d61f8e00baef8a6a9004bbcae4cfcf0953d8936988d1197ae4c44f', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:18:47', '2025-12-09 17:18:47', '2025-12-10 02:18:47'),
	('d7adf8451a87cb5343b2772f9357e0e92ab67f8ea1f6b9b5066e7a24be6ef7a48e6c0a833970cfe8', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-10 00:44:34', '2025-12-10 00:44:34', '2025-12-10 09:44:34'),
	('d9a5f90d5a4b4c3c797adf040506fe0cdeda057ef1619bc79b162249e3d3bb6f43c866f9c9b8ba45', 1, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:06:42', '2025-12-08 14:06:45', '2025-12-08 23:06:45'),
	('de6fda96de78f8fa27a3d11ea937dbfd982753b5bcb0020057064e492f82d428852c619d6548dd27', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 23:14:47', '2025-12-09 23:14:47', '2025-12-10 08:14:47'),
	('e544f90a23506ebdb0d5a76c5ad7541596192955e77bcf1ad50dc00bf0d0431c40dcb156629b8240', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 23:17:12', '2025-12-09 23:17:12', '2025-12-10 08:17:12'),
	('e581db6fdddee15cbce948e279306529be4f259d394c5de182ce6878192b1e1505380f26282cc8ff', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 21:27:38', '2025-12-09 21:27:38', '2025-12-10 06:27:38'),
	('e6b6c05d2a7b43066f0f61a052b6c16c4f7611086df5a175a5b1720f7e03f5a3b68c4584eb59fd28', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-10 01:21:11', '2025-12-10 01:21:11', '2025-12-10 10:21:11'),
	('e9f1ec712eab5f79b74abb57b833d18345f5b7a60393cb4fd288733a018566368f9cf148d1fb65db', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:53:03', '2025-12-09 17:53:03', '2025-12-10 02:53:03'),
	('eea49555ab06d517078158617d13adce2877542030b4ccba3ac761af5edb7d9996307a310ee86638', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 23:32:25', '2025-12-09 23:32:26', '2025-12-10 08:32:26'),
	('f0b739661c64fdfcb0e643b80fb1274b0c165d67b1a76a846cf216183a20d89908c7f370e8584712', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 22:36:50', '2025-12-09 22:36:50', '2025-12-10 07:36:50'),
	('f1989ab1c7b5d43bc1f6ec544879fe5d453ec14feb8d3f4fcf2a621970e7b6e1855a8d664622df9c', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:56:31', '2025-12-09 00:56:31', '2025-12-09 09:56:31'),
	('f1fc00246c1913c2ae4bc362439119cf42fca52b92c0e83318055206a1df4ccc7be3e29835c6ba9d', 3, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 17:57:31', '2025-12-09 17:57:31', '2025-12-10 02:57:31'),
	('f296dee1e85b389bafc2d5f8a0596340a82ba780efe9c7f050fd1fa77e5e70c9c45b22414564a78a', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 23:23:43', '2025-12-09 23:23:43', '2025-12-10 08:23:43'),
	('fa3a1bb1715c51b45d17a9a98a3f6d054989c5548d3fd146ac1559064fbe0cc89e624ed95b2d5304', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:41:27', '2025-12-09 00:41:27', '2025-12-09 09:41:27'),
	('fb48fd339f413f3ccebda33258c90739ce5d68f807f92b894ca360152ad7063ab6508f5ba4668ed4', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:33:05', '2025-12-08 14:33:05', '2025-12-08 23:33:05'),
	('fd35ea042ee55c1d367c73ad8b41b976cb338fe2e9028a9787e92eba92a3df1e8eabee8a3e97ad4c', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 21:34:10', '2025-12-09 21:34:10', '2025-12-10 06:34:10'),
	('ff509786d5e0cabcae0a1164507effb2634419e8571bf2a0225091f40f482aac4999dc1ef01973a9', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-10 01:18:55', '2025-12-10 01:18:55', '2025-12-10 10:18:55');

-- Dumping structure for table dbresto.oauth_auth_codes
CREATE TABLE IF NOT EXISTS `oauth_auth_codes` (
  `id` char(80) NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `client_id` char(36) NOT NULL,
  `scopes` text DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oauth_auth_codes_user_id_index` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.oauth_auth_codes: ~0 rows (approximately)
DELETE FROM `oauth_auth_codes`;

-- Dumping structure for table dbresto.oauth_clients
CREATE TABLE IF NOT EXISTS `oauth_clients` (
  `id` char(36) NOT NULL,
  `owner_type` varchar(255) DEFAULT NULL,
  `owner_id` bigint(20) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `secret` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `redirect_uris` text NOT NULL,
  `grant_types` text NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oauth_clients_owner_type_owner_id_index` (`owner_type`,`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.oauth_clients: ~0 rows (approximately)
DELETE FROM `oauth_clients`;
INSERT INTO `oauth_clients` (`id`, `owner_type`, `owner_id`, `name`, `secret`, `provider`, `redirect_uris`, `grant_types`, `revoked`, `created_at`, `updated_at`) VALUES
	('019afd42-cb00-7235-84ed-1013fdae29a7', NULL, NULL, 'Laravel', '$2y$12$WwPpOMhwjlES9lcCq0cygeRJU9ORA6fq.MFILAliZ8rIvpfkDM4Si', 'users', '[]', '["personal_access"]', 0, '2025-12-08 02:20:04', '2025-12-08 02:20:04');

-- Dumping structure for table dbresto.oauth_device_codes
CREATE TABLE IF NOT EXISTS `oauth_device_codes` (
  `id` char(80) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `client_id` char(36) NOT NULL,
  `user_code` char(8) NOT NULL,
  `scopes` text NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `user_approved_at` datetime DEFAULT NULL,
  `last_polled_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `oauth_device_codes_user_code_unique` (`user_code`),
  KEY `oauth_device_codes_user_id_index` (`user_id`),
  KEY `oauth_device_codes_client_id_index` (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.oauth_device_codes: ~0 rows (approximately)
DELETE FROM `oauth_device_codes`;

-- Dumping structure for table dbresto.oauth_refresh_tokens
CREATE TABLE IF NOT EXISTS `oauth_refresh_tokens` (
  `id` char(80) NOT NULL,
  `access_token_id` char(80) NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oauth_refresh_tokens_access_token_id_index` (`access_token_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.oauth_refresh_tokens: ~0 rows (approximately)
DELETE FROM `oauth_refresh_tokens`;

-- Dumping structure for table dbresto.sessions
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.sessions: ~6 rows (approximately)
DELETE FROM `sessions`;
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
	('cMGP0WplecMKY9jUgHGoQaNGyiPoM7pv9Gbhw8bR', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidWg3UVVYSzFRZ2xjOHRrRFBLOGVXNERjZWFXbmxpeWpFSExNNXlmQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765348293),
	('wvn7BAiRLahsliWTNdZUTPoMs64TfjEcds4gc0G5', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQWhVb1lVVkNvbEIwVjRkNXU4dXJhR2RHWE1KZVdiNlFyR3huMHVCciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765323026);

-- Dumping structure for table dbresto.users
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `notelfon` varchar(20) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `role` varchar(255) DEFAULT NULL,
  `id_tenant` bigint(20) unsigned DEFAULT NULL,
  `lokasi` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `tanggal_masuk` date DEFAULT NULL,
  `profile` varchar(255) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_id_tenant_foreign` (`id_tenant`),
  CONSTRAINT `users_id_tenant_foreign` FOREIGN KEY (`id_tenant`) REFERENCES `master_tenant` (`id_tenant`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.users: ~3 rows (approximately)
DELETE FROM `users`;
INSERT INTO `users` (`user_id`, `notelfon`, `email`, `nama`, `role`, `id_tenant`, `lokasi`, `password`, `tanggal_masuk`, `profile`, `remember_token`, `created_at`, `updated_at`) VALUES
	(1, '08123456789', 'admin@example.com', 'Admin', 'admin', NULL, 'Head Office', '$2y$12$mkfwV2eLnGKlROTqhKIUcujkRNcZu8HZwOzPZcAUgvZxFpCEv5WpK', '2024-01-01', NULL, NULL, '2025-12-08 02:16:35', '2025-12-08 02:16:35'),
	(2, '08123456789', 'admin123@example.com', 'Pak Ali', 'tenant', 1, 'Head Office', '$2y$12$BX9UlQTCXnqNcmLiSRpbbeH7Jk49uERmBiIl93TZZD0O94InFaYI.', '2024-01-01', NULL, NULL, '2025-12-08 02:16:35', '2025-12-08 02:16:35'),
	(3, '08765656688', 'kasir1@example.com', 'Kasir1', 'kasir', 1, NULL, '$2y$10$ru2QZu8swdDWDVeK2oHmcO52OEwki0uYJu45uUVTUEw7jjS1UY9lW', NULL, NULL, NULL, NULL, NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
