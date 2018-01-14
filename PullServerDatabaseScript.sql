/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [DSC]
GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****
CREATE TRIGGER [dbo].[DSCStatusReportOnUpdate]
   ON  [dbo].[StatusReport] 
   AFTER UPDATE
AS
SET NOCOUNT ON
BEGIN
    DECLARE @JobId nvarchar(50) = (SELECT JobId FROM inserted);
    DECLARE @StatusData nvarchar(MAX) = (SELECT StatusData FROM inserted);
    IF @StatusData LIKE '\[%' ESCAPE '\'
        SET @StatusData = REPLACE(SUBSTRING(@StatusData, 3, Len(@StatusData) - 4), '\', '')
    DECLARE @Errors nvarchar(MAX) = (SELECT [Errors] FROM inserted);
    IF @Errors IS NULL
        SET @Errors = (SELECT Errors FROM StatusReport WHERE JobId = @JobId)
    
    IF @Errors LIKE '\[%' ESCAPE '\' AND Len(@Errors) > 4
        SET @Errors = REPLACE(SUBSTRING(@Errors, 3, Len(@Errors) - 4), '\', '')
    UPDATE StatusReport
    SET StatusData = @StatusData, Errors = @Errors
    WHERE JobId = @JobId
    
END
GO
ALTER TABLE [dbo].[StatusReport] ENABLE TRIGGER [DSCStatusReportOnUpdate]
GO
*****/
--Adding functions
CREATE FUNCTION [dbo].[Split] (
      @InputString                  VARCHAR(8000),
      @Delimiter                    VARCHAR(50)
)
RETURNS @Items TABLE (
      Item                          VARCHAR(8000)
)
AS
BEGIN
      IF @Delimiter = ' '
      BEGIN
            SET @Delimiter = ','
            SET @InputString = REPLACE(@InputString, ' ', @Delimiter)
      END
      IF (@Delimiter IS NULL OR @Delimiter = '')
            SET @Delimiter = ','
      DECLARE @Item           VARCHAR(8000)
      DECLARE @ItemList       VARCHAR(8000)
      DECLARE @DelimIndex     INT
      SET @ItemList = @InputString
      SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      WHILE (@DelimIndex != 0)
      BEGIN
            SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex)
            INSERT INTO @Items VALUES (@Item)
            -- Set @ItemList = @ItemList minus one less item
            SET @ItemList = SUBSTRING(@ItemList, @DelimIndex+1, LEN(@ItemList)-@DelimIndex)
            SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      END -- End WHILE
      IF @Item IS NOT NULL -- At least one delimiter was encountered in @InputString
      BEGIN
            SET @Item = @ItemList
            INSERT INTO @Items VALUES (@Item)
      END
      -- No delimiters were encountered in @InputString, so just return @InputString
      ELSE INSERT INTO @Items VALUES (@InputString)
      RETURN
END -- End Function
GO
/****** Object:  Table [dbo].[RegistrationData]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegistrationData](
	[AgentId] [nvarchar](255) NOT NULL,
	[LCMVersion] [nvarchar](255) NULL,
	[NodeName] [nvarchar](255) NULL,
	[IPAddress] [nvarchar](255) NULL,
	[ConfigurationNames] [nvarchar](max) NULL,
 CONSTRAINT [PK_RegistrationData] PRIMARY KEY CLUSTERED 
(
	[AgentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[tvfGetRegistrationData]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[tvfGetRegistrationData] ()
RETURNS TABLE
    AS
RETURN
(
    SELECT NodeName, AgentId,
        (SELECT TOP (1) Item FROM dbo.Split(dbo.RegistrationData.IPAddress, ';') AS IpAddresses) AS IP,
        (SELECT(SELECT [Value] + ',' AS [text()] FROM OPENJSON([ConfigurationNames]) FOR XML PATH (''))) AS ConfigurationName,
        (SELECT COUNT(*) FROM (SELECT [Value] FROM OPENJSON([ConfigurationNames]))AS ConfigurationCount ) AS ConfigurationCount
    FROM dbo.RegistrationData
)
GO
/****** Object:  Table [dbo].[StatusReport]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StatusReport](
	[JobId] [nvarchar](50) NOT NULL,
	[Id] [nvarchar](50) NOT NULL,
	[OperationType] [nvarchar](255) NULL,
	[RefreshMode] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[LCMVersion] [nvarchar](50) NULL,
	[ReportFormatVersion] [nvarchar](255) NULL,
	[ConfigurationVersion] [nvarchar](255) NULL,
	[NodeName] [nvarchar](255) NULL,
	[IPAddress] [nvarchar](255) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Errors] [nvarchar](max) NULL,
	[StatusData] [nvarchar](max) NULL,
	[RebootRequested] [nvarchar](255) NULL,
	[AdditionalData] [nvarchar](max) NULL,
 CONSTRAINT [PK_StatusReport] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[tvfGetNodeStatus]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[tvfGetNodeStatus] ()
RETURNS TABLE
    AS
RETURN
(
    SELECT [dbo].[StatusReport].[NodeName]
	,[Status] = Case dbo.StatusReport.OperationType
				When 'Initial' Then 'Success'
				Else dbo.StatusReport.[Status]
				End
	,[dbo].[StatusReport].[Id] AS [AgentId]
	,[dbo].[StatusReport].[EndTime] AS [Time]
	,[dbo].[StatusReport].[RebootRequested]
	,[dbo].[StatusReport].[OperationType]
	,(
	SELECT [HostName] FROM OPENJSON(
		(SELECT [value] FROM OPENJSON([StatusData]))
	) WITH (HostName nvarchar(200) '$.HostName')) AS HostName
	,(
	SELECT [ResourceId] + ',' AS [text()] 
	FROM OPENJSON(
	(SELECT [value] FROM OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesInDesiredState')
	)
	WITH (
		ResourceId nvarchar(200) '$.ResourceId'
	) FOR XML PATH ('')) AS ResourcesInDesiredState
	,(
	SELECT [ResourceId] + ',' AS [text()] 
	FROM OPENJSON(
	(SELECT [value] FROM OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesNotInDesiredState')
	)
	WITH (
		ResourceId nvarchar(200) '$.ResourceId'
	) FOR XML PATH ('')) AS ResourcesNotInDesiredState
	,(
	SELECT SUM(TRY_CAST(DurationInSeconds AS float)) AS Duration
	FROM OPENJSON(
	(SELECT [value] FROM OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesInDesiredState')
	)
	WITH (   
			DurationInSeconds nvarchar(50) '$.DurationInSeconds',
			InDesiredState bit '$.InDesiredState'
		)
	) AS Duration
	,(
	SELECT [DurationInSeconds] FROM OPENJSON(
		(SELECT [value] FROM OPENJSON([StatusData]))
	) WITH (DurationInSeconds nvarchar(200) '$.DurationInSeconds')) AS DurationWithOverhead
	,(
	SELECT COUNT(*)
	FROM OPENJSON(
	(SELECT [value] FROM OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesInDesiredState')
	)) AS ResourceCountInDesiredState
	
	,(
	SELECT COUNT(*)
	FROM OPENJSON(
	(SELECT [value] FROM OPENJSON((SELECT [value] FROM OPENJSON([StatusData]))) WHERE [key] = 'ResourcesNotInDesiredState')
	)) AS ResourceCountNotInDesiredState
	,(
	SELECT [ResourceId] + ':' + ' (' + [ErrorCode] + ') ' + [ErrorMessage] + ',' AS [text()]
	FROM OPENJSON(
	(SELECT TOP 1  [value] FROM OPENJSON([Errors]))
	)
	WITH (
		ErrorMessage nvarchar(200) '$.ErrorMessage',
		ErrorCode nvarchar(20) '$.ErrorCode',
		ResourceId nvarchar(200) '$.ResourceId'
	) FOR XML PATH ('')) AS ErrorMessage
	,(
	SELECT [value] FROM OPENJSON([StatusData])
	) AS RawStatusData
	FROM dbo.StatusReport INNER JOIN
	(SELECT MAX(EndTime) AS MaxEndTime, NodeName
	FROM dbo.StatusReport AS StatusReport_1
	WHERE EndTime > '1.1.2000'
	GROUP BY [StatusReport_1].[NodeName]) AS SubMax ON dbo.StatusReport.EndTime = SubMax.MaxEndTime AND [dbo].[StatusReport].[NodeName] = SubMax.NodeName
)
GO
/****** Object:  View [dbo].[vRegistrationData]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Adding views
CREATE VIEW [dbo].[vRegistrationData]
AS
SELECT GetRegistrationData.*
FROM dbo.tvfGetRegistrationData() AS GetRegistrationData
GO
/****** Object:  View [dbo].[vNodeStatusSimple]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vNodeStatusSimple]
AS
SELECT dbo.StatusReport.NodeName, dbo.StatusReport.Status, dbo.StatusReport.EndTime AS Time
FROM dbo.StatusReport INNER JOIN
    (SELECT MAX(EndTime) AS MaxEndTime, NodeName
    FROM dbo.StatusReport AS StatusReport_1
    GROUP BY NodeName) AS SubMax ON dbo.StatusReport.EndTime = SubMax.MaxEndTime AND dbo.StatusReport.NodeName = SubMax.NodeName
GO
/****** Object:  View [dbo].[vNodeStatusComplex]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vNodeStatusComplex]
AS
SELECT GetNodeStatus.*
FROM dbo.tvfGetNodeStatus() AS GetNodeStatus
GO
/****** Object:  View [dbo].[vNodeStatusCount]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vNodeStatusCount]
AS
SELECT NodeName, COUNT(*) AS NodeStatusCount
FROM dbo.StatusReport
WHERE (NodeName IS NOT NULL)
GROUP BY NodeName
GO
/****** Object:  Table [dbo].[Devices]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Devices](
	[TargetName] [nvarchar](255) NOT NULL,
	[ConfigurationID] [nvarchar](255) NOT NULL,
	[ServerCheckSum] [nvarchar](255) NOT NULL,
	[TargetCheckSum] [nvarchar](255) NOT NULL,
	[NodeCompliant] [bit] NOT NULL,
	[LastComplianceTime] [datetime] NULL,
	[LastHeartbeatTime] [datetime] NULL,
	[Dirty] [bit] NOT NULL,
	[StatusCode] [int] NULL,
 CONSTRAINT [PK_Devices] PRIMARY KEY CLUSTERED 
(
	[TargetName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[ClearStatusReport]    Script Date: 14/01/2018 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [dbo].[ClearStatusReport]
AS   

	Declare @nodename nvarchar(255)

	Declare status_cursor cursor for 
		SELECT Distinct [NodeName] FROM [DSC].[dbo].[StatusReport]

	OPEN status_cursor  

	Fetch Next from status_cursor Into @nodename

	While @@FETCH_STATUS = 0 
	begin 
		print @nodename
		delete from StatusReport where ([NodeName] = @nodename and [JobId] not in (select top(10) [JobId] from StatusReport  where [NodeName]=@nodename order by StartTime Desc))
		FETCH NEXT FROM status_cursor Into @nodename
	End
	Close status_cursor;
	Deallocate status_cursor;

GO
