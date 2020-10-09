-- CREATE custom SCHEMA

USE [WSS_UsageApplication]
GO

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'custom')
DROP SCHEMA [custom]
GO

USE [WSS_UsageApplication]
GO

CREATE SCHEMA [custom] AUTHORIZATION [dbo]
GO

-- CREATE SiteSize table

USE [WSS_UsageApplication]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[SiteSize]') AND type in (N'U'))
DROP TABLE [custom].[SiteSize]
GO

USE [WSS_UsageApplication]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [custom].[SiteSize](
	[SiteId] [uniqueidentifier] NOT NULL,
	[ContentDatabase] [varchar](250) NOT NULL,
	[Url] [varchar](250) NOT NULL,
	[SiteSizeMB] [bigint] NOT NULL,
	[DateTime] [datetime] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [custom].[SiteSize] SET (LOCK_ESCALATION = DISABLE)
GO

USE [WSS_UsageApplication]
GO

CREATE NONCLUSTERED INDEX [Datetime] ON [custom].[SiteSize] 
(
	[DateTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO

USE [WSS_UsageApplication]
GO

CREATE NONCLUSTERED INDEX [SiteUrl] ON [custom].[SiteSize] 
(
	[Url] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO

-- CREATE ContentDatabaseSize Table

USE [WSS_UsageApplication]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[ContentDatabaseSize]') AND type in (N'U'))
DROP TABLE [custom].[ContentDatabaseSize]
GO

USE [WSS_UsageApplication]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [custom].[ContentDatabaseSize](
	[DatabaseId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](250) NOT NULL,
	[SiteCount] [int] NOT NULL,
	[DiskSizeRequiredMB] [bigint] NOT NULL,
	[DateTime] [datetime] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [WSS_UsageApplication]
GO

CREATE NONCLUSTERED INDEX [Datetime] ON [custom].[ContentDatabaseSize] 
(
	[DateTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO

USE [WSS_UsageApplication]
GO

CREATE NONCLUSTERED INDEX [DatabaseName] ON [custom].[ContentDatabaseSize] 
(
	[Name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO

-- CREATE VIEWS

/*
USE [WSS_UsageApplication]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[custom].[ContentDBSize]'))
DROP VIEW [custom].[ContentDBSize]
GO

USE [WSS_UsageApplication]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [custom].[ContentDBSize]
AS
SELECT    TOP 100 PERCENT DatabaseId, Name, SiteCount, DiskSizeRequired, DateTime
FROM         custom.ContentDatabaseSize
ORDER BY DateTime

GO
*/