-- ===========================================================
-- PROYECTO: Sistema de gestion de eventos y venta de entradas digitales con memorias
-- ASIGNATURA: Base de Datos - Unidad 1
-- DATOS: FICTICIOS. Compras simuladas; sin cobros reales.
-- ===========================================================

CREATE DATABASE IF NOT EXISTS TICKETERA_UNIDAD1
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE TICKETERA_UNIDAD1;

-- 1. ORGANIZADOR
CREATE TABLE ORGANIZADOR (
  ID_Organizador INT AUTO_INCREMENT PRIMARY KEY,
  Nombre_Organizador VARCHAR(120) NOT NULL,
  Tipo_Organizador ENUM('Productora','Artista','Empresa','Particular') NOT NULL,
  Correo VARCHAR(120) NOT NULL UNIQUE,
  Celular VARCHAR(20),
  Ciudad VARCHAR(80) NOT NULL,
  Descripcion VARCHAR(255)
) ENGINE=InnoDB;

-- 2. EVENTO
CREATE TABLE EVENTO (
  ID_Evento INT AUTO_INCREMENT PRIMARY KEY,
  ID_Organizador INT NOT NULL,k
  Nombre_Evento VARCHAR(140) NOT NULL,
  Categoria VARCHAR(60) NOT NULL,
  Descripcion TEXT,
  Ciudad VARCHAR(80) NOT NULL,
  Lugar VARCHAR(120) NOT NULL,
  Direccion VARCHAR(180),
  Capacidad INT NOT NULL,
  Edad_Minima TINYINT UNSIGNED NOT NULL DEFAULT 0,
  Fecha_Inicio DATETIME NOT NULL,
  Fecha_Fin DATETIME NOT NULL,
  Estado_Evento ENUM('Borrador','Publicado','Cancelado','Finalizado') NOT NULL DEFAULT 'Borrador',
  Imagen_Portada VARCHAR(255),
  Imagen_Banner VARCHAR(255),
  CONSTRAINT FK_Evento_Organizador FOREIGN KEY (ID_Organizador)
    REFERENCES ORGANIZADOR(ID_Organizador) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT CHK_Evento_Capacidad CHECK (Capacidad > 0),
  CONSTRAINT CHK_Evento_Fechas CHECK (Fecha_Fin > Fecha_Inicio),
  CONSTRAINT CHK_Evento_Edad CHECK (Edad_Minima <= 99)
) ENGINE=InnoDB;

-- 3. TIPO_ENTRADA (incluye preventas como tipos distintos)
CREATE TABLE TIPO_ENTRADA (
  ID_Tipo_Entrada INT AUTO_INCREMENT PRIMARY KEY,
  ID_Evento INT NOT NULL,
  Nombre_Tipo VARCHAR(90) NOT NULL,
  Precio DECIMAL(10,2) NOT NULL,
  Cupo_Total INT NOT NULL,
  Fecha_Fin_Venta DATETIME,
  Estado_Tipo ENUM('Disponible','Cerrado') NOT NULL DEFAULT 'Disponible',
  CONSTRAINT FK_Tipo_Entrada_Evento FOREIGN KEY (ID_Evento)
    REFERENCES EVENTO(ID_Evento) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT UQ_Tipo_Entrada_Nombre UNIQUE (ID_Evento, Nombre_Tipo),
  CONSTRAINT CHK_Tipo_Entrada_Precio CHECK (Precio >= 0),
  CONSTRAINT CHK_Tipo_Entrada_Cupo CHECK (Cupo_Total > 0)
) ENGINE=InnoDB;

-- 4. CLIENTE
CREATE TABLE CLIENTE (
  ID_Cliente INT AUTO_INCREMENT PRIMARY KEY,
  Tipo_Documento ENUM('Cedula','Pasaporte') NOT NULL,
  Numero_Documento VARCHAR(24) NOT NULL,
  Nombre_Completo VARCHAR(120) NOT NULL,
  Correo VARCHAR(120) NOT NULL,
  Celular VARCHAR(20),
  Fecha_Registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT UQ_Cliente_Documento UNIQUE (Tipo_Documento, Numero_Documento)
) ENGINE=InnoDB;

