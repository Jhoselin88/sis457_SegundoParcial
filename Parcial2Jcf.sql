-- Crear la base de datos
CREATE DATABASE Parcial2Jcf;
GO

-- Usar la base de datos
USE Parcial2Jcf;
GO

-- Crear tabla Canal
CREATE TABLE Canal (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    frecuencia VARCHAR(20),
    estado SMALLINT DEFAULT 1  -- 1 = activo, 0 = inactivo
);
GO

-- Crear tabla Programa
CREATE TABLE Programa (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idCanal INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(250),
    duracion INT,
    productor VARCHAR(100),
    fechaEstreno DATE,
    estado SMALLINT DEFAULT 1,  -- 1 = activo, 0 = inactivo
    CONSTRAINT FK_Programa_Canal FOREIGN KEY (idCanal) REFERENCES Canal(id)
);
GO
select * from Canal;
select * from Programa;
-- Crear usuario para acceso desde la capa de datos
CREATE LOGIN usrparcial2 WITH PASSWORD = '12345678';
GO

CREATE USER usrparcial2 FOR LOGIN usrparcial2;
GO

-- Dar permisos necesarios al usuario
GRANT SELECT, INSERT, UPDATE, DELETE ON Canal TO usrparcial2;
GRANT SELECT, INSERT, UPDATE, DELETE ON Programa TO usrparcial2;
GO

DROP PROCEDURE IF EXISTS paProgramaListar;
GO

-- Listar Canales
DROP PROCEDURE IF EXISTS paCanalListar;
GO
CREATE PROCEDURE paCanalListar
    @parametro NVARCHAR(100)
AS
BEGIN
    SELECT 
        id, 
        nombre, 
        frecuencia, 
        estado
    FROM Canal
    WHERE estado != -1
      AND (
          nombre LIKE '%' + @parametro + '%' 
          OR frecuencia LIKE '%' + @parametro + '%'
          OR @parametro = ''
      )
    ORDER BY nombre;
END
GO

-- Guardar Canal (Insertar o Actualizar)
DROP PROCEDURE IF EXISTS paCanalGuardar;
GO
CREATE PROCEDURE paCanalGuardar
    @id INT OUTPUT,
    @nombre VARCHAR(50),
    @frecuencia VARCHAR(20),
    @estado SMALLINT
AS
BEGIN
    IF @id = 0 OR @id IS NULL
    BEGIN
        -- Insertar nuevo canal
        INSERT INTO Canal (nombre, frecuencia, estado)
        VALUES (@nombre, @frecuencia, @estado);
        
        SET @id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        -- Actualizar canal existente
        UPDATE Canal
        SET nombre = @nombre,
            frecuencia = @frecuencia,
            estado = @estado
        WHERE id = @id;
    END
END
GO

-- Eliminar Canal (eliminación lógica)
DROP PROCEDURE IF EXISTS paCanalEliminar;
GO
CREATE PROCEDURE paCanalEliminar
    @id INT
AS
BEGIN
    -- Primero eliminar (lógicamente) todos los programas asociados
    UPDATE Programa
    SET estado = -1
    WHERE idCanal = @id;
    
    -- Luego eliminar (lógicamente) el canal
    UPDATE Canal
    SET estado = -1
    WHERE id = @id;
END
GO

-- =====================================================
-- STORED PROCEDURES PARA PROGRAMA
-- =====================================================

-- Listar Programas
DROP PROCEDURE IF EXISTS paProgramaListar;
GO
CREATE PROCEDURE paProgramaListar
    @parametro NVARCHAR(100)
AS
BEGIN
    SELECT 
        p.id, 
        p.titulo, 
        p.descripcion, 
        p.duracion, 
        p.productor,
        p.fechaEstreno, 
        p.idCanal, 
        c.nombre AS nombreCanal,
        p.estado
    FROM Programa p
    INNER JOIN Canal c ON p.idCanal = c.id
    WHERE p.estado != -1
      AND (
          p.titulo LIKE '%' + @parametro + '%' 
          OR p.descripcion LIKE '%' + @parametro + '%'
          OR c.nombre LIKE '%' + @parametro + '%'
          OR p.productor LIKE '%' + @parametro + '%'
          OR @parametro = ''
      )
    ORDER BY p.titulo;
END
GO

