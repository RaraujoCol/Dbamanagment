USE [Y2_C4_PROD]
GO

/****** Object:  Table [dbo].[ztbl_controlMantenimiento]    Script Date: 1/21/2022 10:58:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ztbl_controlMantenimiento](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[FechaInicio] [datetime] NULL,
	[FechaFin] [datetime] NULL,
	[Tabla] [nvarchar](50) NULL,
	[Indice] [nvarchar](100) NULL,
	[Fragmentacion] [decimal](18, 0) NULL,
	[page] [int] NULL,
	[Duracion] [int] NULL,
	[Tipo] [nvarchar](50) NULL,
	[rows] [bigint] NULL,
 CONSTRAINT [PK_ztbl_controlMantenimiento] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO

