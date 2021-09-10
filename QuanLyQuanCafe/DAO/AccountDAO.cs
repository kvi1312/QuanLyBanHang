using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using QuanLyQuanCafe.DTO;
using System.Security.Cryptography;
using System.Linq;

namespace QuanLyQuanCafe.DAO
{
    class AccountDAO
    {
        private static AccountDAO instance;

        public static AccountDAO Instance
        {
            get { if (instance == null) instance = new AccountDAO(); return instance; }
            private set { instance = value; }
        }

        private AccountDAO()
        {

        }

        public DataTable GetListAccount()
        {
            return DataProvider.Instance.ExecuteQuery("select UserName, DisplayName, Type from Account");
        }
        public bool Login(string userName, string passWord)
        {
            //mã hóa tài khoản
            //byte[] temp = ASCIIEncoding.ASCII.GetBytes(passWord);
            //byte[] hasData = new MD5CryptoServiceProvider().ComputeHash(temp);
            //string hasPass = "";
            //foreach(byte item in hasData)
            //{
            //    hasPass += item;
            //}
            //var list = hasData.ToString();
            //list.Reverse();
            

            string query = "USP_Login @userName , @passWord";

            DataTable result = DataProvider.Instance.ExecuteQuery(query, new object[]{ userName, passWord});

            return result.Rows.Count > 0;
        }
        public bool UpdateAccount(string userName, string displayName, string pass, string newPass)
        {
            int result = DataProvider.Instance.ExecuteNonQuery("exec USP_UpdateAccount @userName , @displayName , @password , @newPassword", new object[] { userName, displayName, pass, newPass});
            return result  > 0;
        }
        public Account GetAccountByUserName(string userName)
        {
            DataTable data= DataProvider.Instance.ExecuteQuery("select * from account where userName= '" + userName+ "'");

            foreach(DataRow item in data.Rows)
            {
                return new Account(item);
            }
            return null;
        }

        public bool InsertAccount(string name, string displayName, int type)
        {
            string query = string.Format("insert dbo.Account (UserName, DisplayName, Type) values (N'{0}' , N'{1}', {2})", name, displayName, type);
            int result = DataProvider.Instance.ExecuteNonQuery(query);
            return result > 0;

        }
        public bool UpdateAccount(string name, string displayName, int type)
        {
            string query = string.Format("update dbo.Account set  DisplayName = N'{1}' , type = {2} where UserName = N'{0}'", name, displayName, type);
            int result = DataProvider.Instance.ExecuteNonQuery(query);
            return result > 0;

        }

        public bool DeleteAccount(string name)
        {
            
            string query = string.Format("delete Account where UserName = N'{0}'", name);
            int result = DataProvider.Instance.ExecuteNonQuery(query);
            return result > 0;
        }

        public bool ResetPassword(string name)
        {
            string query = string.Format("update account set password = N'0' where UserName = N'{0}'", name);
            int result = DataProvider.Instance.ExecuteNonQuery(query);
            return result > 0;
        }
       
    }
}
