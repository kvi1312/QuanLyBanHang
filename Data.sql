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

alter table Bill
add discount int

update bill set discount =0
