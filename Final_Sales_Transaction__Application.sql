--table Product creation
CREATE TABLE Product (
    ProductId INT PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
	Price DECIMAL(10, 2),
    RemainingQuantity INT NOT NULL,
	YearBought INT,
    CONSTRAINT UQ_ProductName UNIQUE (ProductName)
);

--table Customer creation
CREATE TABLE Customer (
    CustomerId INT PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_CustomerName UNIQUE (CustomerName)
);

--table SalesTransaction creation
CREATE TABLE SalesTransaction (
    TransactionId INT PRIMARY KEY,
    CustomerId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    TransactionDate DATE NOT NULL,
    InvoiceId INT,
    CONSTRAINT FK_SalesTransaction_Customer FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId),
    CONSTRAINT FK_SalesTransaction_Product FOREIGN KEY (ProductId) REFERENCES Product (ProductId),
    CONSTRAINT UQ_SalesTransaction_InvoiceId UNIQUE (InvoiceId),
    CONSTRAINT CHK_SalesTransaction_Quantity CHECK (Quantity > 0)
);

-- table Invoice creation
CREATE TABLE Invoice (
    InvoiceId INT PRIMARY KEY,
    CustomerId INT NOT NULL,
    InvoiceDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    CONSTRAINT FK_Invoice_Customer FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId)
);


--1) Stored Procedures (SP)
--i)

-- SP for Product Table
CREATE PROCEDURE ManageProduct
    @Operation VARCHAR(10),
    @ProductData NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        IF @Operation = 'Create'
        BEGIN
            INSERT INTO Product (ProductId, ProductName, Price, RemainingQuantity, YearBought)
            SELECT JSON_VALUE(@ProductData, '$.ProductId'),
                   JSON_VALUE(@ProductData, '$.ProductName'),
                   JSON_VALUE(@ProductData, '$.Price'),
                   JSON_VALUE(@ProductData, '$.RemainingQuantity'),
                   JSON_VALUE(@ProductData, '$.YearBought')
        END
        ELSE IF @Operation = 'Read'
        BEGIN
            SELECT ProductId, ProductName, Price, RemainingQuantity, YearBought
            FROM Product
            WHERE ProductId = JSON_VALUE(@ProductData, '$.ProductId')
        END
        ELSE IF @Operation = 'Update'
        BEGIN
            UPDATE Product
            SET ProductName = JSON_VALUE(@ProductData, '$.ProductName'),
                Price = JSON_VALUE(@ProductData, '$.Price'),
                RemainingQuantity = JSON_VALUE(@ProductData, '$.RemainingQuantity'),
                YearBought = JSON_VALUE(@ProductData, '$.YearBought')
            WHERE ProductId = JSON_VALUE(@ProductData, '$.ProductId')
        END
        ELSE IF @Operation = 'Delete'
        BEGIN
            DELETE FROM Product
            WHERE ProductId = JSON_VALUE(@ProductData, '$.ProductId')
        END

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
    END CATCH
END

-- Executing SP for Product
DECLARE @CreateProductData NVARCHAR(MAX)
SET @CreateProductData = '{"ProductId": 5, "ProductName": "E", "Price": 212.00, "RemainingQuantity": 1, "YearBought": 2022}'

EXEC ManageProduct @Operation = 'Create', @ProductData = @CreateProductData


DECLARE @ReadProductData NVARCHAR(MAX)
SET @ReadProductData = '{"ProductId": 1}'

EXEC ManageProduct @Operation = 'Read', @ProductData = @ReadProductData


DECLARE @UpdateProductData NVARCHAR(MAX)
SET @UpdateProductData = '{"ProductId": 1, "ProductName": "Updated A", "Price": 15.00, "RemainingQuantity": 15, "YearBought": 2021}'

EXEC ManageProduct @Operation = 'Update', @ProductData = @UpdateProductData


DECLARE @DeleteProductData NVARCHAR(MAX)
SET @DeleteProductData = '{"ProductId": 1}'

EXEC ManageProduct @Operation = 'Delete', @ProductData = @DeleteProductData


