CREATE DATABASE Library_Management_System;
USE Library_Management_System;

CREATE TABLE Members_T( MemberID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
						MemberName VARCHAR(50),
                        ContactNumber BIGINT,
                        EmailId VARCHAR(50),
                        PreferredContactMethod VARCHAR(10), 
                        MemberTier VARCHAR(10)
						);
                        
INSERT INTO Members_T(MemberName, ContactNumber, EmailId, PreferredContactMethod) VALUES
					 ("Neha Jagatramka", 4252339023, "neha.jagatramka@gmail.com", "Mobile"),
                     ("Vishesh Walia", 9452414584, "vishesh.walia@gmail.com", "Email"),
                     ("Mehraj Sulatinia", 9454009149, "mehraj.sultania@gmail.com", "Mobile"),
                     ("Yukyung Cha", 4694940708, "yukyung.cha@gmail.com", "Email"),
                     ("Ray Chou", 7206958110, "ray.cha@gmail.com", "Mobile");
                     
                     
ALTER TABLE Members_T ADD is_active INT NOT NULL DEFAULT 1;

SELECT * 
FROM Members_T;

DELIMITER //
CREATE PROCEDURE delete_member(
IN Member_ID INT 
)
BEGIN 
UPDATE Members_T
SET is_active = 0
WHERE Member_ID = MemberID;
END//

DELIMITER;

CALL delete_member(4);

#Members_audit
CREATE TABLE Members_audit( MemberID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
						MemberName VARCHAR(50),
                        ContactNumber BIGINT,
                        EmailId VARCHAR(50),
                        PreferredContactMethod VARCHAR(10),
                        LastUpdated DATE,
                        action varchar(20)
						);
	DROP TABLE Members_audit;


#update_trigger for Members
DELIMITER //                       
CREATE TRIGGER Members_audit
	AFTER UPDATE ON Members_T
    FOR EACH ROW
	INSERT INTO  Members_audit
    SET LastUpdated = NOW(),
		action = "Updated",
        MemberID = OLD.MemberID,
	    MemberName = OLD.MemberName,
		ContactNumber = OLD.ContactNumber,
	    EmailId = OLD.EmailId,
		PreferredContactMethod = OLD.PreferredContactMethod;
END//
DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
UPDATE Members_T
SET 
	MemberName = "Anurag Agrawal"
WHERE 
	MemberID = 3;
SELECT * 
FROM Members_audit ;

CREATE TABLE Authors_T( AuthorID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
					  AuthorName VARCHAR(50)
                      );

ALTER TABLE Authors_T AUTO_INCREMENT = 2000;

INSERT INTO AUTHORS_T (AuthorName) VALUES 
					("Dan Brown"),("John Green"),("Murakami"),("J.K. Rowling"), ("Agatha Christie");
                    

CREATE TABLE Publications_T(PublicationID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
							PublicationName VARCHAR(50)
                            );
ALTER TABLE Publications_T AUTO_INCREMENT = 3000;

INSERT INTO Publications_T (PublicationName) VALUES
						("Pandas"),("Penguin"),("GoodFolks"),("WritingCompany"), ("StoryTeller");
DROP TABLE Inventory_T;                        
CREATE TABLE Inventory_T(ResourceID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
						 ResourceName VARCHAR(20),
                         Count INT DEFAULT 50,
                         LastUpdated DATETIME);
                                     
ALTER TABLE Inventory_T AUTO_INCREMENT=1000;

INSERT INTO Inventory_T(ResourceName, Count, LastUpdated)
VALUES ("Self help", "50", NOW()),
       ("Magazine", "500", NOW()),
       ("Fictional", "200", NOW()),
       ("Autobiography", "150", NOW()),
       ("Historical", "500", NOW());      
       
DROP TABLE Books_T;
CREATE TABLE Books_T( BookID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
					  BookName VARCHAR(50),
                      AuthorID INT,
                      PublisherID INT,
                      is_deleted INT NOT NULL DEFAULT 0,
                      CONSTRAINT AuthorID_fk FOREIGN KEY(AuthorID) REFERENCES Authors_T(AuthorID) ,
                      CONSTRAINT PublisherID_fk FOREIGN KEY(PublisherID) REFERENCES Publications_T(PublicationID),
                      CONSTRAINT BookID_fk FOREIGN KEY(BookID) REFERENCES Inventory_T(ResourceID)
                      );
