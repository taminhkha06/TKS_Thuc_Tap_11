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

IF OBJECT_ID(N'dbo.tbl_DM_Kho_User', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.tbl_DM_Kho_User
	(
		Auto_ID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbl_DM_Kho_User PRIMARY KEY,
		Ma_Dang_Nhap NVARCHAR(50) NOT NULL,
		Kho_ID BIGINT NOT NULL,
		deleted INT NOT NULL CONSTRAINT DF_tbl_DM_Kho_User_deleted DEFAULT (0),
		Created DATETIME2(0) NOT NULL CONSTRAINT DF_tbl_DM_Kho_User_Created DEFAULT (SYSDATETIME()),
		Created_By NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_Kho_User_Created_By DEFAULT (N''),
		Created_By_Function NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_Kho_User_Created_By_Function DEFAULT (N''),
		Last_Updated DATETIME2(0) NULL,
		Last_Updated_By NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_Kho_User_Last_Updated_By DEFAULT (N''),
		Last_Updated_By_Function NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_DM_Kho_User_Last_Updated_By_Function DEFAULT (N''),
		CONSTRAINT CK_tbl_DM_Kho_User_Ma_Dang_Nhap_Not_Empty CHECK (LEN(LTRIM(RTRIM(Ma_Dang_Nhap))) > 0),
		CONSTRAINT CK_tbl_DM_Kho_User_Kho_ID_Not_Empty CHECK (Kho_ID > 0),
		CONSTRAINT FK_tbl_DM_Kho_User_Kho FOREIGN KEY (Kho_ID) REFERENCES dbo.tbl_DM_Kho(Auto_ID)
	);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.tbl_DM_Kho_User') AND name = N'UX_tbl_DM_Kho_User_Login_Kho')
	CREATE UNIQUE INDEX UX_tbl_DM_Kho_User_Login_Kho
		ON dbo.tbl_DM_Kho_User(Ma_Dang_Nhap, Kho_ID) WHERE deleted = 0;
GO

CREATE OR ALTER PROCEDURE dbo.FQ_110_KU_sp_sel_List_By_Kho_ID
	@Kho_ID BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT KU.Auto_ID, KU.Ma_Dang_Nhap, KU.Kho_ID, K.Ten_Kho, U.Ho_Ten,
		KU.deleted, KU.Created, KU.Created_By, KU.Created_By_Function,
		KU.Last_Updated, KU.Last_Updated_By, KU.Last_Updated_By_Function
	FROM dbo.tbl_DM_Kho_User KU
	JOIN dbo.tbl_DM_Kho K ON K.Auto_ID = KU.Kho_ID AND K.deleted = 0
	LEFT JOIN dbo.view_Sys_Thanh_Vien U ON U.Ma_Dang_Nhap = KU.Ma_Dang_Nhap AND ISNULL(U.deleted, 0) = 0
	WHERE KU.Kho_ID = @Kho_ID AND KU.deleted = 0
	ORDER BY KU.Ma_Dang_Nhap;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_110_KU_sp_sel_List_User_Not_Assigned
	@Kho_ID BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT U.Auto_ID, U.Ma_Dang_Nhap, U.Ho_Ten
	FROM dbo.view_Sys_Thanh_Vien U
	WHERE ISNULL(U.deleted, 0) = 0
		AND NULLIF(LTRIM(RTRIM(U.Ma_Dang_Nhap)), N'') IS NOT NULL
		AND NOT EXISTS
		(
			SELECT 1 FROM dbo.tbl_DM_Kho_User KU
			WHERE KU.Kho_ID = @Kho_ID AND KU.Ma_Dang_Nhap = U.Ma_Dang_Nhap AND KU.deleted = 0
		)
	ORDER BY U.Ma_Dang_Nhap;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_110_KU_sp_ins_Insert
	@Ma_Dang_Nhap NVARCHAR(50),
	@Kho_ID BIGINT,
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Ma_Dang_Nhap = LTRIM(RTRIM(ISNULL(@Ma_Dang_Nhap, N'')));

	IF @Ma_Dang_Nhap = N'' THROW 50041, N'Mã đăng nhập không được để trống.', 1;
	IF ISNULL(@Kho_ID, 0) <= 0 THROW 50042, N'Kho không được để trống.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_Kho WHERE Auto_ID = @Kho_ID AND deleted = 0)
		THROW 50043, N'Kho không tồn tại hoặc đã ngưng sử dụng.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.view_Sys_Thanh_Vien WHERE Ma_Dang_Nhap = @Ma_Dang_Nhap AND ISNULL(deleted, 0) = 0)
		THROW 50044, N'Mã đăng nhập không tồn tại hoặc đã ngưng sử dụng.', 1;
	IF EXISTS (SELECT 1 FROM dbo.tbl_DM_Kho_User WHERE Ma_Dang_Nhap = @Ma_Dang_Nhap AND Kho_ID = @Kho_ID AND deleted = 0)
		THROW 50045, N'User đã được phân quyền vào kho này.', 1;

	INSERT INTO dbo.tbl_DM_Kho_User
		(Ma_Dang_Nhap, Kho_ID, Created_By, Created_By_Function, Last_Updated_By, Last_Updated_By_Function)
	VALUES
		(@Ma_Dang_Nhap, @Kho_ID, ISNULL(@Last_Updated_By, N''), ISNULL(@Last_Updated_By_Function, N''),
		 ISNULL(@Last_Updated_By, N''), ISNULL(@Last_Updated_By_Function, N''));

	SELECT CONVERT(BIGINT, SCOPE_IDENTITY());
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_110_KU_sp_del_Delete_By_ID
	@Auto_ID BIGINT,
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE dbo.tbl_DM_Kho_User
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
	WHERE Func_URL = N'/Danh_Muc/Kho' AND deleted = 0;
	IF @Source_Function_ID IS NULL
		THROW 50046, N'Không tìm thấy chức năng Kho để đăng ký phân quyền User.', 1;

	SELECT @Function_ID = Auto_ID
	FROM dbo.tbl_Sys_Chuc_Nang WITH (UPDLOCK, HOLDLOCK)
	WHERE Func_URL = N'/Danh_Muc/Kho_User' AND deleted = 0;

	IF @Function_ID IS NULL
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.tbl_Sys_Chuc_Nang WHERE Ma_Chuc_Nang = N'2009' AND deleted = 0)
			THROW 50047, N'Mã chức năng 2009 đã được sử dụng.', 1;

		SELECT @Function_ID = ISNULL(MAX(Auto_ID), 0) + 1
		FROM dbo.tbl_Sys_Chuc_Nang WITH (TABLOCKX, HOLDLOCK);

		INSERT INTO dbo.tbl_Sys_Chuc_Nang
			(Auto_ID, Ma_Chuc_Nang, Ten_Chuc_Nang, Sort_Priority, Chuc_Nang_Parent_ID,
			 Nhom_Chuc_Nang_ID, Func_URL, Image_URL, Is_View, Is_New, Is_Edit, Is_Delete,
			 Is_Export, Khach_Hang_ID, Ghi_Chu, deleted, Created, Created_By,
			 Created_By_Function, Last_Updated, Last_Updated_By, Last_Updated_By_Function)
		SELECT @Function_ID, N'2009', N'Phân quyền kho - User',
			(SELECT ISNULL(MAX(Sort_Priority), 0) + 1 FROM dbo.tbl_Sys_Chuc_Nang WHERE Chuc_Nang_Parent_ID = @Parent_ID AND deleted = 0),
			Chuc_Nang_Parent_ID, Nhom_Chuc_Nang_ID, N'/Danh_Muc/Kho_User', Image_URL,
			Is_View, Is_New, Is_Edit, Is_Delete, Is_Export, Khach_Hang_ID,
			N'Phân quyền kho cho user', 0, @Now, @Login_Name, N'DB_SETUP', @Now, @Login_Name, N'DB_SETUP'
		FROM dbo.tbl_Sys_Chuc_Nang
		WHERE Auto_ID = @Source_Function_ID;
	END
	ELSE IF EXISTS (SELECT 1 FROM dbo.tbl_Sys_Chuc_Nang WHERE Ma_Chuc_Nang <> N'2009' AND Func_URL = N'/Danh_Muc/Kho_User' AND deleted = 0)
		THROW 50048, N'Route phân quyền kho đã được đăng ký với mã chức năng khác.', 1;
	ELSE
	BEGIN
		UPDATE dbo.tbl_Sys_Chuc_Nang
		SET Ten_Chuc_Nang = N'Phân quyền kho - User',
			Ghi_Chu = N'Phân quyền kho cho user',
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