-- Guardar Programa (Insertar o Actualizar)
DROP PROCEDURE IF EXISTS paProgramaGuardar;
GO
CREATE PROCEDURE paProgramaGuardar
    @id INT OUTPUT,
    @idCanal INT,
    @titulo VARCHAR(100),
    @descripcion VARCHAR(250),
    @duracion INT,
    @productor VARCHAR(100),
    @fechaEstreno DATE,
    @estado SMALLINT
AS
BEGIN
    IF @id = 0 OR @id IS NULL
    BEGIN
        -- Insertar nuevo programa
        INSERT INTO Programa (idCanal, titulo, descripcion, duracion, productor, fechaEstreno, estado)
        VALUES (@idCanal, @titulo, @descripcion, @duracion, @productor, @fechaEstreno, @estado);
        
        SET @id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        -- Actualizar programa existente
        UPDATE Programa
        SET idCanal = @idCanal,
            titulo = @titulo,
            descripcion = @descripcion,
            duracion = @duracion,
            productor = @productor,
            fechaEstreno = @fechaEstreno,
            estado = @estado
        WHERE id = @id;
    END
END
GO

-- Eliminar Programa (eliminación lógica)
DROP PROCEDURE IF EXISTS paProgramaEliminar;
GO
CREATE PROCEDURE paProgramaEliminar
    @id INT
AS
BEGIN
    UPDATE Programa
    SET estado = -1
    WHERE id = @id;
END
GO

-- Obtener un programa por ID
DROP PROCEDURE IF EXISTS paProgramaObtener;
GO
CREATE PROCEDURE paProgramaObtener
    @id INT
AS
BEGIN
    SELECT 
        p.id, 
        p.titulo, 
        p.descripcion, 
        p.duracion, 
        p.productor,
        p.fechaEstreno, 
        p.idCanal, 
        c.nombre AS nombreCanal,
        p.estado
    FROM Programa p
    INNER JOIN Canal c ON p.idCanal = c.id
    WHERE p.id = @id AND p.estado != -1;
END
GO

-- =====================================================
-- FUNCTIONS ÚTILES
-- =====================================================

-- Función para contar programas por canal
DROP FUNCTION IF EXISTS fnContarProgramasPorCanal;
GO
CREATE FUNCTION fnContarProgramasPorCanal(@idCanal INT)
RETURNS INT
AS
BEGIN
    DECLARE @cantidad INT;
    
    SELECT @cantidad = COUNT(*)
    FROM Programa
    WHERE idCanal = @idCanal AND estado != -1;
    
    RETURN ISNULL(@cantidad, 0);
END
GO

-- Función para obtener duración total de programas por canal
DROP FUNCTION IF EXISTS fnDuracionTotalPorCanal;
GO
CREATE FUNCTION fnDuracionTotalPorCanal(@idCanal INT)
RETURNS INT
AS
BEGIN
    DECLARE @duracionTotal INT;
    
    SELECT @duracionTotal = SUM(duracion)
    FROM Programa
    WHERE idCanal = @idCanal AND estado != -1;
    
    RETURN ISNULL(@duracionTotal, 0);
END
GO

-- Función para validar si existe un programa con el mismo título
DROP FUNCTION IF EXISTS fnExisteProgramaTitulo;
GO
CREATE FUNCTION fnExisteProgramaTitulo(@titulo VARCHAR(100), @idExcluir INT)
RETURNS BIT
AS
BEGIN
    DECLARE @existe BIT = 0;
    
    IF EXISTS (
        SELECT 1 
        FROM Programa 
        WHERE titulo = @titulo 
          AND estado != -1 
          AND id != ISNULL(@idExcluir, 0)
    )
        SET @existe = 1;
    
    RETURN @existe;
END
GO

-- Vista para reportes de programas por canal
DROP VIEW IF EXISTS vwProgramasPorCanal;
GO
CREATE VIEW vwProgramasPorCanal
AS
SELECT 
    c.id AS idCanal,
    c.nombre AS nombreCanal,
    c.frecuencia,
    COUNT(p.id) AS cantidadProgramas,
    SUM(p.duracion) AS duracionTotal,
    AVG(p.duracion) AS duracionPromedio
FROM Canal c
LEFT JOIN Programa p ON c.id = p.idCanal AND p.estado != -1
WHERE c.estado != -1
GROUP BY c.id, c.nombre, c.frecuencia;
GO

-- =====================================================
-- CREAR USUARIO Y PERMISOS
-- =====================================================

