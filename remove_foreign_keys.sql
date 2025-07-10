
-- =============================
-- Script para eliminar FOREIGN KEY constraints antes de eliminar tablas
-- =============================

-- Generar comandos dinámicos para eliminar claves foráneas
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += 'ALTER TABLE [' + OBJECT_NAME(f.parent_object_id) + '] DROP CONSTRAINT [' + f.name + '];' + CHAR(13)
FROM sys.foreign_keys AS f;

EXEC sp_executesql @sql;

-- Ahora ya puedes hacer DROP TABLE sin errores
