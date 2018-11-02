-- Part I – Working with an existing database

-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
    SELECT * FROM employee;

-- Task – Select all records from the Employee table where last name is King.
    SELECT * FROM employee
	    WHERE lastname = 'King';

-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
    SELECT * FROM employee
	    WHERE lastname = 'King' AND reportsto = null;

-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
    SELECT * FROM album
	    ORDER BY title DESC;

-- Task – Select first name from Customer and sort result set in ascending order by city
    SELECT firstname FROM customer
	    ORDER BY city;

-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
    INSERT INTO genre(genreid, name) VALUES 
	    (26,'EDM'),
	    (27,'Podcast');

-- Task – Insert two new records into Employee table
	INSERT INTO Employee (employeeid, lastname, firstname, title, reportsto, 
					 birthdate, hiredate, address, city, state, country,
					 postalcode, phone, fax, email)
			VALUES
			(9, N'Smith', N'John', N'IT Staff', 6,
			 '1980-06-15', '2004-04-18', N'789 Yonge St', N'Toronto', N'ON', N'Canada',
			 N'M4W 2G8', N'+1 (416) 654-9745', N'+1 (416) 654-1544', N'john@chinookcorp.com'),
			(10, N'Wruck', N'Miriam', N'Sales Support Agent', 2,
			 '1976-02-19', '2004-04-18', N'107 Vesta Dr', N'Toronto', N'ON', N'Canada',
			 N'M5P 2Z8', N'+1 (416) 635-6482', N'+1 (416) 635-6183', N'miriam@chinookcorp.com');

-- Task – Insert two new records into Customer table
	INSERT INTO Customer (CustomerId, FirstName, LastName, Company,
					  Address, City, State, Country, PostalCode, 
					  Phone, Fax, Email, SupportRepId) 
			VALUES (60, N'Dörte', N'Eckhard', N'Schallplattengeschäft des Westens',
					N'Chausseestraße 33', N'Berlin', N'Berlin', N'Germany',
					N'10115', N'+49 30 4147230', null, N'guteadresse@web.de', 3),
				   (61, N'Heiko', N'Höfler', N'Blütenburgstadt Arena',
				    N'Caroline-Michaelis-Straße 8', N'Berlin', N'Berlin', N'Germany',
					N'10115', N'+49 177 2806861', null, N'blütenburgarenaleiter@web.de', 3);

-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
	UPDATE customer
	SET firstname = 'Robert', lastname = 'Walter'
	WHERE firstname = 'Aaron' AND lastname = 'Mitchell';

-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
	UPDATE artist
	SET name = 'CCR'
	WHERE name = 'Creedence Clearwater Revival';

-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
	SELECT * FROM invoice
	WHERE billingaddress LIKE 'T%';

-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
	SELECT * FROM invoice
	WHERE total BETWEEN 15 AND 50;

-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
	SET SCHEMA'chinook';
	SELECT * FROM employee
	WHERE hiredate BETWEEN '2003-06-01' AND '2004-03-01';

-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
	ALTER TABLE invoice
	DROP CONSTRAINT FK_InvoiceCustomerId;
	
	ALTER TABLE invoiceline
	DROP CONSTRAINT FK_InvoiceLineInvoiceId;

	ALTER TABLE invoice
	ADD CONSTRAINT FK_InvoiceCustomerId
	FOREIGN KEY (customerid) REFERENCES customer (customerid)
	ON DELETE CASCADE;

	ALTER TABLE invoiceline
	ADD CONSTRAINT 	FK_InvoiceLineInvoiceId
	FOREIGN KEY (invoiceid) REFERENCES invoice (invoiceid)
	ON DELETE CASCADE;

	DELETE FROM customer
	WHERE firstname = 'Robert' AND lastname = 'Walter';

-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
	CREATE OR REPLACE FUNCTION get_time()
	RETURNS TIME AS $$
		BEGIN
			RETURN current_time; 
		END;
	$$ LANGUAGE plpgsql

-- Task – create a function that returns the length of a mediatype from the mediatype table
	CREATE OR REPLACE FUNCTION get_mediatype_length (mediaid INTEGER)
	RETURNS INTEGER AS $$
		DECLARE
			mediatype_length TEXT;
		BEGIN
			SELECT name INTO mediatype_length FROM mediatype WHERE mediatypeid = mediaID;
			RETURN LENGTH(mediatype_length);
		END;
	$$ LANGUAGE plpgsql;
	
