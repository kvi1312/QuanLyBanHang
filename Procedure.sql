Procedure

--GetAccountByUserName 		
		
		create Proc [dbo].[USP_GetAccountByUserName]
@userName nvarchar(100)
as
begin 
	select * from dbo.Account where UserName = @userName
end



--proc Login
		
		create proc [dbo].[USP_Login]
@userName nvarchar(100), @passWord nvarchar(100)
AS
BEGIN
	select * from dbo.Account where UserName = @userName AND PassWord= @passWord
END	

--GetTableList proc

		create proc USP_GetTableList
		AS SElect *from dbo.TableFood
		go


--insert proc bill
		create proc USP_InsertBill
		@idTable int
		as
		begin
			insert dbo.Bill(
							DateCheckIn,
							DateCheckOut,
							idTable,
							status
			)
			values (getdate(),
					null,
					@idTable,
					0
			)
		end
		go

--insert proc billinfo 

--add xong casi nay

		create proc USP_InsertBillInfo
		@idBill int, @idFood int, @count int
		as
		begin
			insert dbo.BillInfo (idBill, idFood,count)
			values(@idBill, @idFood, @count)
		end
		go

		-- roi add toi cai nay 
						alter proc USP_InsertBillInfo
				@idBill int, @idFood int, @count int
				as
				begin
					declare @isExitsBillInfo int

					declare @foodCount int = 1
					
					select @isExitsBillInfo= id, @foodCount = b.count from dbo.BillInfo as b where idBill= @idBill and idFood= @idFood
					
					if (@isExitsBillInfo >0)
					
					begin
						declare @newCount int = @foodCount + @count
						if(@newCount >0)
							update dbo.BillInfo set count = @foodCount +@count where idFood = @idFood
						else
							delete dbo.BillInfo where idBill = @idBill and idFood =@idFood		
					end
					Else 
					begin
						insert dbo.BillInfo (idBill, idFood,count)
						values(@idBill, @idFood, @count)
					
					end
				end
				go

--bài 12 add trigger
 -- bước 1

 			create trigger UTG_UpdateBillInfo
on dbo.BillInfo for insert, update
as
begin
	declare @idBill int
	select @idBill= idBill from Inserted
	declare @idTable int
	select @idTable = idTable from dbo.Bill where id= @idBill and status = 0
	declare @count int
	select @count = count(*) from dbo.BillInfo where idBill =@idBill
	if(@count >0)
		update dbo.TableFood set status = N'có người' where id = @idTable
	else
		update dbo.TableFood set status = N'Trống' where id = @idTable

	
end
go

--bước 2
		
create Trigger UTG_UpdateBill
on dbo.Bill for update
as
begin
	declare @idBill int

	select @idBill = id from inserted
	
	declare @idTable int

	select @idTable = idTable from dbo.Bill where id= @idBill
	
	declare @count int = 0

	select @count = count(*) from dbo.Bill where idTable= @idTable and status =0

	if(@count = 0)
		
		update dbo.TableFood set status = N'trống' where id = @idTable
	
end
go

--bước3

delete dbo.BillInfo
delete dbo.Bill

--bài 13
alter table Bill
add discount int

update bill set discount =0

alter proc USP_InsertBill
		@idTable int
		as
		begin
			insert dbo.Bill(
							DateCheckIn,
							DateCheckOut,
							idTable,
							status,
							discount
			)
			values (getdate(),
					null,
					@idTable,
					0,
					0
			)
		end
		go
-- bước 2
		create proc USP_SwitchTable
 @idTable1 int, @idTable2 int
