USE DivisionPolitica
GO
-- PUNTO 1

CREATE TABLE #Japon(
    Prefectura  varchar(50) NOT NULL,   
    Capital     varchar(50) NOT NULL,   
    Area        float       NULL,       
    Poblacion   int         NULL        
)


BULK INSERT #Japon
    FROM 'C:\Users\Carlos Gonzalez\Documents\cursos\BASE DE DATOS\EJERCICIOS\Taller 4\Japon.csv'
    WITH (
        DATAFILETYPE   = 'char',
        FIELDTERMINATOR = ','
    )

--Agregar los registros de REGION 
DECLARE @IdPais int 
SET @IdPais=(SELECT TOP 1 Id FROM Pais WHERE Nombre='Japón') 
IF @IdPais is null 
BEGIN 
    --Si el PAIS no existe... 
    --Obtener el codigo de TIPO REGION 
    DECLARE @IdTR int 
    SET @IdTR=(SELECT TOP 1 Id FROM TipoRegion WHERE 
TipoRegion='Prefectura') 
    IF @IdTR is null 
        BEGIN 
            INSERT INTO TipoRegion 
                (TipoRegion)
                VALUES('Prefectura') 
            SET @IdTR=@@IDENTITY 
        END 
        --Obtener el codigo de CONTINENTE 
        DECLARE @IdC int 
        SET @IdC=(SELECT TOP 1 Id FROM Continente WHERE Nombre='Asia') 
        IF @IdC is null 
        BEGIN 
            INSERT INTO Continente 
                (Nombre) 
                VALUES('Asia') 
            SET @IdC=@@IDENTITY 
        END 
        --Agregar el PAIS 
        INSERT INTO Pais 
            (Nombre, IdContinente, IdTipoRegion) 
            VALUES('Japón', @IdC, @IdTR) 
        SET @IdPais=@@IDENTITY 
END

INSERT INTO Region 
    (Nombre, IdPais, Area, Poblacion) 
    SELECT J.Prefectura, @IdPais, J.Area, J.Poblacion 
        FROM #Japon J 
        
        
--Agregar los registros de CIUDAD 
INSERT INTO Ciudad 
    (Nombre, IdRegion, CapitalRegion) 
    SELECT J.Capital, R.Id, 1 
        FROM #Japon J 
            JOIN Region R ON J.Prefectura=R.Nombre AND R.IdPais=@IdPais 
            
--Verificando las actualizaciones 

SELECT * 
FROM Pais P 
     JOIN Region R ON P.Id=R.IdPais 
     JOIN Ciudad C ON R.Id=C.IdRegion 
WHERE P.Nombre='Japón'

----------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------
--PUNTO 2
-- PASO 1: Crear la tabla Moneda
CREATE TABLE Moneda (
    Id     int           IDENTITY(1,1) NOT NULL,
    CONSTRAINT pkMoneda_Id PRIMARY KEY (Id),
    Moneda nvarchar(50)  NOT NULL,
    Sigla  nvarchar(10)  NULL,
    Imagen varbinary(MAX) NULL
)

-- PASO 2: Poblar Moneda con valores únicos que ya existen en Pais
INSERT INTO Moneda (Moneda)
    SELECT DISTINCT Moneda
    FROM Pais
    WHERE Moneda IS NOT NULL
GO

-- PASO 3: Agregar columna IdMoneda en Pais 
ALTER TABLE Pais
    ADD IdMoneda int NULL
GO

-- PASO 4: Llenar IdMoneda cruzando por nombre de moneda
UPDATE P
    SET P.IdMoneda = M.Id
FROM Pais P
    JOIN Moneda M ON P.Moneda = M.Moneda
GO

-- PASO 5: Eliminar columna texto Moneda de Pais
ALTER TABLE Pais
    DROP COLUMN Moneda
GO

-- PASO 6: Agregar la llave foránea
ALTER TABLE Pais
    ADD CONSTRAINT fkPais_IdMoneda
        FOREIGN KEY (IdMoneda)
        REFERENCES Moneda(Id)
GO
-- PASO 7: Agregar campos Mapa y Bandera
ALTER TABLE Pais
    ADD Mapa    varbinary(MAX) NULL,
        Bandera varbinary(MAX) NULL
GO

-- PASO 8: Indice unico para Moneda
CREATE UNIQUE INDEX ixMoneda_Moneda
    ON Moneda(Moneda)
GO


-- PASO 9: Verificar resultado final
SELECT TOP 10 *
FROM vwCiudades
WHERE Pais = 'COLOMBIA'
ORDER BY Region, Ciudad
GO

