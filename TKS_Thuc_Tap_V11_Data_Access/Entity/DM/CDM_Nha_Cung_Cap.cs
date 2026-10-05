using System;
using TKS_Thuc_Tap_V11_Data_Access.Utility;

namespace TKS_Thuc_Tap_V11_Data_Access.Entity.DM
{
	public class CDM_Nha_Cung_Cap
	{
		public long Auto_ID { get; set; }
		public string Ma_NCC { get; set; } = CConst.STR_VALUE_NULL;
		public string Ten_NCC { get; set; } = CConst.STR_VALUE_NULL;
		public string Ghi_Chu { get; set; } = CConst.STR_VALUE_NULL;
		public int deleted { get; set; }
		public DateTime? Created { get; set; }
		public string Created_By { get; set; } = CConst.STR_VALUE_NULL;
		public string Created_By_Function { get; set; } = CConst.STR_VALUE_NULL;
		public DateTime? Last_Updated { get; set; }
		public string Last_Updated_By { get; set; } = CConst.STR_VALUE_NULL;
		public string Last_Updated_By_Function { get; set; } = CConst.STR_VALUE_NULL;
	}
}