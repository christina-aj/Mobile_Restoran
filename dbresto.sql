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
  `id_detail_barang` bigint(20) unsigned NOT NULL,
  `qty` int(10) unsigned NOT NULL,
  `harga_satuan` decimal(15,2) NOT NULL,
  `subtotal` decimal(15,2) NOT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_detail_transaksi`),
  KEY `detail_transaksi_id_detail_barang_foreign` (`id_detail_barang`),
  KEY `detail_transaksi_id_transaksi_index` (`id_transaksi`),
  CONSTRAINT `detail_transaksi_id_detail_barang_foreign` FOREIGN KEY (`id_detail_barang`) REFERENCES `detail_barang` (`id_detail_barang`),
  CONSTRAINT `detail_transaksi_id_transaksi_foreign` FOREIGN KEY (`id_transaksi`) REFERENCES `master_transaksi` (`id_transaksi`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.detail_transaksi: ~0 rows (approximately)
DELETE FROM `detail_transaksi`;

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.master_barang: ~2 rows (approximately)
DELETE FROM `master_barang`;
INSERT INTO `master_barang` (`id_barang`, `id_tenant`, `id_satuan`, `id_kategori`, `kode_barang`, `nama_barang`, `deskripsi`, `foto`, `harga_default`, `created_at`, `updated_at`) VALUES
	(1, 1, NULL, 1, 'B1', 'Baksoww', NULL, NULL, 10000.00, NULL, '2025-12-08 16:16:05'),
	(3, 1, NULL, NULL, 'BRG0001', 'bakso campur', NULL, NULL, 13000.00, '2025-12-08 15:18:18', '2025-12-08 15:18:18');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.master_kategori: ~1 rows (approximately)
DELETE FROM `master_kategori`;
INSERT INTO `master_kategori` (`id_kategori`, `user_id`, `kode_kategori`, `nama_kategori`, `keterangan`, `created_at`, `updated_at`) VALUES
	(1, 2, 'KTG0001', 'makanann', NULL, '2025-12-08 15:39:16', '2025-12-08 15:39:16');

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
	(1, 1, 'T1', 'Bakso Ali', NULL, NULL, NULL, NULL);

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table dbresto.master_transaksi: ~0 rows (approximately)
DELETE FROM `master_transaksi`;

-- Dumping structure for table dbresto.migrations
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
	(17, '2025_12_02_161703_add_foto_to_master_barang_table', 1);

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

-- Dumping data for table dbresto.oauth_access_tokens: ~1 rows (approximately)
DELETE FROM `oauth_access_tokens`;
INSERT INTO `oauth_access_tokens` (`id`, `user_id`, `client_id`, `name`, `scopes`, `revoked`, `created_at`, `updated_at`, `expires_at`) VALUES
	('14773435d9da440cbcec617222d667e5eb320fbcc151d0348e1695d45244db0c02fe7e08bbab1454', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:37:29', '2025-12-08 14:37:29', '2025-12-08 23:37:29'),
	('16f2f389384ae53e76981d63519bd25eca27992f4502c672d3d00a4788a346278c1bc4158e53590c', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 15:50:39', '2025-12-08 15:50:39', '2025-12-09 00:50:39'),
	('304bca79aa011bf9afeea27ec34a451b15c1612bf7f7fb8808ba54d231fe21b1b466ed64e5ee64a0', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 15:16:43', '2025-12-08 15:16:43', '2025-12-09 00:16:43'),
	('391c69aff0f89b4de809cfbc13415f6085084cf66777248bec14a49eb24b4d3820046e348579db7d', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:36:00', '2025-12-08 14:36:00', '2025-12-08 23:36:00'),
	('3da2a40ed8663bca0bfe2294c46a0cd6cdcb32b3b08cdccf5408b54c2396409d67d3ca23e3260cbd', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:46:34', '2025-12-08 14:46:34', '2025-12-08 23:46:34'),
	('4c6f04ae177cd043380ea9bb2c325aeff381a44af4d4a87929c7eac6d0c05c3767ded5e577142aa4', 1, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 02:26:20', '2025-12-08 02:26:21', '2025-12-08 11:26:21'),
	('66c8481ff8c586dbb0f6f17d9e83df146061cdaad7ad4a1f001066394b591deb2c7a3716dd8b0568', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:52:04', '2025-12-08 14:52:04', '2025-12-08 23:52:04'),
	('6c175b958f35340816140c3b18897983004b8e2764b674ddf22973fb4433ea1cfe43a00ce2513ee3', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:33:48', '2025-12-09 00:33:48', '2025-12-09 09:33:48'),
	('80f47ad820eee03aa69a99adea84344d09e1655feddfe38241acb1a490c17c3a4f0ce13c839dccd6', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:30:12', '2025-12-08 14:30:12', '2025-12-08 23:30:12'),
	('8b6120b9daec97e4944a011ea9f18801bc2ba2dbe26512ca9c970485e385b98845557e42e3dee865', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 22:20:21', '2025-12-08 22:20:21', '2025-12-09 07:20:21'),
	('95f1975999023216ea194aa197f4d7e5aa87b15fbf28d830023168360fa3755aa8f1de3ad12bf520', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 01:01:13', '2025-12-09 01:01:13', '2025-12-09 10:01:13'),
	('9bfd32257cd4e6d95025097e777d1c65af3f6497716c1227e255988f1d2c6d7bd17349d4a46c6186', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:31:13', '2025-12-09 00:31:14', '2025-12-09 09:31:14'),
	('9e04a61e3585db97ba2d34c0edb27424e54a1c731fd0f8bbc0805a198ca93acbdbab9c57707741fd', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 15:30:27', '2025-12-08 15:30:28', '2025-12-09 00:30:28'),
	('a1fd3ec4ae55e325cea0bc4bdadc9d86885edb5015b9eed7bf4ff8d7ac53d648a8e3adf992bc335f', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:13:59', '2025-12-08 14:13:59', '2025-12-08 23:13:59'),
	('aa2f5948b79ef8cbbf4b3ee608fb9a0a9912ec56692b87e7e3d0ae32985a72083fd368a44fdf8a1c', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:53:05', '2025-12-09 00:53:05', '2025-12-09 09:53:05'),
	('c59139560c70e59f0fbbaa1e26481530205ad1e65808c0910b1a83e59d0e654c92bd11bae71967c3', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 01:06:32', '2025-12-09 01:06:32', '2025-12-09 10:06:32'),
	('c97f934a6e12c58c1426e667c38be649a87829408472e9e7b43ebf8a7cd23eb71ac0654a6529ec51', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 22:38:55', '2025-12-08 22:38:55', '2025-12-09 07:38:55'),
	('ce93b22a2128f8e9ae585719ed105486dcf34da2e90655ec3a827d5ef8aa0ad77035d8e39d230fad', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 16:15:48', '2025-12-08 16:15:48', '2025-12-09 01:15:48'),
	('d53d1e17e0b1422ae40259bc34741cb300683ff442da4cfcc39e205448c58b9f6d41d6741d6d2d35', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 15:54:17', '2025-12-08 15:54:17', '2025-12-09 00:54:17'),
	('d56a8c61cdd0ab9f5736696b91dc6bb23f085f9fa33d3b35b64d0b74acc98d8d504cb2eb1de5fffa', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 22:08:11', '2025-12-08 22:08:13', '2025-12-09 07:08:13'),
	('d9a5f90d5a4b4c3c797adf040506fe0cdeda057ef1619bc79b162249e3d3bb6f43c866f9c9b8ba45', 1, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:06:42', '2025-12-08 14:06:45', '2025-12-08 23:06:45'),
	('f1989ab1c7b5d43bc1f6ec544879fe5d453ec14feb8d3f4fcf2a621970e7b6e1855a8d664622df9c', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:56:31', '2025-12-09 00:56:31', '2025-12-09 09:56:31'),
	('fa3a1bb1715c51b45d17a9a98a3f6d054989c5548d3fd146ac1559064fbe0cc89e624ed95b2d5304', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-09 00:41:27', '2025-12-09 00:41:27', '2025-12-09 09:41:27'),
	('fb48fd339f413f3ccebda33258c90739ce5d68f807f92b894ca360152ad7063ab6508f5ba4668ed4', 2, '019afd42-cb00-7235-84ed-1013fdae29a7', 'authToken', '[]', 0, '2025-12-08 14:33:05', '2025-12-08 14:33:05', '2025-12-08 23:33:05');

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

-- Dumping data for table dbresto.oauth_clients: ~1 rows (approximately)
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

-- Dumping data for table dbresto.sessions: ~5 rows (approximately)
DELETE FROM `sessions`;
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
	('FShucTyAnYhTqlUTz3SMpzthGC1YW6JuYZ5IgPuf', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQUtvVld1YVFoOHFaajIwb3ZFdG1kdjMyNm9uM2FIUld1VzlDeERlMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765227816),
	('fvRsvJUqhzupSFpFw7OqIJ24hCLubMN6B1CsVXJJ', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM3NwS0tXWW9aV084WlpoaHNhdVI5czhUbjdYN01uaHdpTVB0VjhEdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765185743),
	('l3hKmWVr47wDwY6ZJFbuTZdMHyPQMxwWZuXEMnUJ', NULL, '127.0.0.1', 'PostmanRuntime/7.49.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVFJndVpHQWxaNGtXcG04VmVBM1dLbHdCeHJHN3ZrckJFZThDOXNxeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765185966),
	('R9MfXt32eepwe00qQ7lsuFHe2VFsjHrLtRD3iTRx', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQkxoTnVmc3pmM2JoRlI2RW1ZVlpKM01hV3EwNkpaWE5Ka1hRQmdFViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjk6Imh0dHA6Ly9iZWFkbWlucmVzdG8tdGVzdC50ZXN0IjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765227738),
	('vkcgcXYTXII6qqweLMFRK8gT8uLdR0pbAZ5IgFR4', NULL, '192.168.1.250', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRDg1ajRFMUkyQVhtQ2RwbW5wTk5vbXBOa3RHZVpMVDFMTGdtczRmayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly8xOTIuMTY4LjEuMjUwOjgwMDAiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765227905);

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

-- Dumping data for table dbresto.users: ~4 rows (approximately)
DELETE FROM `users`;
INSERT INTO `users` (`user_id`, `notelfon`, `email`, `nama`, `role`, `id_tenant`, `lokasi`, `password`, `tanggal_masuk`, `profile`, `remember_token`, `created_at`, `updated_at`) VALUES
	(1, '08123456789', 'admin@example.com', 'Admin', 'admin', NULL, 'Head Office', '$2y$12$mkfwV2eLnGKlROTqhKIUcujkRNcZu8HZwOzPZcAUgvZxFpCEv5WpK', '2024-01-01', NULL, NULL, '2025-12-08 02:16:35', '2025-12-08 02:16:35'),
	(2, '08123456789', 'admin123@example.com', 'Bakso Ali', 'tenant', 1, 'Head Office', '$2y$12$BX9UlQTCXnqNcmLiSRpbbeH7Jk49uERmBiIl93TZZD0O94InFaYI.', '2024-01-01', NULL, NULL, '2025-12-08 02:16:35', '2025-12-08 02:16:35'),
	(3, '08765656688', 'kasir1@example.com', 'Kasir1', 'kasir', 1, NULL, '$2y$10$ru2QZu8swdDWDVeK2oHmcO52OEwki0uYJu45uUVTUEw7jjS1UY9lW', NULL, NULL, NULL, NULL, NULL),
	(4, NULL, 'u@example.com', 'uuu', 'kasir', 1, NULL, '$2y$12$OeUnn3Vq6Qv7.cvwVr57PuahHNUkr7g9wwfrjRHPOVu5ImbRRf74O', '2025-12-09', NULL, NULL, '2025-12-09 00:42:20', '2025-12-09 00:54:04');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
