---- Project Title: Library Management System 

CREATE DATABASE library_management;
USE library_management;

CREATE TABLE Books (
  BOOK_ID         INT AUTO_INCREMENT PRIMARY KEY,
  TITLE           VARCHAR(100) NOT NULL,
  AUTHOR          VARCHAR(100),
  GENRE           VARCHAR(50),
  YEAR_PUBLISHED  INT,
  AVAILABLE_COPIES INT DEFAULT 0
) 

CREATE TABLE Members (
  MEMBER_ID       INT AUTO_INCREMENT PRIMARY KEY,
  NAME            VARCHAR(100),
  EMAIL           VARCHAR(100),
  PHONE_NO        VARCHAR(15),
  ADDRESS         VARCHAR(255),
  MEMBERSHIP_DATE DATE
) 
drop table if exists BorrowingRecords

CREATE TABLE BorrowingRecords (
  BORROW_ID   INT AUTO_INCREMENT PRIMARY KEY,
  MEMBER_ID   INT,
  BOOK_ID     INT,
  BORROW_DATE DATE,
  RETURN_DATE DATE,
  CONSTRAINT fk_member FOREIGN KEY (MEMBER_ID) REFERENCES Members (MEMBER_ID),
  CONSTRAINT fk_book   FOREIGN KEY (BOOK_ID)   REFERENCES Books   (BOOK_ID)
) 

----Insert

INSERT INTO Books (TITLE, AUTHOR, GENRE, YEAR_PUBLISHED, AVAILABLE_COPIES) VALUES
  ('Ponniyin Selvan', 'Kalki Krishnamurthy', 'Historical Fiction', 1954, 3),
  ('Thirukkural',     'Thiruvalluvar',       'Ethics',            0,    5),
  ('SQL Made Simple', 'Anitha Raj',          'Technology',        2022, 2),
  ('Chennai Stories', 'K. S. Vasan',         'Fiction',           2018, 4),
  ('AI for Everyone', 'Sundar Kumar',        'Technology',        2023, 1);

INSERT INTO Members (NAME, EMAIL, PHONE_NO, ADDRESS, MEMBERSHIP_DATE) VALUES
  ('Karthik Rajendran',   'karthik.r@sample.in', '9876543210', 'Anna Nagar, Chennai', '2024-01-15'),
  ('Priya Balaji',        'priya.b@sample.in',   '9776543211', 'Velachery, Chennai',  '2024-02-20'),
  ('Aravind Subramanian', 'aravinds@sample.in',  '9676543212', 'T. Nagar, Chennai',   '2023-11-05'),
  ('Meena Iyer',          'meena.i@sample.in',   '9576543213', 'Mylapore, Chennai',   '2024-03-12');

INSERT INTO BorrowingRecords (MEMBER_ID, BOOK_ID, BORROW_DATE, RETURN_DATE) VALUES
  (1, 1, '2024-04-01', NULL),
  (1, 3, '2024-04-15', '2024-05-05'),
  (2, 2, '2024-05-10', NULL),
  (3, 4, '2024-03-20', '2024-04-02'),
  (4, 5, '2024-04-25', NULL);

select * from books
select * from borrowingrecords
select * from members

-- Queries
 ---- a)  list of books currently borrowed by a specific member:
 
SELECT b.TITLE, m.name
FROM   Books b
JOIN   BorrowingRecords br ON b.BOOK_ID = br.BOOK_ID
JOIN   Members m           ON m.MEMBER_ID = br.MEMBER_ID
WHERE  m.NAME = 'Karthik Rajendran'
  AND  br.RETURN_DATE IS not NULL;
  
  ------- b) Find members who have overdue books (borrowed more than 30 days ago, not returned):

SELECT DISTINCT m.NAME, m.EMAIL
FROM   Members m
JOIN   BorrowingRecords br USING (MEMBER_ID)
WHERE  br.RETURN_DATE IS NULL
  AND  br.BORROW_DATE < DATE_SUB(CURDATE(), INTERVAL 30 DAY);
  
----- c)Retrieve books by genre along with the count of available copies

SELECT GENRE, SUM(AVAILABLE_COPIES) AS total_available
FROM   Books
GROUP  BY GENRE;

------- d)	Find the most borrowed book(s) overall.

SELECT b.TITLE, COUNT(*) AS times_borrowed
FROM   Books b
JOIN   BorrowingRecords br USING (BOOK_ID)
GROUP  BY b.BOOK_ID
ORDER  BY times_borrowed DESC
LIMIT 1;

-------- e)	Retrieve members who have borrowed books from at least three different genres:

SELECT m.NAME
FROM   Members m
JOIN   BorrowingRecords br USING (MEMBER_ID)
JOIN   Books b           USING (BOOK_ID)
GROUP  BY m.MEMBER_ID
HAVING COUNT(DISTINCT b.GENRE) >= 3;

----- Reporting and Analytics: a)	Calculate the total number of books borrowed per month:

SELECT DATE_FORMAT(BORROW_DATE, '%Y-%m') AS month,
       COUNT(*)                          AS total_borrowed
FROM   BorrowingRecords
GROUP  BY month
ORDER  BY month;

----- b) Find the top three most active members based on the number of books borrowed.

SELECT m.NAME, COUNT(*) AS borrowed_count
FROM   Members m
JOIN   BorrowingRecords br USING (MEMBER_ID)
GROUP  BY m.MEMBER_ID
ORDER  BY borrowed_count DESC
LIMIT 3;

----- c) Retrieve authors whose books have been borrowed at least 10 times:

SELECT b.AUTHOR, COUNT(*) AS total_borrowed
FROM   Books b
JOIN   BorrowingRecords br USING (BOOK_ID)
GROUP  BY b.AUTHOR
HAVING total_borrowed >= 10;

----- d) Identify members who have never borrowed a book.

SELECT m.NAME
FROM   Members m
LEFT  JOIN BorrowingRecords br USING (MEMBER_ID)
WHERE  br.BORROW_ID IS NULL;