ALTER TABLE Books_T AUTO_INCREMENT=1000;

INSERT INTO  Books_T(BookID, BookName, AuthorID, PublisherID) VALUES
					(1000, "Atomic Habits", 2000, 3000),
                    (1001, "Forbes 2022 Edition", 2001, 3001),
                    (1002, "Da Vinci Book", 2002, 3002),
                    (1003, "Steve Jobs", 2003, 3003),
                    (1004, "Team of Rivals", 2004, 3004);

DELIMITER //
CREATE PROCEDURE delete_books(
IN Book_ID INT 
)
BEGIN 
UPDATE Books_T
SET is_deleted = 1
WHERE Book_ID = BookID;
UPDATE Inventory_T
SET  Count = 0,
	 LastUpdated = NOW()
WHERE ResourceID = Book_ID;
END//

DELIMITER;

DELIMITER //
CREATE PROCEDURE add_books(
IN Book_Name varchar(20), Author_Name varchar(20), Publisher_name VARCHAR(20) 
)
BEGIN
DECLARE pid INT; 
DECLARE aid INT;

set pid = 0;
set aid = 0;

IF pid NOT IN (SELECT PublicationID FROM Publications_T)
THEN
INSERT INTO Publications_T(PublicationName) VALUES (Publisher_name);
SET pid = (SELECT PublicationID FROM Publications_T WHERE PublicationName = Publisher_name );
ELSE
SET pid = (SELECT PublicationID FROM Publications_T WHERE PublicationName = Publisher_name );
END IF;

IF aid NOT IN (SELECT AuthorID FROM Authors_T)
THEN
INSERT INTO Authors_T(AuthorName) VALUES (Author_Name);
SET aid = (SELECT AuthorID FROM Authors_T WHERE AuthorName = Author_Name );
ELSE
SET aid = (SELECT AuthorID FROM Authors_T WHERE AuthorName = Author_Name );
END IF;

IF Book_Name NOT IN (SELECT ResourceName from Inventory_T)
THEN
INSERT INTO Inventory_T(ResourceName, LastUpdated) VALUES (Book_Name, NOW());
ELSE
SELECT "Book already in database";
END IF;

IF Book_Name NOT IN (SELECT BookName from Books_T)
THEN
INSERT INTO Books_T(BookName, AuthorID, PublisherID) VALUES (Book_Name, aid, pid);
ELSE
SELECT "Book already in database";
END IF;
END//

DELIMITER ;

CALL add_books("Gandhi7", "FYZ", "ABC");
CALL delete_books(1000);
select * from authors_t;
select * from publications_T;
SELECT * 
FROM Books_T;

SELECT * 
FROM  Inventory_T;                 
CREATE TABLE Transactions_T(TransactionID INT PRIMARY KEY,
					  TransactionType VARCHAR(20),
                      FeesType VARCHAR(20),
                      MemberID INT);
                      
CREATE TRIGGER add_into_transaction
	AFTER INSERT ON Master_T
    FOR EACH ROW
   INSERT INTO Transactions_T
   SET Transactions_T.TransactionID = NEW.TransactionID,
		Transactions_T. FeesType= NEW.FinanceType,
        TransactionType = NEW.TransactionType,
        MemberID = NEW.MemberID;

  DROP TABLE       Transactions_T  ; 
  DROP TRIGGER add_into_transaction;
                      

CREATE TABLE Employees_T( EmployeeID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
						  EmployeeFirstName VARCHAR(25),
                          EmployeeLastName VARCHAR(25),
                          EmployeeStreetAddress VARCHAR(30),
                          EmployeeCity VARCHAR(30),
                          EmployeeState VARCHAR(2),
                          EmployeeZipCode VARCHAR(10),
                          EmployeePhoneNumber BIGINT,
                          EmployeeBirthDate DATE
                          );
ALTER TABLE Employees_T AUTO_INCREMENT=10000;
ALTER TABLE Employees_T ADD is_active INT NOT NULL DEFAULT 1;


