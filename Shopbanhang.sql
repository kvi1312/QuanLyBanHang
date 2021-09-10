CREATE DATABASE QuanLyQuanCafe
GO

USE QuanLyQuanCafe
GO

create table TableFood
(
	id int identity primary key,
	name nvarchar(100) not null default N'bàn chưa đặt tên',
	status nvarchar(100) not null default N'Trống', --trống|| có người
)
GO

create table Account
(

	UserName nvarchar(100) primary key, 
	DisplayName nvarchar(100) not null Default N'UserName',
	PassWord nvarchar(1000) not null default 0,
	Type Int not null, -- 1:admin && 0:staff
)
GO

create table FoodCategory
(
	id int identity primary key,
	name nvarchar(100) not null default N'chưa đặt tên',
)
GO

create table Food 
(
	id int identity primary key,
	Name nvarchar(100) not null default N'chưa đặt tên',
	idCatetory Int not null,
	price float not null default 0,
	foreign key (idCategory) references dbo.FoodCategory(id)
)

go

create table Bill
(
	id int identity primary key,
	DateCheckIn DATE not null default getdate(),
	DateCheckOut DATE,
	idTable INT not null,
	status Int  not null default 0, --1:da thanh toan || 0: chua thanh toan
	foreign key (idTable) references dbo.TableFood(id)
)
go

create table BillInfo
(
	id int identity primary key,
	idBill int not null,
	idFood int not null,
	count int not null default 0
	foreign key (idBill) references dbo.Bill(id),
	foreign key (idFood) references dbo.Food(id)
)
go

/* insert bàn*/

declare @i int = 0
while @i <= 10
begin
	insert dbo.TableFood(name) values (N'Bàn '+CAST(@i as nvarchar(100)))
	set @i= @i+1
End

/* thêm catogory*/
insert dbo.FoodCategory(name)
values(N'Hải Sản')

insert dbo.FoodCategory(name)
values(N'Nông Sản')

insert dbo.FoodCategory(name)
values(N'Lâm Sản')

insert dbo.FoodCategory(name)
values(N'Sản Sản')

insert dbo.FoodCategory(name)
values(N'Nước')

-- thêm món ăn
insert dbo.Food(name, idCategory,price)
values(N'Mực một nắng nướng sa tế',1,120000	)

insert dbo.Food(name, idCategory,price)
values(N'Nghêu hấp xả',1,50000	)

insert dbo.Food(name, idCategory,price)
values(N'dú dê nướng sữa',2,120000	)

insert dbo.Food(name, idCategory,price)
values(N'heo rừng nướng muối ớt',3,120000	)

insert dbo.Food(name, idCategory,price)
values(N'tokkboki',3,90000	)

insert dbo.Food(name, idCategory,price)
values(N'cơm chiên sushi',4,110000	)

insert dbo.Food(name, idCategory,price)
values(N'Sting',5,12000	)

insert dbo.Food(name, idCategory,price)
values(N'pepsi',2,10000	)

--thêm bill

insert dbo.Bill
			(DateCheckIn,
			DateCheckOut,
			idTable,
			status)
values (GETDATE(),
		null,
		3,
		0)

insert dbo.Bill
			(DateCheckIn,
			DateCheckOut,
			idTable,
			status)
values (GETDATE(),
		null,
		4,
		0)
insert dbo.Bill
			(DateCheckIn,
			DateCheckOut,
			idTable,
			status)
values (GETDATE(),
		GETDATE(),
		5,
		1)

--thêm bill info

insert dbo.BillInfo(
	idBill,idFood,count
)
values(5,1,2)

insert dbo.BillInfo(
	idBill,idFood,count
)
values(5,3,4)

insert dbo.BillInfo(
	idBill,idFood,count
)
values(5,5,1)

insert dbo.BillInfo(
	idBill,idFood,count
)
values(6,1,2)

insert dbo.BillInfo(
	idBill,idFood,count
)
values(6,6,2)

insert dbo.BillInfo(
	idBill,idFood,count
)
values(7,5,2)

-- bài13 thêm discount vào bảng bill

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


