--TABLES
CREATE TABLE Product (
product_id INTEGER NOT NULL, 
product_name VARCHAR (64) NOT NULL,
Price DECIMAL (10,2) NOT NULL, 
PRIMARY KEY(product_id)
);


CREATE TABLE Inventory (
product_id INTEGER NOT NULL, 
stock_level INTEGER NOT NULL, 
PRIMARY KEY(product_id),
FOREIGN KEY(product_id) REFERENCES Product(product_id)
);

CREATE TABLE Supplier (
supplier_id INTEGER NOT NULL, 
supplier_name VARCHAR(64) NOT NULL, 
product_id INTEGER NOT NULL, 
quantity INTEGER NOT NULL, 
PRIMARY KEY(supplier_id),
FOREIGN KEY(product_id) REFERENCES Product (product_id)
);

CREATE TABLE Customer1 (
customer_id INTEGER NOT NULL, 
customer_name VARCHAR (64) NOT NULL, 
customer_contact INTEGER NOT NULL, 
purchase_history VARCHAR(64) NOT NULL,
PRIMARY KEY (customer_id)
);

CREATE TABLE ORDER1(
order_id INTEGER NOT NULL,
customer_id INTEGER NOT NULL, 
product_id INTEGER NOT NULL, 
order_date DATE, 
order_status VARCHAR(15), 
PRIMARY KEY(order_id), 
FOREIGN KEY(customer_id) REFERENCES Customer1(customer_id), 
FOREIGN KEY(product_id) REFERENCES Product(product_id)
);

CREATE TABLE OrderItem(
order_item_id INTEGER NOT NULL,
order_id INTEGER NOT NULL,
product_id INTEGER NOT NULL,
quantity INTEGER NOT NULL,
PRIMARY KEY (product_id),
FOREIGN KEY(product_id) REFERENCES Product (product_id)
);

CREATE TABLE Employee_details( 
employee_id INTEGER NOT NULL, 
employee_name VARCHAR (64) NOT NULL, 
employee_contact INTEGER(20) NOT NULL, 
employee_position VARCHAR(64) NOT NULL, 
PRIMARY KEY (employee_id)
);

CREATE TABLE Employee_assignment( 
assignment_id INTEGER NOT NULL, 
employee_id INTEGER NOT NULL, 
order_id INTEGER NOT NULL, PRIMARY KEY (assignment_id),
FOREIGN KEY(employee_id) REFERENCES Employee_details(employee_id),
FOREIGN KEY(order_id) REFERENCES Order1(order_id)
);

CREATE TABLE Manager_details(
manager_id INTEGER NOT NULL, 
employee_id INTEGER NOT NULL,
manager_name VARCHAR(64) NOT NULL, 
manager_contact INTEGER NOT NULL,
PRIMARY KEY (manager_id), 
FOREIGN KEY(employee_id) REFERENCES Employee_details(employee_id)
);

CREATE TABLE PriceChange (
PriceChangeID DECIMAL(12) NOT NULL PRIMARY KEY,
OldPrice DECIMAL(8,2) NOT NULL,
NewPrice DECIMAL(8,2) NOT NULL,
Product_id INTEGER NOT NULL,
ChangeDate DATE NOT NULL,
FOREIGN KEY (Product_id) REFERENCES Product(product_id));



--SEQUENCES
CREATE SEQUENCE product_seq START WITH 1;
CREATE SEQUENCE inventory_seq START WITH 1;
CREATE SEQUENCE supplier_seq START WITH 1;
CREATE SEQUENCE customer_seq START WITH 1;
CREATE SEQUENCE order_seq START WITH 1;
CREATE SEQUENCE order_item_seq START WITH 1;
CREATE SEQUENCE employee_details_seq START WITH 1;
CREATE SEQUENCE employee_assignment_seq START WITH 1;
CREATE SEQUENCE manager_details_seq START WITH 1; 
CREATE SEQUENCE PriceChangeSeq START WITH 1;
--INDEXES
CREATE INDEX order_id_idx
ON OrderItem(order_id);

CREATE INDEX product_id_idx
ON OrderItem(product_id);

CREATE INDEX inventory_id_idx
ON Inventory(product_id);

CREATE INDEX supplier_product_id_idx
ON Supplier(product_id);

CREATE INDEX customer_id_idx
ON Order1(customer_id);

CREATE INDEX order_product_id_idx
ON Order1(product_id);

CREATE INDEX employee_order_id_idx
ON Employee_assignment(order_id);

CREATE INDEX employee_id_idx
ON Employee_assignment(employee_id);

CREATE INDEX manager_employee_id_idx
ON Manager_details(employee_id);



--STORED PROCEDURES
CREATE OR REPLACE PROCEDURE AddProduct(
    product_name IN VARCHAR(64),
    price IN DECIMAL(10, 2)
)
AS
$proc$
BEGIN
    INSERT INTO Product (product_id, product_name, Price)
    VALUES (nextval('product_seq'), product_name, price);
END;
$proc$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddInventory(
    product_id IN INTEGER,
    stock_level IN INTEGER
)
AS
$proc$
BEGIN
    INSERT INTO Inventory (product_id, stock_level)
    VALUES (product_id, stock_level);
END;
$proc$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddSupplier(
    supplier_name IN VARCHAR(64),
    product_id IN INTEGER,
    quantity IN INTEGER
)
AS
$proc$
BEGIN
    INSERT INTO Supplier (supplier_id, supplier_name, product_id, quantity)
    VALUES (nextval('supplier_seq'), supplier_name, product_id, quantity);