--Creating SP for Customer
CREATE PROCEDURE ManageCustomer
    @Operation VARCHAR(10),
    @CustomerData NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Operation = 'Create'
        BEGIN
            INSERT INTO Customer (CustomerId, CustomerName)
            SELECT JSON_VALUE(@CustomerData, '$.CustomerId'),
                   JSON_VALUE(@CustomerData, '$.CustomerName');
        END
        ELSE IF @Operation = 'Read'
        BEGIN
            SELECT CustomerId, CustomerName
            FROM Customer
            WHERE CustomerId = JSON_VALUE(@CustomerData, '$.CustomerId');
        END
        ELSE IF @Operation = 'Update'
        BEGIN
            UPDATE Customer
            SET CustomerName = JSON_VALUE(@CustomerData, '$.CustomerName')
            WHERE CustomerId = JSON_VALUE(@CustomerData, '$.CustomerId');
        END
        ELSE IF @Operation = 'Delete'
        BEGIN
            DELETE FROM Customer
            WHERE CustomerId = JSON_VALUE(@CustomerData, '$.CustomerId');
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;

--Executing SP for Customer
DECLARE @CreateCustomerData NVARCHAR(MAX);
SET @CreateCustomerData = '{"CustomerId": 6, "CustomerName": "Birkhas"}';

EXEC ManageCustomer @Operation = 'Create', @CustomerData = @CreateCustomerData;


DECLARE @ReadCustomerData NVARCHAR(MAX)
SET @ReadCustomerData = '{"CustomerId": 1}'

EXEC ManageCustomer @Operation = 'Read', @CustomerData = @ReadCustomerData


DECLARE @UpdateCustomerData NVARCHAR(MAX)
SET @UpdateCustomerData = '{"CustomerId": 1, "CustomerName": "Bijay Basnet"}'

EXEC ManageCustomer @Operation = 'Update', @CustomerData = @UpdateCustomerData


DECLARE @DeletecustomerData NVARCHAR(MAX)
SET @DeleteCustomerData = '{"CustomerId": 1}'

EXEC ManageCustomer @Operation = 'Delete', @CustomerData = @DeleteCustomerData


--creating SP for SalesTransaction
CREATE PROCEDURE ManageSalesTransaction
    @Operation VARCHAR(10),
    @TransactionData NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Operation = 'Create'
        BEGIN
            INSERT INTO SalesTransaction (TransactionId, CustomerId, ProductId, Quantity, TransactionDate, InvoiceId)
            SELECT JSON_VALUE(@TransactionData, '$.TransactionId'),
                   JSON_VALUE(@TransactionData, '$.CustomerId'),
                   JSON_VALUE(@TransactionData, '$.ProductId'),
                   JSON_VALUE(@TransactionData, '$.Quantity'),
                   JSON_VALUE(@TransactionData, '$.TransactionDate'),
                   JSON_VALUE(@TransactionData, '$.InvoiceId');
        END
        ELSE IF @Operation = 'Read'
        BEGIN
            SELECT TransactionId, CustomerId, ProductId, Quantity, TransactionDate, InvoiceId
            FROM SalesTransaction
            WHERE TransactionId = JSON_VALUE(@TransactionData, '$.TransactionId');
        END
        ELSE IF @Operation = 'Update'
        BEGIN
            UPDATE SalesTransaction
            SET CustomerId = JSON_VALUE(@TransactionData, '$.CustomerId'),
                ProductId = JSON_VALUE(@TransactionData, '$.ProductId'),
                Quantity = JSON_VALUE(@TransactionData, '$.Quantity'),
                TransactionDate = JSON_VALUE(@TransactionData, '$.TransactionDate'),
                InvoiceId = JSON_VALUE(@TransactionData, '$.InvoiceId')
            WHERE TransactionId = JSON_VALUE(@TransactionData, '$.TransactionId');
        END
        ELSE IF @Operation = 'Delete'
        BEGIN
            DELETE FROM SalesTransaction
            WHERE TransactionId = JSON_VALUE(@TransactionData, '$.TransactionId');
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;