-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
	CREATE OR REPLACE FUNCTION avg_total_all_invoices()
	RETURNS TEXT AS $$
		DECLARE
			average TEXT;
		BEGIN
			SELECT AVG(total) INTO average FROM invoice;
			RETURN average;
		END;
	$$ LANGUAGE plpgsql;

-- Task – Create a function that returns the most expensive track
	CREATE OR REPLACE FUNCTION get_most_expensive_track()
	RETURNS TABLE(
		name VARCHAR(200),
		untiprice NUMERIC(10,2)
	) 
	AS $$
		BEGIN
			RETURN QUERY
			SELECT track.name, track.unitprice FROM track
			ORDER BY unitprice DESC
			FETCH FIRST 1 ROWS ONLY;
		END;
	$$ LANGUAGE plpgsql;

-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
	CREATE OR REPLACE FUNCTION average_invoice_price()
	RETURNS TEXT AS $$
	DECLARE
		price NUMERIC(5,2);
		BEGIN
			SELECT AVG(unitprice) INTO price FROM invoiceline;
			RETURN price;
		END;
	$$ LANGUAGE plpgsql;

-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
	CREATE OR REPLACE FUNCTION employees_after_1968()
	RETURNS TABLE(
		employeeid INTEGER,     lastname VARCHAR(20), firstname VARCHAR(20),
		title VARCHAR(30),      reportsto INTEGER,    birthdate timestamp, hiredate timestamp,
		address VARCHAR(70),    city VARCHAR(40),     state VARCHAR(40),   country VARCHAR(40),
		postalcode VARCHAR(10), phone VARCHAR(24),    fax VARCHAR(24),     email VARCHAR(60)
	) AS $$
		BEGIN
			RETURN QUERY
				SELECT * FROM employee WHERE employee.birthdate >= '1969-01-01';
		END;
	$$ LANGUAGE plpgsql;

-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
	CREATE OR REPLACE FUNCTION get_employees_fl_name()
	RETURNS TABLE(
		firstname VARCHAR(20),
		lastname VARCHAR(20)
	) AS $$
		BEGIN
			RETURN QUERY
				SELECT employee.firstname, employee.lastname FROM employee;
		END;
	$$ LANGUAGE plpgsql;

-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
	CREATE OR REPLACE FUNCTION update_employee(
		   old_first_name varchar(20), 
		   old_last_name varchar, 
		   new_first_name varchar(20), 
		   new_last_name varchar
	)
		RETURNS VOID AS $$
		BEGIN
			UPDATE employee 
				SET firstname = new_first_name, lastname = new_last_name
				WHERE firstname = old_first_name AND lastname = old_last_name;
		END;
	$$ LANGUAGE plpgsql;

-- Task – Create a stored procedure that returns the managers of an employee.
	CREATE OR REPLACE FUNCTION get_managers(employee_id INTEGER)
	RETURNS TABLE(firstname VARCHAR(20), lastname VARCHAR(20)) AS $$
	DECLARE
		manager_id INTEGER;
		manager_manager_id INTEGER;
	BEGIN
		SELECT reportsto FROM employee INTO manager_id
		WHERE employeeid = employee_id;
		IF manager_id IS NOT NULL
			THEN
				SELECT reportsto FROM employee INTO manager_manager_id
				WHERE employee.employeeid = manager_id;
				RETURN QUERY
				SELECT employee.firstname, employee.lastname FROM employee 
				WHERE employee.employeeid = manager_id OR employee.employeeid = manager_manager_id;
		END IF;
	END;
$$ LANGUAGE plpgsql;
-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
	CREATE OR REPLACE FUNCTION get_customer_company(customer_id INTEGER)
	RETURNS TABLE (
		firstname VARCHAR(20),
		lastname VARCHAR(20),
		comapny VARCHAR(80)
	) 
	AS $$
		BEGIN
			RETURN QUERY
			SELECT customer.firstname, customer.lastname, company from customer
			WHERE customerid = customer_id;
		END;
	$$ LANGUAGE plpgsql;