INSERT INTO Employees_T (EmployeeFirstName, EmployeeLastName, EmployeeStreetAddress, EmployeeCity, EmployeeState,EmployeeZipCode, EmployeePhoneNumber, EmployeeBirthDate) 
VALUES ("Allison", "Burgers", "850 Cecil Drive", "Richardson", "TX", '75080', "94526362636", "1995-01-26"),
	   ("John", "Wick", "160 Johnson Street", "Chicago", "IL", '67587', "94526362636", "1995-01-26"),
	   ("Tony", "Stark", "201 Martha Drive", "Richardson", "TX", '75080', "2464571234", "1992-01-14"),
       ("Natasha", "Romanoff", "616 Cecil Drive", "New York City", "NY", '82467', "7562471358", "1994-05-20"),
       ("Taylor", "Swift", "6th Ave Road", "Seattle", "WA", '98121', "9452636167", "1993-07-27");
       
DELIMITER //
CREATE PROCEDURE delete_employee(
IN Employee_ID INT 
)
BEGIN 
UPDATE Employees_T
SET is_active = 0
WHERE Employee_ID = EmployeeID;
END//

DELIMITER;
CALL delete_employee(10004)
SELECT * FROM Employees_T;

CREATE TABLE employee_audit(EmployeeID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
						  EmployeeFirstName VARCHAR(25),
                          EmployeeLastName VARCHAR(25),
                          EmployeeStreetAddress VARCHAR(50),
                          EmployeeCity VARCHAR(30),
                          EmployeeState VARCHAR(2),
                          EmployeeZipCode VARCHAR(10),
                          EmployeePhoneNumber BIGINT,
                          EmployeeBirthDate DATE,
                          LastUpdated DATE,
                          action varchar(20));
                          
DROP TABLE employee_audit;
#trigger_UPDATE for Employees_T
DELIMITER //                       
CREATE TRIGGER employee_audit
	AFTER UPDATE ON Employees_T
    FOR EACH ROW
	INSERT INTO employee_audit
    SET LastUpdated = NOW(),
		action = "Updated",
        EmployeeID = OLD.EmployeeID,
		EmployeeFirstName = OLD.EmployeeFirstName,
		EmployeeLastName = OLD.EmployeeLastName,
        EmployeeStreetAddress = OLD.EmployeeStreetAddress,
		EmployeeCity = OLD.EmployeeCity,
		EmployeeState = OLD.EmployeeState,
	    EmployeeZipCode =  OLD.EmployeeZipCode,
		EmployeePhoneNumber = OLD.EmployeePhoneNumber,
	    EmployeeBirthDate = OLD.EmployeeBirthDate;
 DROP TRIGGER employee_audit;       
END//
DELIMITER ;


UPDATE Employees_T
SET 
	EmployeeFirstName = "Smith" ,
    EmployeeLastName = "John"
WHERE 
	EmployeeID = 10003;

SELECT *
FROM employee_audit;
    
    
SELECT * 
FROM Employees_T;

CREATE TABLE Rooms_T(RoomID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
					 RoomType VARCHAR(50),
					 Capacity INT,
                     Availibility DATETIME
					);
ALTER TABLE Rooms_T AUTO_INCREMENT = 500;
                    
INSERT INTO Rooms_T(RoomType, Capacity, Availibility)VALUES
				   ('Conference Room', '12',NOW()),
				   ('Meeting Room', '8', NOW()),
				   ('Conference Room', '12', NOW()),
                   ('Meeting Room', '8', NOW()),
                   ('Meeting Room', '8', NOW());
                   

DROP TABLE Finances_T;
CREATE TABLE Finances_T(FinanceType VARCHAR(20) PRIMARY KEY,
						Fees INT
                      );
                      
                     
                      
INSERT INTO Finances_T (FinanceType, Fees) VALUES 
						("Late fee", 30), 
                        ("No show", 25), 
						("Damage to property", 40), 
                        ("Lost items", 50), 
                        ("Membership fee", 20),
                        ("Member", 0);

CREATE TABLE Master_T( MemberID INT, 
			   BookID INT,
               EmployeeID INT,
               TransactionID INT PRIMARY KEY AUTO_INCREMENT,
               FinanceType VARCHAR(20) DEFAULT "Member",
               TransactionType VARCHAR(20) DEFAULT "Free",
               Is_Borrowed INT NOT NULL DEFAULT 0,
               Is_Returned INT NOT NULL DEFAULT 0,
               Date_Issued DATETIME,
               Date_Returned DATETIME,
               CONSTRAINT MemberID_fk FOREIGN KEY(MemberID) REFERENCES Members_T(MemberID) ON DELETE CASCADE,
               CONSTRAINT BookID_fk1 FOREIGN KEY(BookID) REFERENCES Books_T(BookID),
               CONSTRAINT EmployeeID_fk FOREIGN KEY(EmployeeID) REFERENCES Employees_T(EmployeeID),
               CONSTRAINT FinanceType_fk FOREIGN KEY(FinanceType) REFERENCES Finances_T (FinanceType)
               );