--Executing SP for SalesTransaction
DECLARE @CreateTransactionData NVARCHAR(MAX);
SET @CreateTransactionData = '{"TransactionId": 6, "CustomerId": 5, "ProductId": 3, "Quantity": 1, "TransactionDate": "2023-05-13", "InvoiceId": 2004}';

EXEC ManageSalesTransaction @Operation = 'Create', @TransactionData = @CreateTransactionData;


DECLARE @ReadTransactionData NVARCHAR(MAX);
SET @ReadTransactionData = '{"TransactionId": 1}';

EXEC ManageSalesTransaction @Operation = 'Read', @TransactionData = @ReadTransactionData;


DECLARE @UpdateTransactionData NVARCHAR(MAX);
SET @UpdateTransactionData = '{"TransactionId": 1, "CustomerId": 2, "ProductId": 1, "Quantity": 50, "TransactionDate": "2023-05-17", "InvoiceId": 1002}';

EXEC ManageSalesTransaction @Operation = 'Update', @TransactionData = @UpdateTransactionData;


DECLARE @DeleteTransactionData NVARCHAR(MAX);
SET @DeleteTransactionData = '{"TransactionId": 1}';

EXEC ManageSalesTransaction @Operation = 'Delete', @TransactionData = @DeleteTransactionData;


--Creating SP for Invoice
CREATE PROCEDURE ManageInvoice
    @Operation VARCHAR(10),
    @InvoiceData NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Operation = 'Create'
        BEGIN
            INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, TotalAmount)
            SELECT JSON_VALUE(@InvoiceData, '$.InvoiceId'),
                   JSON_VALUE(@InvoiceData, '$.CustomerId'),
                   JSON_VALUE(@InvoiceData, '$.InvoiceDate'),
                   JSON_VALUE(@InvoiceData, '$.TotalAmount');
        END
        ELSE IF @Operation = 'Read'
        BEGIN
            SELECT InvoiceId, CustomerId, InvoiceDate, TotalAmount
            FROM Invoice
            WHERE InvoiceId = JSON_VALUE(@InvoiceData, '$.InvoiceId');
        END
        ELSE IF @Operation = 'Update'
        BEGIN
            UPDATE Invoice
            SET CustomerId = JSON_VALUE(@InvoiceData, '$.CustomerId'),
                InvoiceDate = JSON_VALUE(@InvoiceData, '$.InvoiceDate'),
                TotalAmount = JSON_VALUE(@InvoiceData, '$.TotalAmount')
            WHERE InvoiceId = JSON_VALUE(@InvoiceData, '$.InvoiceId');
        END
        ELSE IF @Operation = 'Delete'
        BEGIN
            DELETE FROM Invoice
            WHERE InvoiceId = JSON_VALUE(@InvoiceData, '$.InvoiceId');
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;

--Executing SP for Invoice
DECLARE @CreateInvoiceData NVARCHAR(MAX);
SET @CreateInvoiceData = '{"InvoiceId": 1001, "CustomerId": 1, "InvoiceDate": "2023-05-10", "TotalAmount": 10000.50}';

EXEC ManageInvoice @Operation = 'Create', @InvoiceData = @CreateInvoiceData;


DECLARE @ReadInvoiceData NVARCHAR(MAX);
SET @ReadInvoiceData = '{"InvoiceId": 1001}';

EXEC ManageInvoice @Operation = 'Read', @InvoiceData = @ReadInvoiceData;


DECLARE @UpdateInvoiceData NVARCHAR(MAX);
SET @UpdateInvoiceData = '{"InvoiceId": 1001, "CustomerId": 2, "InvoiceDate": "2023-05-17", "TotalAmount": 150.75}';

EXEC ManageInvoice @Operation = 'Update', @InvoiceData = @UpdateInvoiceData;


DECLARE @DeleteInvoiceData NVARCHAR(MAX);
SET @DeleteInvoiceData = '{"InvoiceId": 1002}';

EXEC ManageInvoice @Operation = 'Delete', @InvoiceData = @DeleteInvoiceData;