END;
$proc$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddCustomer(
    customer_name IN VARCHAR(64),
    customer_contact IN INTEGER,
    purchase_history IN VARCHAR(64)
)
AS
$proc$
BEGIN
    INSERT INTO Customer1 (customer_id, customer_name, customer_contact, purchase_history)
    VALUES (nextval('customer_seq'), customer_name, customer_contact, purchase_history);
END;
$proc$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddOrder(
    customer_id IN INTEGER,
    product_id IN INTEGER,
    order_date IN DATE,
    order_status IN VARCHAR(15)
)
AS
$proc$
BEGIN
    INSERT INTO Order1 (order_id, customer_id, product_id, order_date, order_status)
    VALUES (nextval('order_seq'), customer_id, product_id, order_date, order_status);
END;
$proc$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddOrderItem(
    order_id IN INTEGER,
    product_id IN INTEGER,
    quantity IN INTEGER
)
AS
$proc$
BEGIN
    INSERT INTO OrderItem (order_item_id, order_id, product_id, quantity)
    VALUES (nextval('order_item_seq'), order_id, product_id, quantity);
END;
$proc$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddEmployeeDetails(
    employee_name IN VARCHAR(64),
    employee_contact IN INTEGER,
    employee_position IN VARCHAR(64)
)
AS
$proc$
BEGIN
    INSERT INTO Employee_details (employee_id, employee_name, employee_contact, employee_position)
    VALUES (nextval('employee_details_seq'), employee_name, employee_contact, employee_position);
END;
$proc$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AssignEmployee(
    employee_id IN INTEGER,
    order_id IN INTEGER
)
AS
$proc$
BEGIN
    INSERT INTO Employee_assignment (assignment_id, employee_id, order_id)
    VALUES (nextval('employee_assignment_seq'), employee_id, order_id);
END;
$proc$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddManagerDetails(
	employee_id IN INTEGER,
    maneger_name IN VARCHAR(64),
    manager_contact IN INTEGER
)
AS
$proc$
BEGIN
    INSERT INTO Manager_details (manager_id, employee_id, manager_name, manager_contact)
    VALUES (nextval('manager_details_seq'), employee_id, manager_name, manager_contact);
END;
$proc$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION ProductPriceChangeFunction()
RETURNS TRIGGER LANGUAGE plpgsql
AS $trigfunc$
BEGIN
    INSERT INTO PriceChange(PriceChangeID, OldPrice, NewPrice, Product_id, ChangeDate)
	VALUES(nextval('PriceChangeSeq'), 
	OLD.Price, 
	NEW.Price, 
	New.Product_id,
	current_date);
RETURN NEW;
END;
$trigfunc$;

CREATE TRIGGER ProductPriceChangeTrigger
BEFORE UPDATE OF Price ON Product
FOR EACH ROW
EXECUTE PROCEDURE ProductPriceChangeFunction();



--TRIGGERS
--Replace this with your history table trigger.

--INSERTS
START TRANSACTION;
DO
$$BEGIN
    CALL AddProduct('Lipstick', 16);
    CALL AddProduct('Foundation', 32);
    CALL AddProduct('Mascara', 12);
END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
$$BEGIN
    CALL AddInventory(1, 25); 
    CALL AddInventory(2, 30); 
    CALL AddInventory(3, 15); 
END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
$$BEGIN
    CALL AddSupplier('Supplier1', 1, 100); 
    CALL AddSupplier('Supplier2', 2, 200); 
    CALL AddSupplier('Supplier3', 3, 150); 
END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
$$BEGIN
    CALL AddSupplier('Supplier A', 1, 100); 
    CALL AddSupplier('Supplier B', 2, 200); 
    CALL AddSupplier('Supplier C', 3, 150); 
END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
$$BEGIN
    CALL AddCustomer('Sevanthi', 569, 'Lipstick');
    CALL AddCustomer('Sujan', 607, 'Mascara');
END$$;
COMMIT TRANSACTION;


START TRANSACTION;
DO
$$BEGIN
    CALL AddOrder(1, 1, '2024-12-01', 'Shipped'); 
    CALL AddOrder(2, 2, '2024-12-02', 'Processing'); 
END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
$$BEGIN
    CALL AddOrderItem(1, 1, 2);
    CALL AddOrderItem(2, 2, 1);
END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
$$BEGIN
    CALL AddEmployeeDetails('Niharika', 794, 'Sales Executive');
    CALL AddEmployeeDetails('Suhas', 853, 'Sales Executive');
END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
$$BEGIN
    CALL AssignEmployee(1, 1); 
    CALL AssignEmployee(2, 2); 
END$$;
COMMIT TRANSACTION;


--QUERIES
SELECT p.product_name, i.stock_level
FROM Inventory i
JOIN Product p ON i.product_id = p.product_id
WHERE i.stock_level < 20;


SELECT e.employee_name, o.order_id
FROM Employee_assignment ea
JOIN Employee_details e ON ea.employee_id = e.employee_id
JOIN Order1 o ON ea.order_id = o.order_id;


SELECT p.product_name, COUNT(o.order_id) AS total_orders
FROM Product p
JOIN ORDER1 o ON p.product_id = o.product_id
GROUP BY p.product_name;

SELECT * FROM Product WHERE product_id = 1;

SELECT * FROM PriceChange;

UPDATE Product
SET Price = 20
WHERE product_id = 1;

SELECT * FROM PriceChange;