as begin
	declare @idFirstBill int
	declare @idSecondBill int

	declare @isFirstTableEmpty int = 1
	declare @isSecondTableEmpty int = 1

	select @idSecondBill =id from dbo.Bill where idTable = @idTable2  AND status = 0
	select @idFirstBill =id from dbo.Bill where idTable = @idTable1  AND status = 0

	print @idFirstBill
	print @idSecondBill
	print'-----'

	if(@idFirstBill is null)
	begin
		insert dbo.Bill
				(DateCheckIn,
				DateCheckOut,
				idTable,
				status)
		values (GETDATE(),
				null,
				@idTable1,
				0)
		select @idFirstBill =MAX(id) from dbo.Bill where idTable = @idTable1 and status =0
		
	end
		select @isFirstTableEmpty = COUNT(*) from BillInfo where idBill = @idFirstBill
	if(@idSecondBill is null)
	begin
		insert dbo.Bill
				(DateCheckIn,
				DateCheckOut,
				idTable,
				status)
		values (GETDATE(),
				null,
				@idTable2,
				0)
		select @idSecondBill =MAX(id) from dbo.Bill where idTable = @idTable2 and status =0
		
	end
		select @isSecondTableEmpty = count(*) from BillInfo where idBill= @idSecondBill
	select id into IDBillInfoTable from BillInfo where idBill = @idSecondBill
	update BillInfo set idBill = @idSecondBill where idBill =@idFirstBill
	update BillInfo set idBill= @idFirstBill where id in (select * from IDBillInfoTable)
	drop table IDBillInfoTable

	if(@isFirstTableEmpty =0)
	update dbo.TableFood set status = N'Trống' where id = @idTable2

	if(@isSecondTableEmpty =0)
	update dbo.TableFood set status = N'Trống' where id = @idTable1
end
go
-- bài 14
alter table dbo.bill add totalPrice float

create proc USP_GetListBillByDate
@checkIn date, @checkOut date
as
begin
	select t.name, b.totalPrice as [Tổng Tiền], DateCheckIn as [Ngày Vào], DateCheckOut as [Ngày Ra], discount as [Giảm Giá]
	from dbo.Bill as b, dbo.TableFood as t
	where DateCheckIn >= @checkIn and DateCheckOut <= @checkOut and b.status=1
	and t.id = b.idTable
end 
go
--bai 15

create proc USP_UpdateAccount 
@userName nvarchar(100), @displayName nvarchar(100), @password nvarchar(100), @newPassword nvarchar(100)
as
begin
	declare @isRightPass int
	select @isRightPass = count (*) from dbo.Account where UserName = @userName and PassWord= @password
	if(@isRightPass = 1)
	begin
		if(@password = null or @newPassword = '')
		begin
			update dbo.Account set DisplayName =@displayName where UserName= @userName
		end
		else
			update dbo.Account set DisplayName =@displayName, PassWord= @newPassword where UserName = @userName
	end
end
go
-- bài 18

create trigger UTG_DeleteBillInfo
on dbo.BillInfo for Delete
as
begin
	declare @idBillInfo int
	declare @idBill int
	select @idBillInfo = id, @idBill = deleted.idBill from deleted

	declare @idTable int
	select @idTable = idtable from dbo.bill where id = @idBill

	declare @count int = 0

	select @count= Count(*) from dbo.BillInfo as bi, dbo.bill as b  where b.id = bi.idBill  and b.id = @idBill and b.status=0

	if(@count =0)
		update dbo.TableFood set status = N'Trống' where id = @idTable
end
go



-- bài 24

create proc USP_GetListBillByDateAndPage
@checkIn date, @checkOut date, @page int
as
begin
	declare @pageRows int =10
	declare @selectRows int= @pageRows * @page
	declare @exceptRows int = (@page -1) *@pageRows

	;with BillShow as( select t.name, b.totalPrice as [Tổng Tiền], DateCheckIn as [Ngày Vào], DateCheckOut as [Ngày Ra], discount as [Giảm Giá]
	from dbo.Bill as b, dbo.TableFood as t
	where DateCheckIn >= @checkIn and DateCheckOut <= @checkOut and b.status=1
	and t.id = b.idTable)

	select top (@selectRows) * from BillShow
	except
	select top (@exceptRows) * from BillShow

end 
go


create proc USP_GetNumBillByDate
@checkIn date, @checkOut date
as
begin
	select count (*)
	from dbo.Bill as b, dbo.TableFood as t
	where DateCheckIn >= @checkIn and DateCheckOut <= @checkOut and b.status=1
	and t.id = b.idTable
end 
go