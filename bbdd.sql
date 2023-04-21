USE [master]
GO

CREATE DATABASE [TodoList]
GO

USE [TodoList]
GO

CREATE TABLE [dbo].[Notas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Texto] [varchar](250) NOT NULL,
	[Finalizada] [bit] NOT NULL
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[LogNotas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FechaLog] [date] NOT NULL,
	[Accion] [varchar](6) NOT NULL,
	[Texto] [varchar](250) NOT NULL,
	[Finalizada] [bit] NOT NULL
) ON [PRIMARY]
GO

CREATE TRIGGER tgrLogNotas
   ON  Notas
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

    DECLARE @accion CHAR(6)
		SET @accion = CASE
				WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
					THEN 'Update'
				WHEN EXISTS(SELECT * FROM inserted)
					THEN 'Insert'
				WHEN EXISTS(SELECT * FROM deleted)
					THEN 'Delete'
				ELSE NULL
		END
	IF @accion = 'Delete' OR @accion = 'Update'
			INSERT INTO LogNotas (FechaLog, Accion, Texto, Finalizada)
			SELECT GETDATE(), @accion, d.Texto, d.Finalizada
			FROM deleted d
 
	IF @accion = 'Insert'
			INSERT INTO LogNotas (FechaLog, Accion, Texto, Finalizada)
			SELECT GETDATE(), @accion, i.Texto, i.Finalizada
			FROM inserted i

END
GO