-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
	CREATE OR REPLACE FUNCTION remove_invoice(invoice_ID INTEGER)
	RETURNS VOID AS $$
	BEGIN
		DELETE FROM invoice
		WHERE invoice.invoiceid = invoice_ID;
	END;
	$$ LANGUAGE plpgsql;
	
	-- As in 2.7
	ALTER TABLE invoice
	DROP CONSTRAINT FK_InvoiceCustomerId;
	
	ALTER TABLE invoiceline
	DROP CONSTRAINT FK_InvoiceLineInvoiceId;

	ALTER TABLE invoice
	ADD CONSTRAINT FK_InvoiceCustomerId
	FOREIGN KEY (customerid) REFERENCES customer (customerid)
	ON DELETE CASCADE;

	ALTER TABLE invoiceline
	ADD CONSTRAINT 	FK_InvoiceLineInvoiceId
	FOREIGN KEY (invoiceid) REFERENCES invoice (invoiceid)
	ON DELETE CASCADE;

	SELECT removeInvoice(412); -- because the constraints have been changed, this will no longer fail

-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
	CREATE OR REPLACE FUNCTION insert_new_customer(
		newcustomerid INTEGER, 
		newfirstname VARCHAR(40), 
		newlastname VARCHAR(20), 
		newcompany VARCHAR(80), 
		newadddress VARCHAR(70), 
		newcity VARCHAR(40), 
		newstate VARCHAR(40), 
		newcountry VARCHAR(40), 
		newpostalcode VARCHAR(10), 
		newphone VARCHAR(24), 
		newfax VARCHAR(24), 
		newemail VARCHAR(60), 
		newsupportrepid INTEGER
	)
	RETURNS VOID AS $$
		BEGIN
			INSERT INTO customer(
				customerid, firstname, lastname, company, address,
				city, state, country, postalcode, phone, fax, email,
				supportrepid
			)
			VALUES(
				newcustomerid, newfirstname, newlastname, newcompany, newadddress,
				newcity, newstate, newcountry, newpostalcode, newphone, newfax, newemail, 
				newsupportrepid
			);
		END;
	$$ LANGUAGE plpgsql;

-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
	CREATE OR REPLACE FUNCTION after_insert()
	RETURNS TRIGGER AS $$
		BEGIN
			-- STUFF HAPPENS HERE
		END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER insert_trigger
		AFTER INSERT
		ON employee
		FOR EACH ROW
		EXECUTE PROCEDURE after_insert();

-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
	CREATE OR REPLACE FUNCTION after_update()
	RETURNS TRIGGER AS $$
		BEGIN
			--STUFF HAPPENS HERE
		END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER update_trigger
		AFTER UPDATE
		ON album
		FOR EACH ROW
		EXECUTE PROCEDURE after_update();

-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
	CREATE OR REPLACE FUNCTION after_delete()
	RETURNS TRIGGER AS $$
		BEGIN
			--STUFF HAPPENS HERE
		END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER delete_trigger
		AFTER DELETE
		ON customer
		FOR EACH ROW
		EXECUTE PROCEDURE after_delete();

-- 6.2 Before
-- Task – Create a before trigger that restricts the deletion of any invoice that is priced over 50 dollars.
	CREATE OR REPLACE FUNCTION limited_delete()
	RETURN TRIGGER AS $$
		BEGIN
			IF OLD.total > 50 THEN
				RAISE EXCEPTION 'Inovices with a total greater then $50.00 cannot be deleted';
			END IF;
			RETURN NEW;
		END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER invoive_delete_upper_limit
		BEFORE DELETE
		ON invoice
		FOR EACH ROW
		EXECUTE PROCEDURE limited_delete();

-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
	SELECT customer.lastname, customer.firstname, invoice.invoiceid FROM customer
	INNER JOIN invoice ON invoice.customerid = customer.customerid;

-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
	SELECT customer.customerid, 
		customer.firstname,
		customer.lastname,
		invoice.invoiceid,
		invoice.total 
	FROM customer
	LEFT JOIN invoice ON customer.customerid = invoice.customerid;

-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
	SELECT artist.name, album.title FROM artist
	RIGHT JOIN album ON artist.artistid = album.artistid;

-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
	SELECT * from artist
	CROSS JOIN album
	ORDER BY artist.name ASC;

-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
	SELECT a.employeeid AS "employee_id",   a.firstname AS "employee_first_name",   a.lastname AS "employee_last_name",
	   	   b.employeeid AS "supervisor_id", b.firstname AS "supervisor_first_name", b.lastname AS "supervisor_last_name"
	FROM employee a, employee b
	WHERE a.reportsto = b.employeeid;