CREATE DATABASE Parcial2Jcf;
USE master
drop LOGIN  usrparcial2;
GO 
CREATE LOGIN usrparcial2 WITH PASSWORD = '12345678',
	CHECK_pOLICY = ON,
	CHECK_EXPIRATION = OFF,
	DEFAULT_DATABASE = Parcial2Jcf
GO
USE Parcial2Jcf
GO 
CREATE USER usrparcial2 FOR LOGIN usrparcial2
GO
ALTER ROLE db_owner ADD MEMBER usrparcial2
GO

DROP PROC IF EXISTS paListarProgramas;
DROP PROC IF EXISTS paListarCanales;
/* Para borrar Tabalas -> UEPS */
DROP TABLE Programa;
DROP TABLE Canal;

DROP TABLE IF EXISTS Progama;
DROP TABLE IF EXISTS Canal;

/*Creacion de tablas en SQLserver */
CREATE TABLE Canal (
    id INT IDENTITY(1, 1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    frecuencia VARCHAR(20),
    estado SMALLINT
);

CREATE TABLE Programa (
    id INT IDENTITY(1, 1) PRIMARY KEY,
    idCanal INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(250),
    duracion INT,
    clasificacion VARCHAR(50),
    productor VARCHAR(100),
    fechaEstreno DATE,
    estado SMALLINT,
    
    CONSTRAINT fk_Programa_Canal 
        FOREIGN KEY (idCanal) 
        REFERENCES Canal (id)
);

-- Agregar columnas de auditoria y estado
ALTER TABLE Canal ADD  usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Canal ADD  fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Canal ADD  estadoRegistro SMALLINT NOT NULL DEFAULT 1; -- -1: Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Programa ADD  usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Programa ADD  fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Programa ADD  estadoRegistro SMALLINT NOT NULL DEFAULT 1; -- -1: Eliminado, 0: Inactivo, 1: Activo


GO
DROP PROC IF EXISTS paProgramaListar; -- Elimina el procedimiento si ya existe
GO
CREATE PROC paProgramaListar 
    @parametro VARCHAR(50) 
AS
BEGIN
    SELECT 
        p.id, 
        p.idCanal, 
        c.nombre AS nombreCanal, 
        p.titulo, 
        p.descripcion, 
        p.duracion, 
        p.productor, 
        p.fechaEstreno, 
        P.clasificacion,
        p.estado,
        p.usuarioRegistro,
        p.fechaRegistro,
        p.estadoRegistro
    FROM 
        Programa p
    INNER JOIN 
        Canal c ON c.id = p.idCanal
    WHERE p.estadoRegistro > 0
        AND (ISNULL(p.titulo,'') + ISNULL(p.descripcion,'') + ISNULL(c.nombre,'')) 
    LIKE '%' + REPLACE(@parametro,' ','%') + '%'
    ORDER BY 
        p.estado DESC, 
        p.titulo ASC;
END
GO
EXEC paProgramaListar 'noticias tarde';
GO
EXEC paProgramaListar '';

-- DML
INSERT INTO Canal (nombre, frecuencia, estado) VALUES 
('Canal 1', '101.1 FM', 1),
('Canal 2', '102.2 FM', 1),
('Canal 3', '103.3 FM', 0); 

INSERT INTO Programa (idCanal, titulo, descripcion, duracion, productor, fechaEstreno, estado) VALUES 
(1, 'Noticiero Matutino', 'Noticias de la mañana', 60, 'Juan Perez', '2023-01-15', 1),
(1, 'Show de Comedia', 'Programa de comedia y entretenimiento', 30, 'Ana Gomez', '2023-02-20', 1),
(2, 'Documental de Naturaleza', 'Explorando la vida salvaje', 45, 'Carlos Ruiz', '2023-03-10', 0),
(3, 'Programa Deportivo', 'Resumen de eventos deportivos', 60, 'Luis Martinez', '2023-04-05', 1);

-- Leer 
SELECT * FROM Canal;
SELECT * FROM Programa;