-- Crear usuario para acceso desde la capa de datos
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usrparcial2')
BEGIN
    CREATE LOGIN usrparcial2 WITH PASSWORD = '12345678';
END
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usrparcial2')
BEGIN
    CREATE USER usrparcial2 FOR LOGIN usrparcial2;
END
GO

-- Dar permisos necesarios al usuario
GRANT SELECT, INSERT, UPDATE, DELETE ON Canal TO usrparcial2;
GRANT SELECT, INSERT, UPDATE, DELETE ON Programa TO usrparcial2;
GRANT EXECUTE ON paCanalListar TO usrparcial2;
GRANT EXECUTE ON paCanalGuardar TO usrparcial2;
GRANT EXECUTE ON paCanalEliminar TO usrparcial2;
GRANT EXECUTE ON paProgramaListar TO usrparcial2;
GRANT EXECUTE ON paProgramaGuardar TO usrparcial2;
GRANT EXECUTE ON paProgramaEliminar TO usrparcial2;
GRANT EXECUTE ON paProgramaObtener TO usrparcial2;
GRANT SELECT ON vwProgramasPorCanal TO usrparcial2;
GO

-- =====================================================
-- DATOS DE PRUEBA
-- =====================================================

-- Limpiar datos previos (opcional)
DELETE FROM Programa;
DELETE FROM Canal;
DBCC CHECKIDENT ('Programa', RESEED, 0);
DBCC CHECKIDENT ('Canal', RESEED, 0);
GO

-- Insertar canales
INSERT INTO Canal (nombre, frecuencia, estado)
VALUES
('Canal Noticias 24', '101.5 MHz', 1),
('CineMax TV', '89.9 MHz', 1),
('Deportes Total', '95.7 MHz', 1),
('Musica Viva', '103.2 MHz', 1),
('Cultura Plus', '107.1 MHz', 1);
GO

-- Insertar programas
INSERT INTO Programa (idCanal, titulo, descripcion, duracion, productor, fechaEstreno, estado)
VALUES
(1, 'Noticias de la Mañana', 'Resumen informativo diario con las principales noticias nacionales e internacionales.', 60, 'Juan Pérez', '2024-01-10', 1),
(1, 'Entrevista en Vivo', 'Programa de entrevistas con personalidades del ámbito político y social.', 45, 'Laura Gómez', '2024-02-20', 1),
(2, 'Cine de Noche', 'Proyección de películas clásicas de Hollywood.', 120, 'Carlos Medina', '2023-11-05', 1),
(2, 'Detrás de las Cámaras', 'Documental sobre la producción cinematográfica y efectos especiales.', 50, 'Andrea López', '2024-03-15', 1),
(3, 'Fútbol Total', 'Análisis de los principales partidos del fin de semana.', 90, 'Diego Herrera', '2023-12-01', 1),
(3, 'Carreras al Límite', 'Cobertura de eventos de automovilismo internacional.', 60, 'Roberto Díaz', '2024-04-10', 1),
(4, 'Top Hits', 'Los éxitos musicales más sonados de la semana.', 30, 'María Torres', '2023-09-18', 1),
(4, 'Detrás del Escenario', 'Entrevistas con artistas y bandas emergentes.', 45, 'Sofía Martínez', '2024-05-22', 1),
(5, 'Arte y Cultura', 'Exploración de eventos culturales y artísticos locales.', 60, 'Lucía Fernández', '2023-10-30', 1),
(5, 'Historia Viva', 'Serie documental sobre hechos históricos relevantes.', 50, 'Jorge Ramírez', '2024-06-12', 1);
GO

-- =====================================================
-- PRUEBAS DE LOS STORED PROCEDURES
-- =====================================================

PRINT '=== PRUEBA DE PROCEDIMIENTOS ALMACENADOS ==='
GO

-- Prueba de listar canales
PRINT 'Listando todos los canales:'
EXEC paCanalListar @parametro = '';
GO

-- Prueba de listar programas
PRINT 'Listando programas con "Cine":'
EXEC paProgramaListar @parametro = 'Cine';
GO

-- Prueba de la vista
PRINT 'Reporte de programas por canal:'
SELECT * FROM vwProgramasPorCanal;
GO

-- Prueba de función para contar programas
PRINT 'Cantidad de programas del canal 1:'
SELECT dbo.fnContarProgramasPorCanal(1) AS CantidadProgramas;
GO

PRINT 'Base de datos configurada correctamente con Stored Procedures y Functions!'
GO