--ii)
--creating SP to generate Invoice
CREATE PROCEDURE GenerateInvoice
    @CustomerData NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @CustomerId INT;
    SELECT @CustomerId = JSON_VALUE(@CustomerData, '$.CustomerId');
    -- Calculating total amount for the invoice
    DECLARE @TotalAmount DECIMAL(10, 2);
    SELECT @TotalAmount = SUM(P.Price * ST.Quantity)
    FROM SalesTransaction ST
    JOIN Product P ON ST.ProductId = P.ProductId
    WHERE ST.CustomerId = @CustomerId;
    -- Calculating the discount
    DECLARE @Discount DECIMAL(4, 2);
    IF (@TotalAmount <= 1000)
        SET @Discount = 0.05;
    ELSE
        SET @Discount = 0.1;
    -- Applying the discount to the total amount
    SET @TotalAmount = @TotalAmount - (@TotalAmount * @Discount);
    -- Generating a unique invoice ID
    DECLARE @InvoiceId INT;
    SELECT @InvoiceId = ISNULL(MAX(InvoiceId), 0) + 1
    FROM Invoice;
    IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerId = @CustomerId)
    BEGIN
        INSERT INTO Customer (CustomerId)
        VALUES (@CustomerId);
    END;
    INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, TotalAmount)
    VALUES (@InvoiceId, @CustomerId, GETDATE(), @TotalAmount);
    UPDATE SalesTransaction
    SET InvoiceId = @InvoiceId
    WHERE CustomerId = @CustomerId;
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    COMMIT TRANSACTION;
    SELECT * FROM Invoice WHERE InvoiceId = @InvoiceId;
END;

--executing SP for Generate Invoice
DECLARE @CustomerDatatest NVARCHAR(MAX);
SET @CustomerDatatest = '{"CustomerId": 5}';

EXEC GenerateInvoice @CustomerData = @CustomerDatatest;


--3)
--List of customers whose name starts with the letter "A" or ends with the letter "S" but should have the letter "K".
SELECT CustomerName
FROM Customer
WHERE (CustomerName LIKE 'A%' OR CustomerName LIKE '%S') AND CustomerName LIKE '%K%';

--Customers whose invoice is not processed yet.
SELECT C.CustomerName
FROM Customer C
LEFT JOIN Invoice I ON C.CustomerId = I.CustomerId
WHERE I.InvoiceId IS NULL;

--Name of customer who has spent highest amount in a specific date range.
SELECT TOP 1 C.CustomerName
FROM Customer C
INNER JOIN Invoice I ON C.CustomerId = I.CustomerId
WHERE I.InvoiceDate BETWEEN '2023-05-11' AND '2023-05-25'
ORDER BY I.TotalAmount DESC;

--Remove the product which is not bought in the current year.
DELETE FROM Product
WHERE ProductId IN (
    SELECT p.ProductId
    FROM Product p
    LEFT JOIN SalesTransaction st ON p.ProductId = st.ProductId
    WHERE st.ProductId IS NULL OR YEAR(st.TransactionDate) <> YEAR(GETDATE())
);