DROP TABLE Master_T;
ALTER TABLE Master_T AUTO_INCREMENT=5000;

DELIMITER //
CREATE PROCEDURE Master_Entry_Borrowed(
IN 	Member_ID INT, 
	Book_ID INT,
	Employee_ID INT
)
BEGIN
IF (SELECT Count FROM Inventory_T where ResourceID = Book_ID) >=1 AND Book_ID IN (SELECT ResourceID from Inventory_T)
THEN

INSERT INTO Master_T(MemberID, BookID, EmployeeID, Is_Borrowed, Date_Issued) values
(Member_ID ,Book_ID, Employee_ID, 1, NOW());

UPDATE Inventory_T 
SET Count = Count - 1,
LastUpdated = NOW();

ELSE
Select "Book out of stock";

END IF;
END//

DELIMITER ;

Call Master_Entry_Borrowed(1,1001,10001);
TRUNCATE TABLE Master_T;
select * from Master_T;









    
    

INSERT INTO Master_T(MemberID, BookID, EmployeeID, FinanceType, TransactionType) VALUES 
			(1, 1000, 10000, "Late fee" , "Credit"),
            (3, 1004, 10003, "Damage to property", "Cash"),
            (4, 1000, 10002, "Lost items", "Credit"),
            (5, 1000, 10002, "Membership fee", "Cash");
            
SELECT * FROM Transactions_T;

INSERT INTO Master_T(MemberID, BookID, EmployeeID, FinanceType, TransactionType) VALUES 
			(1, 1000, 10000, "Late fee" , "Credit"),
            (3, 1004, 10003, "Damage to property", "Cash"),
            (4, 1000, 10002, "Lost items", "Credit"),
            (5, 1000, 10002, "Membership fee", "Cash");
            
INSERT INTO Master_T(MemberID, BookID, EmployeeID, FinanceType, TransactionType) VALUES 
			(1, 1000, 10000, "Late fee" , "Credit"),
            (1, 1004, 10003, "Damage to property", "Cash"),
            (1, 1000, 10002, "Lost items", "Credit"),
            (1, 1000, 10002, "Membership fee", "Cash");

            
CREATE TABLE Reservations_T( ReservationID INT NOT NULL PRIMARY KEY,
							 MemberID INT,
                             RoomNo INT,
                             FROM_DATETIME DATETIME,
                             TO_DATETIME DATETIME,
                             ExpectedCount INT,
                             CONSTRAINT MemberID_fk1 FOREIGN KEY(MemberID) REFERENCES Members_T(MemberID) ON DELETE CASCADE,
                             CONSTRAINT RoomNo_fk FOREIGN KEY(RoomNo) REFERENCES Rooms_T(RoomID)
                       );
 DROP TABLE  Reservations_T   ;                          
CREATE TABLE Requests_T(RequestID INT PRIMARY KEY AUTO_INCREMENT,
						MemberID INT,
                        Book_Name varchar(30),
                        CONSTRAINT MemberID_fk2 FOREIGN KEY(MemberID) REFERENCES Members_T(MemberID)
                      );

INSERT INTO Requests_T (MemberID,Book_Name) VALUES 
					   (1,"The Midnight Library"),  
                       (2,"Anxious People"), 
                       (3,"The Kite Runner"), 
                       (4,"Anxious People"), 
                       (5,"The Midnight Library");

CREATE TABLE BookToOrder_T(OrderID INT PRIMARY KEY AUTO_INCREMENT,
                        Book_Name varchar(30)
                      );
ALTER TABLE BookToOrder_T AUTO_INCREMENT = 20000;
	
DELIMITER //
create TRIGGER insert_into_bookto_order
after insert on Requests_T for each row begin
DECLARE updatecount INT;
set updatecount = (SELECT COUNT(Book_Name) FROM Requests_T where book_name = new.book_name);
if updatecount >= 5 and new.book_name not in (select book_name from booktoorder_T)
    then
	insert into booktoorder_T(book_name) values (new.book_name);
  end if;
end//
DELIMITER ;









