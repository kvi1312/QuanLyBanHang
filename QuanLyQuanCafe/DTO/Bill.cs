using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace QuanLyQuanCafe.DTO
{
    public class Bill
    {   
        public Bill(int id, DateTime? dateCheckin, DateTime? dateCheckOut, int status, int discount=0)
        {
            this.ID = id;
            this.DateCheckIn = dateCheckin;
            this.DateCheckOut = dateCheckOut;
            this.Status = status;
            this.Discount = discount;
        }
        public Bill (DataRow row)
        {
            this.ID = (int)row["id"];
            this.DateCheckIn = (DateTime?)row["dateCheckIn"];
            var dateCheckOutTemp = row["dateCheckOut"];
            if(dateCheckOutTemp.ToString() != "")
                this.DateCheckOut = (DateTime?)dateCheckOutTemp;

            this.Status = (int)row["status"];
            if (row["discount"].ToString() != "")
                this.Discount = (int)row["discount"];
            
            
        }
        private int discount;
        private int status;
        private DateTime? dateCheckOut;
        private DateTime? dateCheckIn;
        private int iD;

       
        public DateTime? DateCheckIn { get { return dateCheckIn; } set => dateCheckIn = value; }
        public DateTime? DateCheckOut { get => dateCheckOut; set => dateCheckOut = value; }
        public int Status { get => status; set => status = value; }
        public int ID { get => iD; set => iD = value; }
        public int Discount { get => discount; set => discount = value; }
    }
}