--creating trigger to manage remaining quantity of the product
CREATE TRIGGER UpdateRemainingQuantity
ON SalesTransaction
AFTER INSERT, UPDATE
AS
BEGIN
    -- Checking if the inserted or updated quantity exceeds the remaining quantity
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Product p ON i.ProductId = p.ProductId
        WHERE i.Quantity > p.RemainingQuantity
    )
    BEGIN
        RAISERROR ('The quantity exceeds the remaining quantity for the product.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Updating the remaining quantity for the affected products
    UPDATE Product
    SET RemainingQuantity = RemainingQuantity - (SELECT SUM(Quantity)
                                                 FROM inserted
                                                 WHERE ProductId = Product.ProductId)
    WHERE ProductId IN (SELECT DISTINCT ProductId FROM inserted);
END;

--The product should have a remaining column which shows the remaining quantity of the product. This should be updated on the basis of sales transactions. List out the products whose remaining quantity is less than 2. 
SELECT *
FROM Product
WHERE RemainingQuantity < 2;

--Get the product of the year (The product that was bought by maximum customers this year.) 
SELECT TOP 1 p.ProductId, p.ProductName, COUNT(DISTINCT st.CustomerId) AS CustomerCount
FROM Product p
JOIN SalesTransaction st ON p.ProductId = st.ProductId
WHERE YEAR(st.TransactionDate) = YEAR(GETDATE())
GROUP BY p.ProductId, p.ProductName
ORDER BY CustomerCount DESC;

--Return the list of customers who bought more than 10 products.
SELECT c.CustomerId, c.CustomerName
FROM Customer c
JOIN (
    SELECT CustomerId, COUNT(*) AS ProductCount
    FROM SalesTransaction
    GROUP BY CustomerId
    HAVING COUNT(*) > 10
) t ON c.CustomerId = t.CustomerId;


--4)
CREATE FUNCTION GetTotalBillAmount
(
    @CustomerJson NVARCHAR(MAX),
    @StartDate DATE,
    @EndDate DATE
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @CustomerIds TABLE (CustomerId INT);
    INSERT INTO @CustomerIds
    SELECT CAST(value AS INT)
    FROM OPENJSON(@CustomerJson);

    DECLARE @Result TABLE (CustomerId INT, TotalBillAmount DECIMAL(10, 2));

    INSERT INTO @Result (CustomerId, TotalBillAmount)
    SELECT st.CustomerId, SUM(st.Quantity * p.Price) AS TotalAmount
    FROM SalesTransaction st
    INNER JOIN Product p ON st.ProductId = p.ProductId
    WHERE st.CustomerId IN (SELECT CustomerId FROM @CustomerIds)
    AND st.TransactionDate >= @StartDate AND st.TransactionDate <= @EndDate
    GROUP BY st.CustomerId;

    -- returning the result as JSON
    RETURN (
        SELECT CustomerId, TotalBillAmount
        FROM @Result
        FOR JSON PATH
    );
END;

DECLARE @CustomerJson NVARCHAR(MAX) = '[1, 2]';
DECLARE @StartDate DATE = '2023-05-01';
DECLARE @EndDate DATE = '2023-05-15';

DECLARE @ResultJson NVARCHAR(MAX);

SET @ResultJson = dbo.GetTotalBillAmount(@CustomerJson, @StartDate, @EndDate);

SELECT @ResultJson AS Result;


--5)
CREATE PROCEDURE GetCustomerInformation
    @DateRange NVARCHAR(MAX),
    @CustomerId INT = NULL
AS
BEGIN
    DECLARE @StartDate DATE, @EndDate DATE

    SELECT @StartDate = JSON_VALUE(@DateRange, '$.startDate'),
           @EndDate = JSON_VALUE(@DateRange, '$.endDate')

    DECLARE @Result NVARCHAR(MAX)

    SET @Result = 
        'SELECT C.CustomerId, C.CustomerName, SUM(I.TotalAmount) AS TotalInvoiceAmount
        FROM Customer C
        JOIN Invoice I ON C.CustomerId = I.CustomerId
        WHERE I.InvoiceDate >= ' + QUOTENAME(@StartDate, '''') + '
        AND I.InvoiceDate <= ' + QUOTENAME(@EndDate, '''')
    
    IF @CustomerId IS NOT NULL
        SET @Result = @Result + ' AND C.CustomerId = ' + CONVERT(NVARCHAR, @CustomerId)
    ELSE
        SET @Result = @Result + ' GROUP BY C.CustomerId, C.CustomerName'

    SET @Result = (
        SELECT C.CustomerId, C.CustomerName, SUM(I.TotalAmount) AS TotalInvoiceAmount
        FROM Customer C
        JOIN Invoice I ON C.CustomerId = I.CustomerId
        WHERE I.InvoiceDate >= @StartDate
        AND I.InvoiceDate <= @EndDate
        AND (C.CustomerId = @CustomerId OR @CustomerId IS NULL)
        GROUP BY C.CustomerId, C.CustomerName
        FOR JSON AUTO
    )

    SELECT @Result AS Result
END

--executing SP for customer information
DECLARE @DateRangetest NVARCHAR(MAX)
DECLARE @CustomerIdtest INT

SET @DateRangetest = '{"startDate": "2023-01-01", "endDate": "2023-05-31"}'
SET @CustomerIdtest = 5

EXEC GetCustomerInformation @DateRangetest, @CustomerIdtest