DELIMITER $$
CREATE TRIGGER Transactions_after_insert
AFTER INSERT ON Transactions_T
FOR EACH ROW
BEGIN
     IF (SELECT COUNT(TransactionID) FROM Transactions_T GROUP BY MemberID) >= 10 THEN
         UPDATE Members_T
         SET Members_T.MemberTier = "GOLD";
	 ELSEIF ((SELECT COUNT(TransactionID) FROM Transactions_T GROUP BY MemberID) < 10 AND (SELECT COUNT(TransactionID) FROM Transactions_T GROUP BY MemberID) >= 5) THEN
         UPDATE Members_T
         SET Members_T.MemberTier = "SILVER";
	 ELSE 
         UPDATE Members_T
         SET Members_T.MemberTier = "BRONZE";
	END IF;
END $$
DELIMITER ;	

DROP TRIGGER Transactions_after_insert;
SELECT * 
FROM Transactions_T;
			

 SELECT COUNT(TransactionID) FROM Transactions_T GROUP BY MemberID                     
                      
DELIMITER //

CREATE FUNCTION Total_Books_Borrowed()
Returns INT
DETERMINISTIC
Begin
DECLARE Count_borrowed INT;
SET count_borrowed = (SELECT COUNT(is_borrowed) from master_T);
RETURN(count_borrowed);
END//

DELIMITER ;

select total_books_borrowed();

DELIMITER $$

CREATE PROCEDURE Master_book_returned(
IN Member_ID INT, 
Employee_ID BIGINT,
Book_ID INT)
BEGIN
IF (SELECT is_borrowed from master_t where memberID = Member_ID and BookID = Book_ID) = 1
THEN 
UPDATE Master_T
SET IS_borrowed = 0,
 IS_returned = 1,
 EmployeeID = Employee_ID,
 Date_Returned = NOW()
where memberID = Member_ID and bookid = book_id;
ELSE
SELECT "Book not borrowed";
END IF;
END$$

DELIMITER ;

CREATE TABLE Master_Audit( MemberID INT, 
			   BookID INT,
               EmployeeID INT,
               TransactionID INT PRIMARY KEY AUTO_INCREMENT,
               FinanceType VARCHAR(20) DEFAULT "Member",
               TransactionType VARCHAR(20) DEFAULT "Free",
               Is_Borrowed INT NOT NULL DEFAULT 0,
               Is_Returned INT NOT NULL DEFAULT 0,
               Date_Issued DATETIME,
               Date_Returned DATETIME,
               Action VARCHAR(20),
               LastUpdated DATETIME
			);

DELIMITER //               
CREATE TRIGGER after_master_update
AFTER UPDATE ON Master_T
FOR EACH ROW
INSERT INTO Master_Audit
		SET Action = 'UPDATE',
			LastUpdated = NOW(),
            MemberID = OLD.MemberID, 
			BookID = OLD.BookID,
			EmployeeID = OLD.EmployeeID,
			TransactionID = OLD.TransactionID,
			FinanceType = OLD.FinanceType,
			TransactionType = OLD.TransactionType,
			Is_Borrowed = OLD.Is_Borrowed,
			Is_Returned = OLD.Is_Returned,
			Date_Issued = OLD.Date_Issued,
			Date_Returned = OLD.Date_Returned;
END//
DELIMITER ;

CALL Master_book_returned(1,10003,1003);


select count(*)*30 from master_t
where is_returned = 1 and DATEDIFF(Date_returned, date_issued) > 15;
                     
    

SELECT MemberID, COUNT(MemberID) AS timesBookBorrowed
FROM Master_T
GROUP BY MemberID
ORDER BY COUNT(MemberID) DESC
LIMIT 5;

SELECT BookID, Count(BookID) AS TimesBookIsBorrowed
FROM Master_T
GROUP BY BookID
ORDER BY Count(BookID) DESC
LIMIT 5;

SELECT P. PublicationName, COUNT(B. BookName)
FROM Books_T  AS B JOIN Publications_T AS P
ON B.PublisherID = P.PublicationID
GROUP BY P. PublicationName;

SELECT A.AuthorName, COUNT(B. BookName)
FROM Books_T  AS B JOIN  Authors_T AS A
ON B.AuthorID = A.AuthorID
GROUP BY A.AuthorName;
                             
                             
               

               
               
			   


                          

                          
                          
                          