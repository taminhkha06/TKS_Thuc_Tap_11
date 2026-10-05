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

IF OBJECT_ID(N'dbo.tbl_DM_Loai_San_Pham', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.tbl_DM_Loai_San_Pham
	(
		Auto_ID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbl_DM_Loai_San_Pham PRIMARY KEY,
		Ma_LSP NVARCHAR(50) NOT NULL,
		Ten_LSP NVARCHAR(200) NOT NULL,
		Ghi_Chu NVARCHAR(1000) NOT NULL CONSTRAINT DF_tbl_DM_Loai_San_Pham_Ghi_Chu DEFAULT (N''),
		deleted INT NOT NULL CONSTRAINT DF_tbl_DM_Loai_San_Pham_deleted DEFAULT (0),
		Created DATETIME2(0) NOT NULL CONSTRAINT DF_tbl_DM_Loai_San_Pham_Created DEFAULT (SYSDATETIME()),
		Created_By NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_Loai_San_Pham_Created_By DEFAULT (N''),
		Created_By_Function NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_Loai_San_Pham_Created_By_Function DEFAULT (N''),
		Last_Updated DATETIME2(0) NULL,
		Last_Updated_By NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_Loai_San_Pham_Last_Updated_By DEFAULT (N''),
		Last_Updated_By_Function NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_Loai_San_Pham_Last_Updated_By_Function DEFAULT (N''),
		CONSTRAINT CK_tbl_DM_Loai_San_Pham_Ma_LSP_Not_Empty CHECK (LEN(LTRIM(RTRIM(Ma_LSP))) > 0),
		CONSTRAINT CK_tbl_DM_Loai_San_Pham_Ten_LSP_Not_Empty CHECK (LEN(LTRIM(RTRIM(Ten_LSP))) > 0)
	);

END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.tbl_DM_Loai_San_Pham') AND name = N'UX_tbl_DM_Loai_San_Pham_Ma_LSP')
	CREATE UNIQUE INDEX UX_tbl_DM_Loai_San_Pham_Ma_LSP
		ON dbo.tbl_DM_Loai_San_Pham(Ma_LSP) WHERE deleted = 0;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.tbl_DM_Loai_San_Pham') AND name = N'UX_tbl_DM_Loai_San_Pham_Ten_LSP')
	CREATE UNIQUE INDEX UX_tbl_DM_Loai_San_Pham_Ten_LSP
		ON dbo.tbl_DM_Loai_San_Pham(Ten_LSP) WHERE deleted = 0;
GO

CREATE OR ALTER PROCEDURE dbo.FQ_106_LSP_sp_sel_List
AS
BEGIN
	SET NOCOUNT ON;
	SELECT Auto_ID, Ma_LSP, Ten_LSP, Ghi_Chu, deleted, Created, Created_By,
		Created_By_Function, Last_Updated, Last_Updated_By, Last_Updated_By_Function
	FROM dbo.tbl_DM_Loai_San_Pham
	WHERE deleted = 0
	ORDER BY Ma_LSP;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_106_LSP_sp_sel_Get_By_ID
	@Auto_ID BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT Auto_ID, Ma_LSP, Ten_LSP, Ghi_Chu, deleted, Created, Created_By,
		Created_By_Function, Last_Updated, Last_Updated_By, Last_Updated_By_Function
	FROM dbo.tbl_DM_Loai_San_Pham
	WHERE Auto_ID = @Auto_ID AND deleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_106_LSP_sp_ins_Insert
	@Ma_LSP NVARCHAR(50),
	@Ten_LSP NVARCHAR(200),
	@Ghi_Chu NVARCHAR(1000),
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Ma_LSP = LTRIM(RTRIM(ISNULL(@Ma_LSP, N'')));
	SET @Ten_LSP = LTRIM(RTRIM(ISNULL(@Ten_LSP, N'')));

	IF @Ma_LSP = N'' THROW 50001, N'Mã loại sản phẩm không được rỗng.', 1;
	IF @Ten_LSP = N'' THROW 50002, N'Tên loại sản phẩm không được rỗng.', 1;
	IF EXISTS (SELECT 1 FROM dbo.tbl_DM_Loai_San_Pham WHERE deleted = 0 AND Ma_LSP = @Ma_LSP)
		THROW 50003, N'Mã loại sản phẩm đã tồn tại.', 1;
	IF EXISTS (SELECT 1 FROM dbo.tbl_DM_Loai_San_Pham WHERE deleted = 0 AND Ten_LSP = @Ten_LSP)
		THROW 50004, N'Tên loại sản phẩm đã tồn tại.', 1;

	INSERT INTO dbo.tbl_DM_Loai_San_Pham
		(Ma_LSP, Ten_LSP, Ghi_Chu, Created_By, Created_By_Function, Last_Updated_By, Last_Updated_By_Function)
	VALUES
		(@Ma_LSP, @Ten_LSP, ISNULL(@Ghi_Chu, N''), ISNULL(@Last_Updated_By, N''),
		 ISNULL(@Last_Updated_By_Function, N''), ISNULL(@Last_Updated_By, N''), ISNULL(@Last_Updated_By_Function, N''));

	SELECT CONVERT(BIGINT, SCOPE_IDENTITY());
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_106_LSP_sp_upd_Update
	@Auto_ID BIGINT,
	@Ma_LSP NVARCHAR(50),
	@Ten_LSP NVARCHAR(200),
	@Ghi_Chu NVARCHAR(1000),
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Ma_LSP = LTRIM(RTRIM(ISNULL(@Ma_LSP, N'')));
	SET @Ten_LSP = LTRIM(RTRIM(ISNULL(@Ten_LSP, N'')));

	IF @Ma_LSP = N'' THROW 50001, N'Mã loại sản phẩm không được rỗng.', 1;
	IF @Ten_LSP = N'' THROW 50002, N'Tên loại sản phẩm không được rỗng.', 1;
	IF EXISTS (SELECT 1 FROM dbo.tbl_DM_Loai_San_Pham WHERE deleted = 0 AND Ma_LSP = @Ma_LSP AND Auto_ID <> @Auto_ID)
		THROW 50003, N'Mã loại sản phẩm đã tồn tại.', 1;
	IF EXISTS (SELECT 1 FROM dbo.tbl_DM_Loai_San_Pham WHERE deleted = 0 AND Ten_LSP = @Ten_LSP AND Auto_ID <> @Auto_ID)
		THROW 50004, N'Tên loại sản phẩm đã tồn tại.', 1;

	UPDATE dbo.tbl_DM_Loai_San_Pham
	SET Ma_LSP = @Ma_LSP,
		Ten_LSP = @Ten_LSP,
		Ghi_Chu = ISNULL(@Ghi_Chu, N''),
		Last_Updated = SYSDATETIME(),
		Last_Updated_By = ISNULL(@Last_Updated_By, N''),
		Last_Updated_By_Function = ISNULL(@Last_Updated_By_Function, N'')
	WHERE Auto_ID = @Auto_ID AND deleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_106_LSP_sp_del_Delete_By_ID
	@Auto_ID BIGINT,
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE dbo.tbl_DM_Loai_San_Pham
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
	WHERE Func_URL = N'/Danh_Muc/Don_Vi_Tinh' AND deleted = 0;

	IF @Source_Function_ID IS NULL
		THROW 50005, N'Không tìm thấy chức năng Đơn vị tính để đăng ký Loại sản phẩm.', 1;

	SELECT @Function_ID = Auto_ID
	FROM dbo.tbl_Sys_Chuc_Nang WITH (UPDLOCK, HOLDLOCK)
	WHERE Func_URL = N'/Danh_Muc/Loai_San_Pham' AND deleted = 0;

	IF @Function_ID IS NULL
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.tbl_Sys_Chuc_Nang WHERE Ma_Chuc_Nang = N'2005' AND deleted = 0)
			THROW 50006, N'Mã chức năng 2005 đã được sử dụng.', 1;

		SELECT @Function_ID = ISNULL(MAX(Auto_ID), 0) + 1
		FROM dbo.tbl_Sys_Chuc_Nang WITH (TABLOCKX, HOLDLOCK);

		INSERT INTO dbo.tbl_Sys_Chuc_Nang
			(Auto_ID, Ma_Chuc_Nang, Ten_Chuc_Nang, Sort_Priority, Chuc_Nang_Parent_ID,
			 Nhom_Chuc_Nang_ID, Func_URL, Image_URL, Is_View, Is_New, Is_Edit, Is_Delete,
			 Is_Export, Khach_Hang_ID, Ghi_Chu, deleted, Created, Created_By,
			 Created_By_Function, Last_Updated, Last_Updated_By, Last_Updated_By_Function)
		SELECT @Function_ID, N'2005', N'Loại sản phẩm',
			(SELECT ISNULL(MAX(Sort_Priority), 0) + 1 FROM dbo.tbl_Sys_Chuc_Nang WHERE Chuc_Nang_Parent_ID = @Parent_ID AND deleted = 0),
			Chuc_Nang_Parent_ID, Nhom_Chuc_Nang_ID, N'/Danh_Muc/Loai_San_Pham', Image_URL,
			Is_View, Is_New, Is_Edit, Is_Delete, Is_Export, Khach_Hang_ID,
			N'Danh mục loại sản phẩm', 0, @Now, @Login_Name, N'DB_SETUP', @Now, @Login_Name, N'DB_SETUP'
		FROM dbo.tbl_Sys_Chuc_Nang
		WHERE Auto_ID = @Source_Function_ID;
	END
	ELSE IF EXISTS (SELECT 1 FROM dbo.tbl_Sys_Chuc_Nang WHERE Ma_Chuc_Nang <> N'2005' AND Func_URL = N'/Danh_Muc/Loai_San_Pham' AND deleted = 0)
		THROW 50007, N'Route Loại sản phẩm đã được đăng ký với mã chức năng khác.', 1;
	ELSE
	BEGIN
		UPDATE dbo.tbl_Sys_Chuc_Nang
		SET Ten_Chuc_Nang = N'Loại sản phẩm',
			Ghi_Chu = N'Danh mục loại sản phẩm',
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
		SELECT Nhom_Thanh_Vien_ID, Is_Have_View_Permission, Is_Have_Add_Permission,
			Is_Have_Edit_Permission, Is_Have_Delete_Permission, Is_Have_Export_Permission,
			ROW_NUMBER() OVER (ORDER BY Nhom_Thanh_Vien_ID) AS Row_Number
		FROM dbo.tbl_Sys_Phan_Quyen_Chuc_Nang
		WHERE Chuc_Nang_ID = @Source_Function_ID AND deleted = 0
			AND NOT EXISTS
			(
				SELECT 1 FROM dbo.tbl_Sys_Phan_Quyen_Chuc_Nang Existing
				WHERE Existing.Chuc_Nang_ID = @Function_ID
					AND Existing.Nhom_Thanh_Vien_ID = tbl_Sys_Phan_Quyen_Chuc_Nang.Nhom_Thanh_Vien_ID
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