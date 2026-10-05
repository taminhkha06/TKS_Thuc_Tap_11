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

IF OBJECT_ID(N'dbo.tbl_XNK_Nhap_Kho', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.tbl_XNK_Nhap_Kho
	(
		Auto_ID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbl_XNK_Nhap_Kho PRIMARY KEY,
		So_Phieu_Nhap_Kho NVARCHAR(50) NOT NULL,
		Kho_ID BIGINT NOT NULL,
		NCC_ID BIGINT NOT NULL,
		Ngay_Nhap_Kho DATE NOT NULL,
		Ghi_Chu NVARCHAR(1000) NOT NULL CONSTRAINT DF_tbl_XNK_Nhap_Kho_Ghi_Chu DEFAULT (N''),
		deleted INT NOT NULL CONSTRAINT DF_tbl_XNK_Nhap_Kho_deleted DEFAULT (0),
		Created DATETIME2(0) NOT NULL CONSTRAINT DF_tbl_XNK_Nhap_Kho_Created DEFAULT (SYSDATETIME()),
		Created_By NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_XNK_Nhap_Kho_Created_By DEFAULT (N''),
		Created_By_Function NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_XNK_Nhap_Kho_Created_By_Function DEFAULT (N''),
		Last_Updated DATETIME2(0) NULL,
		Last_Updated_By NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_XNK_Nhap_Kho_Last_Updated_By DEFAULT (N''),
		Last_Updated_By_Function NVARCHAR(100) NOT NULL CONSTRAINT DF_tbl_XNK_Nhap_Kho_Last_Updated_By_Function DEFAULT (N''),
		CONSTRAINT CK_tbl_XNK_Nhap_Kho_So_Phieu_Not_Empty CHECK (LEN(LTRIM(RTRIM(So_Phieu_Nhap_Kho))) > 0),
		CONSTRAINT CK_tbl_XNK_Nhap_Kho_Kho_ID_Not_Empty CHECK (Kho_ID > 0),
		CONSTRAINT CK_tbl_XNK_Nhap_Kho_NCC_ID_Not_Empty CHECK (NCC_ID > 0),
		CONSTRAINT FK_tbl_XNK_Nhap_Kho_Kho FOREIGN KEY (Kho_ID) REFERENCES dbo.tbl_DM_Kho(Auto_ID),
		CONSTRAINT FK_tbl_XNK_Nhap_Kho_NCC FOREIGN KEY (NCC_ID) REFERENCES dbo.tbl_DM_NCC(Auto_ID)
	);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.tbl_XNK_Nhap_Kho') AND name = N'UX_tbl_XNK_Nhap_Kho_So_Phieu')
	CREATE UNIQUE INDEX UX_tbl_XNK_Nhap_Kho_So_Phieu
		ON dbo.tbl_XNK_Nhap_Kho(So_Phieu_Nhap_Kho) WHERE deleted = 0;
GO

BEGIN TRY
	BEGIN TRANSACTION;

	SET IDENTITY_INSERT dbo.tbl_XNK_Nhap_Kho ON;
	INSERT INTO dbo.tbl_XNK_Nhap_Kho
		(Auto_ID, So_Phieu_Nhap_Kho, Kho_ID, NCC_ID, Ngay_Nhap_Kho, Ghi_Chu,
		 deleted, Created, Created_By, Created_By_Function,
		 Last_Updated, Last_Updated_By, Last_Updated_By_Function)
	SELECT D.Auto_ID, D.So_Phieu_Nhap_Kho, D.Kho_ID, D.NCC_ID, D.Ngay_Nhap_Kho, D.Ghi_Chu,
		D.deleted, D.Created, D.Created_By, D.Created_By_Function,
		D.Last_Updated, D.Last_Updated_By, D.Last_Updated_By_Function
	FROM dbo.tbl_DM_Nhap_Kho D
	WHERE NOT EXISTS (SELECT 1 FROM dbo.tbl_XNK_Nhap_Kho X WHERE X.Auto_ID = D.Auto_ID);
	SET IDENTITY_INSERT dbo.tbl_XNK_Nhap_Kho OFF;

	IF EXISTS
	(
		SELECT 1 FROM dbo.tbl_DM_Nhap_Kho_Raw_Data R
		LEFT JOIN dbo.tbl_XNK_Nhap_Kho X ON X.Auto_ID = R.Nhap_Kho_ID
		WHERE X.Auto_ID IS NULL
	)
		THROW 50071, N'Không thể chuyển FK: có dòng hàng không khớp phiếu nhập.', 1;

	IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_tbl_DM_Nhap_Kho_Raw_Data_Header')
		ALTER TABLE dbo.tbl_DM_Nhap_Kho_Raw_Data DROP CONSTRAINT FK_tbl_DM_Nhap_Kho_Raw_Data_Header;
	IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_tbl_DM_Nhap_Kho_Raw_Data_XNK_Header')
		ALTER TABLE dbo.tbl_DM_Nhap_Kho_Raw_Data DROP CONSTRAINT FK_tbl_DM_Nhap_Kho_Raw_Data_XNK_Header;

	ALTER TABLE dbo.tbl_DM_Nhap_Kho_Raw_Data WITH CHECK
		ADD CONSTRAINT FK_tbl_DM_Nhap_Kho_Raw_Data_XNK_Header
		FOREIGN KEY (Nhap_Kho_ID) REFERENCES dbo.tbl_XNK_Nhap_Kho(Auto_ID);

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	THROW;
END CATCH
GO

CREATE OR ALTER PROCEDURE dbo.FQ_111_NK_sp_sel_List
AS
BEGIN
	SET NOCOUNT ON;
	SELECT H.Auto_ID, H.So_Phieu_Nhap_Kho, H.Kho_ID, H.NCC_ID, H.Ngay_Nhap_Kho,
		H.Ghi_Chu, K.Ten_Kho, N.Ten_NCC, COUNT(R.Auto_ID) AS So_Dong_Hang,
		ISNULL(SUM(R.SL_Nhap * R.Don_Gia_Nhap), 0) AS Tong_Tien,
		H.deleted, H.Created, H.Created_By, H.Created_By_Function,
		H.Last_Updated, H.Last_Updated_By, H.Last_Updated_By_Function
	FROM dbo.tbl_XNK_Nhap_Kho H
	JOIN dbo.tbl_DM_Kho K ON K.Auto_ID = H.Kho_ID
	JOIN dbo.tbl_DM_NCC N ON N.Auto_ID = H.NCC_ID
	LEFT JOIN dbo.tbl_DM_Nhap_Kho_Raw_Data R ON R.Nhap_Kho_ID = H.Auto_ID
	WHERE H.deleted = 0
	GROUP BY H.Auto_ID, H.So_Phieu_Nhap_Kho, H.Kho_ID, H.NCC_ID, H.Ngay_Nhap_Kho,
		H.Ghi_Chu, K.Ten_Kho, N.Ten_NCC, H.deleted, H.Created, H.Created_By,
		H.Created_By_Function, H.Last_Updated, H.Last_Updated_By, H.Last_Updated_By_Function
	ORDER BY H.Ngay_Nhap_Kho DESC, H.Auto_ID DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_111_NK_sp_sel_List_Raw_By_Nhap_Kho_ID
	@Nhap_Kho_ID BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT R.Auto_ID, R.Nhap_Kho_ID, R.San_Pham_ID, R.SL_Nhap, R.Don_Gia_Nhap,
		P.Ma_San_Pham, P.Ten_San_Pham, D.Ten_Don_Vi_Tinh
	FROM dbo.tbl_DM_Nhap_Kho_Raw_Data R
	JOIN dbo.tbl_DM_San_Pham P ON P.Auto_ID = R.San_Pham_ID
	JOIN dbo.tbl_DM_Don_Vi_Tinh D ON D.Auto_ID = P.Don_Vi_Tinh_ID
	WHERE R.Nhap_Kho_ID = @Nhap_Kho_ID
	ORDER BY R.Auto_ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_111_NK_sp_ins_Insert
	@So_Phieu_Nhap_Kho NVARCHAR(50),
	@Kho_ID BIGINT,
	@NCC_ID BIGINT,
	@Ngay_Nhap_Kho DATE,
	@Ghi_Chu NVARCHAR(1000),
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	SET @So_Phieu_Nhap_Kho = LTRIM(RTRIM(ISNULL(@So_Phieu_Nhap_Kho, N'')));

	IF @So_Phieu_Nhap_Kho = N'' THROW 50051, N'Số phiếu nhập không được để trống.', 1;
	IF ISNULL(@Kho_ID, 0) <= 0 THROW 50052, N'Kho không được để trống.', 1;
	IF ISNULL(@NCC_ID, 0) <= 0 THROW 50053, N'Nhà cung cấp không được để trống.', 1;
	IF @Ngay_Nhap_Kho IS NULL THROW 50054, N'Ngày nhập kho không được để trống.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_Kho WHERE Auto_ID = @Kho_ID AND deleted = 0)
		THROW 50055, N'Kho không tồn tại hoặc đã ngưng sử dụng.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_NCC WHERE Auto_ID = @NCC_ID AND deleted = 0)
		THROW 50056, N'Nhà cung cấp không tồn tại hoặc đã ngưng sử dụng.', 1;
	IF EXISTS (SELECT 1 FROM dbo.tbl_XNK_Nhap_Kho WHERE So_Phieu_Nhap_Kho = @So_Phieu_Nhap_Kho AND deleted = 0)
		THROW 50057, N'Số phiếu nhập đã tồn tại.', 1;

	INSERT INTO dbo.tbl_XNK_Nhap_Kho
		(So_Phieu_Nhap_Kho, Kho_ID, NCC_ID, Ngay_Nhap_Kho, Ghi_Chu,
		 Created_By, Created_By_Function, Last_Updated_By, Last_Updated_By_Function)
	VALUES
		(@So_Phieu_Nhap_Kho, @Kho_ID, @NCC_ID, @Ngay_Nhap_Kho, ISNULL(@Ghi_Chu, N''),
		 ISNULL(@Last_Updated_By, N''), ISNULL(@Last_Updated_By_Function, N''),
		 ISNULL(@Last_Updated_By, N''), ISNULL(@Last_Updated_By_Function, N''));

	SELECT CONVERT(BIGINT, SCOPE_IDENTITY());
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_111_NK_sp_ins_Insert_Raw_Data
	@Nhap_Kho_ID BIGINT,
	@San_Pham_ID BIGINT,
	@SL_Nhap DECIMAL(18, 3),
	@Don_Gia_Nhap DECIMAL(18, 2)
AS
BEGIN
	SET NOCOUNT ON;
	IF ISNULL(@Nhap_Kho_ID, 0) <= 0 THROW 50058, N'Phiếu nhập không hợp lệ.', 1;
	IF ISNULL(@San_Pham_ID, 0) <= 0 THROW 50059, N'Sản phẩm không được để trống.', 1;
	IF @SL_Nhap <= 0 THROW 50060, N'Số lượng nhập phải lớn hơn 0.', 1;
	IF @Don_Gia_Nhap < 0 THROW 50061, N'Đơn giá nhập không được nhỏ hơn 0.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_XNK_Nhap_Kho WHERE Auto_ID = @Nhap_Kho_ID AND deleted = 0)
		THROW 50066, N'Phiếu nhập không tồn tại hoặc đã bị xóa.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_San_Pham WHERE Auto_ID = @San_Pham_ID AND deleted = 0)
		THROW 50062, N'Sản phẩm không tồn tại hoặc đã ngưng sử dụng.', 1;

	INSERT INTO dbo.tbl_DM_Nhap_Kho_Raw_Data (Nhap_Kho_ID, San_Pham_ID, SL_Nhap, Don_Gia_Nhap)
	VALUES (@Nhap_Kho_ID, @San_Pham_ID, @SL_Nhap, @Don_Gia_Nhap);
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_111_NK_sp_upd_Update_Raw_Data
	@Auto_ID BIGINT,
	@SL_Nhap DECIMAL(18, 3),
	@Don_Gia_Nhap DECIMAL(18, 2)
AS
BEGIN
	SET NOCOUNT ON;
	IF @SL_Nhap <= 0 THROW 50060, N'Số lượng nhập phải lớn hơn 0.', 1;
	IF @Don_Gia_Nhap < 0 THROW 50061, N'Đơn giá nhập không được nhỏ hơn 0.', 1;
	IF NOT EXISTS
	(
		SELECT 1
		FROM dbo.tbl_DM_Nhap_Kho_Raw_Data R
		JOIN dbo.tbl_XNK_Nhap_Kho H ON H.Auto_ID = R.Nhap_Kho_ID
		WHERE R.Auto_ID = @Auto_ID AND H.deleted = 0
	)
		THROW 50067, N'Không tìm thấy dòng hàng thuộc phiếu nhập đang hoạt động.', 1;

	UPDATE dbo.tbl_DM_Nhap_Kho_Raw_Data
	SET SL_Nhap = @SL_Nhap, Don_Gia_Nhap = @Don_Gia_Nhap
	WHERE Auto_ID = @Auto_ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_111_NK_sp_del_Delete_Raw_Data
	@Auto_ID BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS
	(
		SELECT 1
		FROM dbo.tbl_DM_Nhap_Kho_Raw_Data R
		JOIN dbo.tbl_XNK_Nhap_Kho H ON H.Auto_ID = R.Nhap_Kho_ID
		WHERE R.Auto_ID = @Auto_ID AND H.deleted = 0
	)
		THROW 50067, N'Không tìm thấy dòng hàng thuộc phiếu nhập đang hoạt động.', 1;

	DELETE FROM dbo.tbl_DM_Nhap_Kho_Raw_Data WHERE Auto_ID = @Auto_ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_111_NK_sp_upd_Update_Header
	@Auto_ID BIGINT,
	@So_Phieu_Nhap_Kho NVARCHAR(50),
	@Kho_ID BIGINT,
	@NCC_ID BIGINT,
	@Ngay_Nhap_Kho DATE,
	@Ghi_Chu NVARCHAR(1000),
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	SET @So_Phieu_Nhap_Kho = LTRIM(RTRIM(ISNULL(@So_Phieu_Nhap_Kho, N'')));

	IF @So_Phieu_Nhap_Kho = N'' THROW 50051, N'Số phiếu nhập không được để trống.', 1;
	IF ISNULL(@Kho_ID, 0) <= 0 THROW 50052, N'Kho không được để trống.', 1;
	IF ISNULL(@NCC_ID, 0) <= 0 THROW 50053, N'Nhà cung cấp không được để trống.', 1;
	IF @Ngay_Nhap_Kho IS NULL THROW 50054, N'Ngày nhập kho không được để trống.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_Kho WHERE Auto_ID = @Kho_ID AND deleted = 0)
		THROW 50055, N'Kho không tồn tại hoặc đã ngưng sử dụng.', 1;
	IF NOT EXISTS (SELECT 1 FROM dbo.tbl_DM_NCC WHERE Auto_ID = @NCC_ID AND deleted = 0)
		THROW 50056, N'Nhà cung cấp không tồn tại hoặc đã ngưng sử dụng.', 1;
	IF EXISTS (SELECT 1 FROM dbo.tbl_XNK_Nhap_Kho WHERE So_Phieu_Nhap_Kho = @So_Phieu_Nhap_Kho AND deleted = 0 AND Auto_ID <> @Auto_ID)
		THROW 50057, N'Số phiếu nhập đã tồn tại.', 1;

	UPDATE dbo.tbl_XNK_Nhap_Kho
	SET So_Phieu_Nhap_Kho = @So_Phieu_Nhap_Kho,
		Kho_ID = @Kho_ID,
		NCC_ID = @NCC_ID,
		Ngay_Nhap_Kho = @Ngay_Nhap_Kho,
		Ghi_Chu = ISNULL(@Ghi_Chu, N''),
		Last_Updated = SYSDATETIME(),
		Last_Updated_By = ISNULL(@Last_Updated_By, N''),
		Last_Updated_By_Function = ISNULL(@Last_Updated_By_Function, N'')
	WHERE Auto_ID = @Auto_ID AND deleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.FQ_111_NK_sp_del_Delete_By_ID
	@Auto_ID BIGINT,
	@Last_Updated_By NVARCHAR(100),
	@Last_Updated_By_Function NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE dbo.tbl_XNK_Nhap_Kho
	SET deleted = 1,
		Last_Updated = SYSDATETIME(),
		Last_Updated_By = ISNULL(@Last_Updated_By, N''),
		Last_Updated_By_Function = ISNULL(@Last_Updated_By_Function, N'')
	WHERE Auto_ID = @Auto_ID AND deleted = 0;
END
GO