-- 5. COMPRA (operaciones simuladas)
CREATE TABLE COMPRA (
  ID_Compra INT AUTO_INCREMENT PRIMARY KEY,
  ID_Cliente INT NOT NULL,
  Fecha_Compra DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Estado_Compra ENUM('Pendiente','Confirmada','Cancelada') NOT NULL DEFAULT 'Pendiente',
  Metodo_Registro ENUM('Web','Manual') NOT NULL DEFAULT 'Web',
  CONSTRAINT FK_Compra_Cliente FOREIGN KEY (ID_Cliente)
    REFERENCES CLIENTE(ID_Cliente) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. ENTRADA (una compra puede contener varias entradas)
CREATE TABLE ENTRADA (
  ID_Entrada INT AUTO_INCREMENT PRIMARY KEY,
  ID_Compra INT NOT NULL,
  ID_Tipo_Entrada INT NOT NULL,
  Codigo_Entrada VARCHAR(45) NOT NULL UNIQUE,
  Precio_Pagado DECIMAL(10,2) NOT NULL,
  Estado_Entrada ENUM('Emitida','Utilizada','Anulada') NOT NULL DEFAULT 'Emitida',
  Fecha_Generacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT FK_Entrada_Compra FOREIGN KEY (ID_Compra)
    REFERENCES COMPRA(ID_Compra) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT FK_Entrada_Tipo FOREIGN KEY (ID_Tipo_Entrada)
    REFERENCES TIPO_ENTRADA(ID_Tipo_Entrada) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT CHK_Entrada_Precio CHECK (Precio_Pagado >= 0)
) ENGINE=InnoDB;

-- 7. ARTISTA
CREATE TABLE ARTISTA (
  ID_Artista INT AUTO_INCREMENT PRIMARY KEY,
  Nombre_Artistico VARCHAR(120) NOT NULL,
  Genero_Musical VARCHAR(70),
  Instagram VARCHAR(180),
  Foto_Artista VARCHAR(255)
) ENGINE=InnoDB;

-- 8. PARTICIPACION (resuelve N:M entre EVENTO y ARTISTA)
CREATE TABLE PARTICIPACION (
  ID_Participacion INT AUTO_INCREMENT PRIMARY KEY,
  ID_Evento INT NOT NULL,
  ID_Artista INT NOT NULL,
  Hora_Presentacion DATETIME,
  Observacion VARCHAR(200),
  CONSTRAINT FK_Participacion_Evento FOREIGN KEY (ID_Evento)
    REFERENCES EVENTO(ID_Evento) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT FK_Participacion_Artista FOREIGN KEY (ID_Artista)
    REFERENCES ARTISTA(ID_Artista) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT UQ_Participacion UNIQUE (ID_Evento, ID_Artista)
) ENGINE=InnoDB;

-- 9. FOTO_EVENTO (memorias publicas con autorizacion previa)
CREATE TABLE FOTO_EVENTO (
  ID_Foto INT AUTO_INCREMENT PRIMARY KEY,
  ID_Evento INT NOT NULL,
  Titulo_Foto VARCHAR(120),
  URL_Foto VARCHAR(255) NOT NULL,
  Fecha_Publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Publicada BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT FK_Foto_Evento FOREIGN KEY (ID_Evento)
    REFERENCES EVENTO(ID_Evento) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT UQ_Foto_Url UNIQUE (URL_Foto)
) ENGINE=InnoDB;

-- DML: Datos 100% ficticios para practicar consultas.
-- Los numeros de documento no son documentos reales.

INSERT INTO ORGANIZADOR
 (Nombre_Organizador, Tipo_Organizador, Correo, Celular, Ciudad, Descripcion) VALUES
 ('RESAK Premium','Productora','resak.ejemplo@example.com','0990000001','Loja','Eventos musicales'),
 ('Escena Andina','Productora','andina@example.com','0990000002','Cuenca','Encuentros culturales'),
 ('Ruta Sonora','Empresa','ruta@example.com','0990000003','Quito','Festivales y conciertos'),
 ('Luna Urbana','Productora','luna@example.com','0990000004','Loja','Fiestas tematicas'),
 ('Horizonte Artistico','Artista','horizonte@example.com','0990000005','Ambato','Presentaciones en vivo');

INSERT INTO EVENTO
 (ID_Organizador, Nombre_Evento, Categoria, Descripcion, Ciudad, Lugar, Direccion, Capacidad,
  Edad_Minima, Fecha_Inicio, Fecha_Fin, Estado_Evento, Imagen_Portada, Imagen_Banner) VALUES
 (1,'Noche RESAK','Fiesta','Evento demostrativo de RESAK','Loja','Centro de eventos A','Zona centro',350,18,'2026-12-12 20:00:00','2026-12-13 03:00:00','Publicado','/media/resak_portada.jpg','/media/resak_banner.jpg'),
 (3,'Festival Horizonte','Festival','Festival musical de prueba','Quito','Recinto B','Av. Principal',600,0,'2026-12-19 17:00:00','2026-12-20 01:00:00','Publicado','/media/festival_portada.jpg','/media/festival_banner.jpg'),
 (4,'Beats de Ciudad','Concierto','Sesion electronica','Loja','Sala C','Calle Central',250,18,'2027-01-09 21:00:00','2027-01-10 02:00:00','Publicado','/media/beats_portada.jpg',NULL),
 (2,'Encuentro Cultural','Cultural','Encuentro finalizado','Cuenca','Teatro D','Sector Historico',180,0,'2026-08-20 18:00:00','2026-08-20 23:00:00','Finalizado','/media/cultural_portada.jpg',NULL),
 (5,'Sesion Acustica','Concierto','Evento en preparacion','Ambato','Auditorio E','Av. del Parque',150,0,'2027-02-06 19:00:00','2027-02-06 23:00:00','Borrador',NULL,NULL);

INSERT INTO TIPO_ENTRADA
 (ID_Evento, Nombre_Tipo, Precio, Cupo_Total, Fecha_Fin_Venta, Estado_Tipo) VALUES
 (1,'General Preventa 1',8.00,100,'2026-12-01 23:59:00','Disponible'),
 (1,'General Preventa 2',12.00,100,'2026-12-11 23:59:00','Disponible'),
 (1,'VIP',15.00,50,'2026-12-12 21:00:00','Disponible'),
 (2,'General',12.00,200,'2026-12-19 19:00:00','Disponible'),
 (2,'VIP',20.00,40,'2026-12-19 19:00:00','Disponible'),
 (3,'General',10.00,150,'2027-01-09 20:00:00','Disponible'),
 (4,'General',6.00,120,'2026-08-20 17:00:00','Cerrado'),
 (5,'General',5.00,100,'2027-02-06 18:00:00','Cerrado');

INSERT INTO CLIENTE
 (Tipo_Documento, Numero_Documento, Nombre_Completo, Correo, Celular) VALUES
 ('Cedula','0000000001','Cliente de Prueba 1','cliente1@example.com','0991111001'),
 ('Cedula','0000000002','Cliente de Prueba 2','cliente2@example.com','0991111002'),
 ('Pasaporte','PAS-EJ-003','Cliente de Prueba 3','cliente3@example.com','0991111003'),
 ('Cedula','0000000004','Cliente de Prueba 4','cliente4@example.com','0991111004'),
 ('Pasaporte','PAS-EJ-005','Cliente de Prueba 5','cliente5@example.com','0991111005');

INSERT INTO COMPRA
 (ID_Cliente, Fecha_Compra, Estado_Compra, Metodo_Registro) VALUES
 (1,'2026-10-10 10:00:00','Confirmada','Web'),
 (2,'2026-10-11 11:30:00','Confirmada','Web'),
 (3,'2026-10-12 16:00:00','Confirmada','Manual'),
 (4,'2026-08-19 18:00:00','Confirmada','Web'),
 (5,'2026-10-13 09:00:00','Confirmada','Web'),
 (1,'2026-10-14 13:00:00','Confirmada','Manual'),
 (2,'2026-10-15 08:00:00','Cancelada','Web');

-- Fecha_Generacion coincide con la compra de prueba.
-- Los eventos futuros no tienen entradas utilizadas.
INSERT INTO ENTRADA
 (ID_Compra, ID_Tipo_Entrada, Codigo_Entrada, Precio_Pagado, Estado_Entrada, Fecha_Generacion) VALUES
 (1,1,'EJ-0001',8.00,'Emitida','2026-10-10 10:00:00'),
 (1,1,'EJ-0002',8.00,'Emitida','2026-10-10 10:00:00'),
 (2,3,'EJ-0003',15.00,'Emitida','2026-10-11 11:30:00'),
 (3,4,'EJ-0004',12.00,'Emitida','2026-10-12 16:00:00'),
 (3,4,'EJ-0005',12.00,'Emitida','2026-10-12 16:00:00'),
 (4,7,'EJ-0006',6.00,'Utilizada','2026-08-19 18:00:00'),
 (5,6,'EJ-0007',10.00,'Emitida','2026-10-13 09:00:00'),
 (6,5,'EJ-0008',20.00,'Emitida','2026-10-14 13:00:00'),
 (6,5,'EJ-0009',20.00,'Emitida','2026-10-14 13:00:00'),
 (2,1,'EJ-0010',8.00,'Emitida','2026-10-11 11:30:00'),
 (4,7,'EJ-0011',6.00,'Utilizada','2026-08-19 18:00:00'),
 (7,8,'EJ-0012',5.00,'Anulada','2026-10-15 08:00:00');

INSERT INTO ARTISTA
 (Nombre_Artistico, Genero_Musical, Instagram, Foto_Artista) VALUES
 ('DJ Aurora','House','https://instagram.com','/media/artistas/aurora.jpg'),
 ('DJ Nebula','Tech House','https://instagram.com','/media/artistas/nebula.jpg'),
 ('Banda Ruta','Pop','https://instagram.com','/media/artistas/ruta.jpg'),
 ('Solista Luz','Pop','https://instagram.com','/media/artistas/luz.jpg'),
 ('Orquesta Horizonte','Tropical','https://instagram.com','/media/artistas/horizonte.jpg');

INSERT INTO PARTICIPACION
 (ID_Evento, ID_Artista, Hora_Presentacion, Observacion) VALUES
 (1,1,'2026-12-12 22:00:00','Apertura'),
 (1,2,'2026-12-13 00:00:00','Cierre'),
 (2,3,'2026-12-19 20:00:00','Concierto'),
 (2,4,'2026-12-19 21:00:00','Invitada'),
 (3,1,'2027-01-09 23:00:00','Set principal'),
 (4,5,'2026-08-20 19:00:00','Presentacion central'),
 (5,4,'2027-02-06 20:00:00','Programacion preliminar');

INSERT INTO FOTO_EVENTO
 (ID_Evento, Titulo_Foto, URL_Foto, Fecha_Publicacion, Publicada) VALUES
 (4,'Apertura','/media/memorias/cultural_01.jpg','2026-08-21 10:00:00',TRUE),
 (4,'Presentacion','/media/memorias/cultural_02.jpg','2026-08-21 10:05:00',TRUE),
 (4,'Publico','/media/memorias/cultural_03.jpg','2026-08-21 10:10:00',TRUE),
 (4,'Escenario','/media/memorias/cultural_04.jpg','2026-08-21 10:15:00',TRUE),
 (4,'Cierre','/media/memorias/cultural_05.jpg','2026-08-21 10:20:00',TRUE);

-- CONSULTAS DE ALGEBRA RELACIONAL TRADUCIDAS A SQL


-- CONSULTA 1. Seleccion: Eventos publicados con organizador.
SELECT E.Nombre_Evento, O.Nombre_Organizador
FROM EVENTO AS E
INNER JOIN ORGANIZADOR AS O ON E.ID_Organizador = O.ID_Organizador
WHERE E.Estado_Evento = 'Publicado';

-- CONSULTA 2. Proyeccion: memorias de eventos finalizados, artistas y fotos.
SELECT DISTINCT E.Nombre_Evento, A.Nombre_Artistico,
       A.Instagram, F.URL_Foto
FROM EVENTO AS E
INNER JOIN FOTO_EVENTO AS F ON E.ID_Evento = F.ID_Evento
INNER JOIN PARTICIPACION AS P ON E.ID_Evento = P.ID_Evento
INNER JOIN ARTISTA AS A ON P.ID_Artista = A.ID_Artista
WHERE E.Estado_Evento = 'Finalizado' AND F.Publicada = TRUE;

-- CONSULTA 3. Seleccion y proyeccion: Entradas de hasta 12 dolares
-- para eventos publicados.
SELECT E.Nombre_Evento, T.Nombre_Tipo, T.Precio
FROM EVENTO AS E
INNER JOIN TIPO_ENTRADA AS T ON E.ID_Evento = T.ID_Evento
WHERE E.Estado_Evento = 'Publicado' AND T.Precio <= 12.00;

-- CONSULTA 4. Reunion: Compradores, sus entradas y eventos.
SELECT C.Nombre_Completo, N.Codigo_Entrada,
       E.Nombre_Evento, T.Nombre_Tipo
FROM CLIENTE AS C
INNER JOIN COMPRA AS CO ON C.ID_Cliente = CO.ID_Cliente
INNER JOIN ENTRADA AS N ON CO.ID_Compra = N.ID_Compra
INNER JOIN TIPO_ENTRADA AS T ON N.ID_Tipo_Entrada = T.ID_Tipo_Entrada
INNER JOIN EVENTO AS E ON T.ID_Evento = E.ID_Evento
WHERE CO.Estado_Compra = 'Confirmada' AND N.Estado_Entrada <> 'Anulada';

-- CONSULTA 5. Agrupacion: entradas vendidas e ingresos por evento.
SELECT E.ID_Evento, E.Nombre_Evento,
       COUNT(N.ID_Entrada) AS Entradas_Vendidas,
       SUM(N.Precio_Pagado) AS Ingresos_Simulados
FROM EVENTO AS E
INNER JOIN TIPO_ENTRADA AS T ON E.ID_Evento = T.ID_Evento
INNER JOIN ENTRADA AS N ON T.ID_Tipo_Entrada = N.ID_Tipo_Entrada
INNER JOIN COMPRA AS CO ON N.ID_Compra = CO.ID_Compra
WHERE CO.Estado_Compra = 'Confirmada' AND N.Estado_Entrada <> 'Anulada'
GROUP BY E.ID_Evento, E.Nombre_Evento
ORDER BY E.ID_Evento;
