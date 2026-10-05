USE [TKS_Thuc_Tap_V11]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

IF OBJECT_ID(N'dbo.tbl_DM_San_Pham', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.tbl_DM_San_Pham
	(
		Auto_ID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbl_DM_San_Pham PRIMARY KEY,
		Ma_San_Pham NVARCHAR(50) NOT NULL,
		Ten_San_Pham NVARCHAR(200) NOT NULL,
		Loai_San_Pham_ID BIGINT NOT NULL,
		Don_Vi_Tinh_ID BIGINT NOT NULL,
		Ghi_Chu NVARCHAR(1000) NOT NULL CONSTRAINT DF_tbl_DM_San_Pham_Ghi_Chu DEFAULT (N''),
		deleted INT NOT NULL CONSTRAINT DF_tbl_DM_San_Pham_deleted DEFAULT (0),
		Created DATETIME2(0) NOT NULL CONSTRAINT DF_tbl_DM_San_Pham_Created DEFAULT (SYSDATETIME()),
		Created_By NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_San_Pham_Created_By DEFAULT (N''),
		Created_By_Function NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_San_Pham_Created_By_Function DEFAULT (N''),
		Last_Updated DATETIME2(0) NULL,
		Last_Updated_By NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_San_Pham_Last_Updated_By DEFAULT (N''),
		Last_Updated_By_Function NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_San_Pham_Last_Updated_By_Function DEFAULT (N''),
		CONSTRAINT CK_tbl_DM_San_Pham_Ma_Not_Empty CHECK (LEN(LTRIM(RTRIM(Ma_San_Pham))) > 0),
		CONSTRAINT CK_tbl_DM_San_Pham_Ten_Not_Empty CHECK (LEN(LTRIM(RTRIM(Ten_San_Pham))) > 0),
		CONSTRAINT FK_tbl_DM_San_Pham_Loai_San_Pham FOREIGN KEY (Loai_San_Pham_ID) REFERENCES dbo.tbl_DM_Loai_San_Pham(Auto_ID),
		CONSTRAINT FK_tbl_DM_San_Pham_Don_Vi_Tinh FOREIGN KEY (Don_Vi_Tinh_ID) REFERENCES dbo.tbl_DM_Don_Vi_Tinh(Auto_ID)
	);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.tbl_DM_San_Pham') AND name = N'UX_tbl_DM_San_Pham_Ma_San_Pham')
	CREATE UNIQUE INDEX UX_tbl_DM_San_Pham_Ma_San_Pham ON dbo.tbl_DM_San_Pham(Ma_San_Pham) WHERE deleted = 0;
GO

CREATE OR ALTER PROCEDURE dbo.FQ_107_SP_sp_sel_List
AS
BEGIN
	SET NOCOUNT ON;
	SELECT p.Auto_ID, p.Ma_San_Pham, p.Ten_San_Pham, p.Loai_San_Pham_ID,
		p.Don_Vi_Tinh_ID, p.Ghi_Chu, l.Ten_LSP, d.Ten_Don_Vi_Tinh,
		p.deleted, p.Created, p.Created_By, p.Created_By_Function,
		p.Last_Updated, p.Last_Updated_By, p.Last_Updated_By_Function
	FROM dbo.tbl_DM_San_Pham p
	LEFT JOIN dbo.tbl_DM_Loai_San_Pham l ON l.Auto_ID = p.Loai_San_Pham_ID
	LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh d ON d.Auto_ID = p.Don_Vi_Tinh_ID
	WHERE p.deleted = 0
	ORDER BY p.Ma_San_Pham;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_107_SP_sp_sel_Get_By_ID
	@Auto_ID BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT p.Auto_ID, p.Ma_San_Pham, p.Ten_San_Pham, p.Loai_San_Pham_ID,
		p.Don_Vi_Tinh_ID, p.Ghi_Chu, l.Ten_LSP, d.Ten_Don_Vi_Tinh,
		p.deleted, p.Created, p.Created_By, p.Created_By_Function,
		p.Last_Updated, p.Last_Updated_By, p.Last_Updated_By_Function
	FROM dbo.tbl_DM_San_Pham p
	LEFT JOIN dbo.tbl_DM_Loai_San_Pham l ON l.Auto_ID = p.Loai_San_Pham_ID
	LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh d ON d.Auto_ID = p.Don_Vi_Tinh_ID
	WHERE p.Auto_ID = @Auto_ID AND p.deleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_107_SP_sp_ins_Insert
	@Ma_San_Pham NVARCHAR(50),
	@Ten_San_Pham NVARCHAR(200),
	@Loai_San_Pham_ID BIGINT,
	@Don_Vi_Tinh_ID BIGINT,
	@Ghi_Chu NVARCHAR(1000),
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Ma_San_Pham = LTRIM(RTRIM(ISNULL(@Ma_San_Pham, N'')));
	SET @Ten_San_Pham = LTRIM(RTRIM(ISNULL(@Ten_San_Pham, N'')));

	IF @Ma_San_Pham = N'' THROW 50011, N'Mã sản phẩm không được để trống.', 1;
	IF @Ten_San_Pham = N'' THROW 50012, N'Tên sản phẩm không được để trống.', 1;
	IF ISNULL(@Loai_San_Pham_ID, 0) <= 0 THROW 50013, N'Loại sản phẩm không được để trống.', 1;
	IF ISNULL(@Don_Vi_Tinh_ID, 0) <= 0 THROW 50014, N'Đơn vị tính không được để trống.', 1;
	IF EXISTS (SELECT 1 FROM dbo.tbl_DM_San_Pham WHERE deleted = 0 AND Ma_San_Pham = @Ma_San_Pham)
		THROW 50015, N'Mã sản phẩm đã tồn tại.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_Loai_San_Pham WHERE Auto_ID = @Loai_San_Pham_ID AND deleted = 0)
		THROW 50016, N'Loại sản phẩm không tồn tại hoặc đã ngưng sử dụng.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_Don_Vi_Tinh WHERE Auto_ID = @Don_Vi_Tinh_ID AND ISNULL(deleted, 0) = 0)
		THROW 50017, N'Đơn vị tính không tồn tại hoặc đã ngưng sử dụng.', 1;

	INSERT INTO dbo.tbl_DM_San_Pham
		(Ma_San_Pham, Ten_San_Pham, Loai_San_Pham_ID, Don_Vi_Tinh_ID, Ghi_Chu,
		 Created_By, Created_By_Function, Last_Updated_By, Last_Updated_By_Function)
	VALUES
		(@Ma_San_Pham, @Ten_San_Pham, @Loai_San_Pham_ID, @Don_Vi_Tinh_ID, ISNULL(@Ghi_Chu, N''),
		 ISNULL(@Last_Updated_By, N''), ISNULL(@Last_Updated_By_Function, N''),
		 ISNULL(@Last_Updated_By, N''), ISNULL(@Last_Updated_By_Function, N''));

	SELECT CONVERT(BIGINT, SCOPE_IDENTITY());
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_107_SP_sp_upd_Update
	@Auto_ID BIGINT,
	@Ma_San_Pham NVARCHAR(50),
	@Ten_San_Pham NVARCHAR(200),
	@Loai_San_Pham_ID BIGINT,
	@Don_Vi_Tinh_ID BIGINT,
	@Ghi_Chu NVARCHAR(1000),
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Ma_San_Pham = LTRIM(RTRIM(ISNULL(@Ma_San_Pham, N'')));
	SET @Ten_San_Pham = LTRIM(RTRIM(ISNULL(@Ten_San_Pham, N'')));

	IF @Ma_San_Pham = N'' THROW 50011, N'Mã sản phẩm không được để trống.', 1;
	IF @Ten_San_Pham = N'' THROW 50012, N'Tên sản phẩm không được để trống.', 1;
	IF ISNULL(@Loai_San_Pham_ID, 0) <= 0 THROW 50013, N'Loại sản phẩm không được để trống.', 1;
	IF ISNULL(@Don_Vi_Tinh_ID, 0) <= 0 THROW 50014, N'Đơn vị tính không được để trống.', 1;
	IF EXISTS (SELECT 1 FROM dbo.tbl_DM_San_Pham WHERE deleted = 0 AND Ma_San_Pham = @Ma_San_Pham AND Auto_ID <> @Auto_ID)
		THROW 50015, N'Mã sản phẩm đã tồn tại.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_Loai_San_Pham WHERE Auto_ID = @Loai_San_Pham_ID AND deleted = 0)
		THROW 50016, N'Loại sản phẩm không tồn tại hoặc đã ngưng sử dụng.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_Don_Vi_Tinh WHERE Auto_ID = @Don_Vi_Tinh_ID AND ISNULL(deleted, 0) = 0)
		THROW 50017, N'Đơn vị tính không tồn tại hoặc đã ngưng sử dụng.', 1;

	UPDATE dbo.tbl_DM_San_Pham
	SET Ma_San_Pham = @Ma_San_Pham,
		Ten_San_Pham = @Ten_San_Pham,
		Loai_San_Pham_ID = @Loai_San_Pham_ID,
		Don_Vi_Tinh_ID = @Don_Vi_Tinh_ID,
		Ghi_Chu = ISNULL(@Ghi_Chu, N''),
		Last_Updated = SYSDATETIME(),
		Last_Updated_By = ISNULL(@Last_Updated_By, N''),
		Last_Updated_By_Function = ISNULL(@Last_Updated_By_Function, N'')
	WHERE Auto_ID = @Auto_ID AND deleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_107_SP_sp_del_Delete_By_ID
	@Auto_ID BIGINT,
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE dbo.tbl_DM_San_Pham
	SET deleted = 1,
		Last_Updated = SYSDATETIME(),
		Last_Updated_By = ISNULL(@Last_Updated_By, N''),
		Last_Updated_By_Function = ISNULL(@Last_Updated_By_Function, N'')
	WHERE Auto_ID = @Auto_ID AND deleted = 0;
END
GO

BEGIN TRY
	BEGIN TRANSACTION;
	DECLARE @Function_ID BIGINT;
	DECLARE @Source_Function_ID BIGINT;
	DECLARE @Parent_ID BIGINT;
	DECLARE @Now DATETIME = GETDATE();
	DECLARE @Login_Name NVARCHAR(100) = CONVERT(NVARCHAR(100), SUSER_SNAME());

	SELECT @Source_Function_ID = Auto_ID, @Parent_ID = Chuc_Nang_Parent_ID
	FROM dbo.tbl_Sys_Chuc_Nang WITH (UPDLOCK, HOLDLOCK)
	WHERE Func_URL = N'/Danh_Muc/Loai_San_Pham' AND deleted = 0;
	IF @Source_Function_ID IS NULL
		THROW 50018, N'Không tìm thấy chức năng Loại sản phẩm để đăng ký Sản phẩm.', 1;

	SELECT @Function_ID = Auto_ID
	FROM dbo.tbl_Sys_Chuc_Nang WITH (UPDLOCK, HOLDLOCK)
	WHERE Func_URL = N'/Danh_Muc/San_Pham' AND deleted = 0;

	IF @Function_ID IS NULL
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.tbl_Sys_Chuc_Nang WHERE Ma_Chuc_Nang = N'2006' AND deleted = 0)
			THROW 50019, N'Mã chức năng 2006 đã được sử dụng.', 1;

		SELECT @Function_ID = ISNULL(MAX(Auto_ID), 0) + 1
		FROM dbo.tbl_Sys_Chuc_Nang WITH (TABLOCKX, HOLDLOCK);

		INSERT INTO dbo.tbl_Sys_Chuc_Nang
			(Auto_ID, Ma_Chuc_Nang, Ten_Chuc_Nang, Sort_Priority, Chuc_Nang_Parent_ID,
			 Nhom_Chuc_Nang_ID, Func_URL, Image_URL, Is_View, Is_New, Is_Edit, Is_Delete,
			 Is_Export, Khach_Hang_ID, Ghi_Chu, deleted, Created, Created_By,
			 Created_By_Function, Last_Updated, Last_Updated_By, Last_Updated_By_Function)
		SELECT @Function_ID, N'2006', N'Sản phẩm',
			(SELECT ISNULL(MAX(Sort_Priority), 0) + 1 FROM dbo.tbl_Sys_Chuc_Nang WHERE Chuc_Nang_Parent_ID = @Parent_ID AND deleted = 0),
			Chuc_Nang_Parent_ID, Nhom_Chuc_Nang_ID, N'/Danh_Muc/San_Pham', Image_URL,
			Is_View, Is_New, Is_Edit, Is_Delete, Is_Export, Khach_Hang_ID,
			N'Danh mục sản phẩm', 0, @Now, @Login_Name, N'DB_SETUP', @Now, @Login_Name, N'DB_SETUP'
		FROM dbo.tbl_Sys_Chuc_Nang
		WHERE Auto_ID = @Source_Function_ID;
	END
	ELSE IF EXISTS (SELECT 1 FROM dbo.tbl_Sys_Chuc_Nang WHERE Ma_Chuc_Nang <> N'2006' AND Func_URL = N'/Danh_Muc/San_Pham' AND deleted = 0)
		THROW 50020, N'Route Sản phẩm đã được đăng ký với mã chức năng khác.', 1;
	ELSE
	BEGIN
		UPDATE dbo.tbl_Sys_Chuc_Nang
		SET Ten_Chuc_Nang = N'Sản phẩm',
			Ghi_Chu = N'Danh mục sản phẩm',
			Last_Updated = @Now,
			Last_Updated_By = @Login_Name,
			Last_Updated_By_Function = N'DB_SETUP'
		WHERE Auto_ID = @Function_ID;
	END

	DECLARE @Permission_Base_ID BIGINT;
	SELECT @Permission_Base_ID = ISNULL(MAX(Auto_ID), 0)
	FROM dbo.tbl_Sys_Phan_Quyen_Chuc_Nang WITH (TABLOCKX, HOLDLOCK);

	;WITH Permission_Source AS
	(
		SELECT SourcePermission.Nhom_Thanh_Vien_ID, SourcePermission.Is_Have_View_Permission,
			SourcePermission.Is_Have_Add_Permission, SourcePermission.Is_Have_Edit_Permission,
			SourcePermission.Is_Have_Delete_Permission, SourcePermission.Is_Have_Export_Permission,
			ROW_NUMBER() OVER (ORDER BY SourcePermission.Nhom_Thanh_Vien_ID) AS Row_Number
		FROM dbo.tbl_Sys_Phan_Quyen_Chuc_Nang SourcePermission
		WHERE SourcePermission.Chuc_Nang_ID = @Source_Function_ID AND SourcePermission.deleted = 0
			AND NOT EXISTS
			(
				SELECT 1 FROM dbo.tbl_Sys_Phan_Quyen_Chuc_Nang Existing
				WHERE Existing.Chuc_Nang_ID = @Function_ID
					AND Existing.Nhom_Thanh_Vien_ID = SourcePermission.Nhom_Thanh_Vien_ID
					AND Existing.deleted = 0
			)
	)
	INSERT INTO dbo.tbl_Sys_Phan_Quyen_Chuc_Nang
		(Auto_ID, Nhom_Thanh_Vien_ID, Chuc_Nang_ID, Is_Have_View_Permission,
		 Is_Have_Add_Permission, Is_Have_Edit_Permission, Is_Have_Delete_Permission,
		 Is_Have_Export_Permission, deleted, Created, Created_By, Created_By_Function,
		 Last_Updated, Last_Updated_By, Last_Updated_By_Function)
	SELECT @Permission_Base_ID + Row_Number, Nhom_Thanh_Vien_ID, @Function_ID,
		Is_Have_View_Permission, Is_Have_Add_Permission, Is_Have_Edit_Permission,
		Is_Have_Delete_Permission, Is_Have_Export_Permission, 0, @Now, @Login_Name,
		N'DB_SETUP', @Now, @Login_Name, N'DB_SETUP'
	FROM Permission_Source;

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	THROW;
END CATCH
GO