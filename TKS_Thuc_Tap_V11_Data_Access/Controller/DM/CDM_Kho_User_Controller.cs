using System;
using System.Collections.Generic;
using System.Data;
using TKS_Thuc_Tap_V11_Data_Access.DataLayer;
using TKS_Thuc_Tap_V11_Data_Access.Entity.DM;
using TKS_Thuc_Tap_V11_Data_Access.Entity.Sys;
using TKS_Thuc_Tap_V11_Data_Access.Utility;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.DM
{
	public class CDM_Kho_User_Controller
	{
		public List<CDM_Kho_User> FQ_110_KU_sp_sel_List_By_Kho_ID(long p_iKho_ID)
		{
			List<CDM_Kho_User> v_arrRes = new();
			DataTable v_dt = new();
			try
			{
				CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_110_KU_sp_sel_List_By_Kho_ID", p_iKho_ID);
				foreach (DataRow v_row in v_dt.Rows)
					v_arrRes.Add(CUtility.Map_Row_To_Entity<CDM_Kho_User>(v_row));
			}
			finally
			{
				v_dt.Dispose();
			}
			return v_arrRes;
		}

		public List<CSys_Thanh_Vien> FQ_110_KU_sp_sel_List_User_Not_Assigned(long p_iKho_ID)
		{
			List<CSys_Thanh_Vien> v_arrRes = new();
			DataTable v_dt = new();
			try
			{
				CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_110_KU_sp_sel_List_User_Not_Assigned", p_iKho_ID);
				foreach (DataRow v_row in v_dt.Rows)
					v_arrRes.Add(CUtility.Map_Row_To_Entity<CSys_Thanh_Vien>(v_row));
			}
			finally
			{
				v_dt.Dispose();
			}
			return v_arrRes;
		}

		public long FQ_110_KU_sp_ins_Insert(CDM_Kho_User p_objData)
		{
			return Convert.ToInt64(CSqlHelper.ExecuteScalar(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_110_KU_sp_ins_Insert",
				p_objData.Ma_Dang_Nhap, p_objData.Kho_ID,
				p_objData.Last_Updated_By, p_objData.Last_Updated_By_Function));
		}

		public void FQ_110_KU_sp_del_Delete_By_ID(long p_iAuto_ID, string p_strLast_Updated_By, string p_strLast_Updated_By_Function)
		{
			CSqlHelper.ExecuteNonquery(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_110_KU_sp_del_Delete_By_ID",
				p_iAuto_ID, p_strLast_Updated_By, p_strLast_Updated_By_Function);
		}
	}
}