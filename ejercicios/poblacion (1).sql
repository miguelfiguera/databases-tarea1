-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 15-05-2025 a las 02:41:35
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `poblacion`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `densidad_poblacion`
--

CREATE TABLE `densidad_poblacion` (
  `id_densidad` int(11) NOT NULL,
  `id_municipio_fk` int(11) NOT NULL,
  `anio` smallint(4) NOT NULL,
  `poblacion` int(11) NOT NULL,
  `densidad_km2` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dirigentes`
--

CREATE TABLE `dirigentes` (
  `id_dirigente` int(11) NOT NULL,
  `nombre_completo` varchar(200) NOT NULL,
  `cargo` enum('Presidente','Gobernador','Alcalde') NOT NULL,
  `id_pais_fk` int(11) NOT NULL,
  `id_estado_fk` int(11) DEFAULT NULL,
  `id_municipio_fk` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados`
--

CREATE TABLE `estados` (
  `id_estado` int(11) NOT NULL,
  `nombre_estado` varchar(100) NOT NULL,
  `id_pais_fk` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `municipios`
--

CREATE TABLE `municipios` (
  `id_Municipio` int(11) NOT NULL,
  `nombre_municipio` varchar(100) NOT NULL,
  `id_estado_fk` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paises`
--

CREATE TABLE `paises` (
  `id_pais` int(11) NOT NULL,
  `nombre_pais` varchar(100) NOT NULL,
  `codigo_iso` varchar(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `densidad_poblacion`
--
ALTER TABLE `densidad_poblacion`
  ADD PRIMARY KEY (`id_densidad`),
  ADD KEY `id_municipio_fk` (`id_municipio_fk`),
  ADD KEY `anio` (`anio`);

--
-- Indices de la tabla `dirigentes`
--
ALTER TABLE `dirigentes`
  ADD PRIMARY KEY (`id_dirigente`),
  ADD KEY `id_pais_fk` (`id_pais_fk`),
  ADD KEY `id_estado_fk` (`id_estado_fk`),
  ADD KEY `id_municipio_fk` (`id_municipio_fk`);

--
-- Indices de la tabla `estados`
--
ALTER TABLE `estados`
  ADD PRIMARY KEY (`id_estado`),
  ADD KEY `id_pais_fk` (`id_pais_fk`);

--
-- Indices de la tabla `municipios`
--
ALTER TABLE `municipios`
  ADD PRIMARY KEY (`id_Municipio`),
  ADD KEY `id_estado_fk` (`id_estado_fk`);

--
-- Indices de la tabla `paises`
--
ALTER TABLE `paises`
  ADD PRIMARY KEY (`id_pais`),
  ADD UNIQUE KEY `codigo_iso` (`codigo_iso`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `densidad_poblacion`
--
ALTER TABLE `densidad_poblacion`
  MODIFY `id_densidad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `dirigentes`
--
ALTER TABLE `dirigentes`
  MODIFY `id_dirigente` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `estados`
--
ALTER TABLE `estados`
  MODIFY `id_estado` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `municipios`
--
ALTER TABLE `municipios`
  MODIFY `id_Municipio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `paises`
--
ALTER TABLE `paises`
  MODIFY `id_pais` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `densidad_poblacion`
--
ALTER TABLE `densidad_poblacion`
  ADD CONSTRAINT `densidad_poblacion_ibfk_1` FOREIGN KEY (`id_municipio_fk`) REFERENCES `municipios` (`id_Municipio`);

--
-- Filtros para la tabla `dirigentes`
--
ALTER TABLE `dirigentes`
  ADD CONSTRAINT `dirigentes_ibfk_1` FOREIGN KEY (`id_pais_fk`) REFERENCES `paises` (`id_pais`),
  ADD CONSTRAINT `dirigentes_ibfk_2` FOREIGN KEY (`id_estado_fk`) REFERENCES `estados` (`id_estado`),
  ADD CONSTRAINT `dirigentes_ibfk_3` FOREIGN KEY (`id_municipio_fk`) REFERENCES `municipios` (`id_Municipio`);

--
-- Filtros para la tabla `estados`
--
ALTER TABLE `estados`
  ADD CONSTRAINT `estados_ibfk_1` FOREIGN KEY (`id_pais_fk`) REFERENCES `paises` (`id_pais`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `municipios`
--
ALTER TABLE `municipios`
  ADD CONSTRAINT `municipios_ibfk_1` FOREIGN KEY (`id_estado_fk`) REFERENCES `estados` (`id_estado`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
