-- CC_W2024_Prog8081_sec3_Jaanvi_Jaanvi_Zainab_el_Bukhatwa_Youyuan_Zhang_Ravi_Jha_Marina_Paskal_April_8_2024.sql
-- Winter 2024 Mini Project
-- Revision History:
-- Jaanvi Jaanvi, Section 3, 2024.04.7: Created
-- Jaanvi Jaanvi, Zainab el Bukhatwa, Youyuan Zhang, Ravi Jha (Observer), Marina Paskal, Section 3, 2024.04.8: Updated

Print 'PROG8081 Section 3'; Print 
'Mini Project SWC_DB';
Print '';
Print 'Jaanvi Jaanvi, Zainab el Bukhatwa, Youyuan Zhang, Ravi Jha (Observer), Marina Paskal'; 
Print '';
Print GETDATE();
Print '';

USE master;
GO

Print '*** Create SWC_DB ***';
Print 'Remove SWC_DB if it exists. Create SWC_DB.';
IF EXISTS (
    SELECT * FROM sys.databases WHERE name = 'SWC_DB'
)
BEGIN
    USE master;
    ALTER DATABASE SWC_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SWC_DB;
END
GO

Print '*** Create new SWC_DB ***';
CREATE DATABASE SWC_DB;
GO

Print '*** Us SWC_DB ***';
USE SWC_DB;
GO

Print '*** Create PartTypes table ***';
CREATE TABLE PartTypes (
    PartTypeID INT IDENTITY(1,1) PRIMARY KEY,
    PartTypeName VARCHAR(50) NOT NULL UNIQUE
);
GO

Print '*** Create BundleBrand table ***';
CREATE TABLE BundleBrand (
    BundleBrandID INT IDENTITY(1,1) PRIMARY KEY,
    BundleBrandName VARCHAR(50) NOT NULL UNIQUe 
);
GO

Print '*** Create BundleType table ***';
CREATE TABLE BundleType (
    BundleTypeID INT IDENTITY(1,1) PRIMARY KEY,
    BundleTypeName VARCHAR(50) NOT NULL UNIQUE
);
GO

Print '*** Create Suppliers table ***';
CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName VARCHAR(120) NOT NULL UNIQUE
);
GO

Print '*** Create Bundles table ***';
CREATE TABLE Bundles (
    BundleID INT IDENTITY(1,1) PRIMARY KEY,
    BundleTypeID INT NOT NULL FOREIGN KEY REFERENCES BundleType(BundleTypeID),
    BundleBrandID INT NOT NULL FOREIGN KEY REFERENCES BundleBrand(BundleBrandID),
    BundleDiscount DECIMAL(10, 2) NOT NULL
);
GO

Print '*** Create Parts table ***';
CREATE TABLE Parts (
    PartID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL FOREIGN KEY REFERENCES Suppliers(SupplierID),
    PartTypeID INT NOT NULL FOREIGN KEY REFERENCES PartTypes(PartTypeID),
    PartNumber VARCHAR(100) NOT NULL UNIQUE,
    PartDescription VARCHAR(255) NOT NULL CHECK (LEN(PartDescription) >= 3),
    PartUnitPrice DECIMAL(10, 2) NOT NULL CHECK (PartUnitPrice >= 0)
);
GO

Print '*** Create Purchasers table ***';
CREATE TABLE Purchasers (
    PurchaserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL CHECK (LEN(FirstName) >= 3),
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    StreetNumber VARCHAR(20) NOT NULL,
    StreetName VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    Province VARCHAR(50) NOT NULL,
    Country VARCHAR(50) DEFAULT 'Canada',
    PostalCode VARCHAR(20) NOT NULL,
    Phone VARCHAR(20) NOT NULL CHECK (LEN(Phone) = 10)
);
CREATE INDEX IDX_Phone ON Purchasers(Phone); -- Index for Performance
CREATE UNIQUE INDEX IDX_Email ON Purchasers(Email); -- Create unique index for the purchaser's email
GO

Print '*** Create Purchases table ***';
CREATE TABLE Purchases (
    PurchaseID INT IDENTITY(1,1),
    PurchaserID INT NOT NULL,
    PartID INT NULL,
    BundleID INT NULL,
    PurchaseDate DATE NOT NULL,
    Qty INT NOT NULL CHECK (Qty > 0),
     FOREIGN KEY (PurchaserID) REFERENCES Purchasers(PurchaserID),
    FOREIGN KEY (PartID) REFERENCES Parts(PartID),
    FOREIGN KEY (BundleID) REFERENCES Bundles(BundleID),
    CONSTRAINT CHK_PartOrBundle 
        CHECK ((PartID IS NULL AND BundleID IS NOT NULL) OR (PartID IS NOT NULL AND BundleID IS NULL))
);
GO

Print '*** Create BundleParts table ***';
CREATE TABLE BundleParts (
    BundleID INT NOT NULL FOREIGN KEY REFERENCES Bundles(BundleID),
    PartID INT NOT NULL FOREIGN KEY REFERENCES Parts(PartID),
    CONSTRAINT CK_BundleParts PRIMARY KEY (BundleID, PartID) -- Define composite key constraint
);
GO

Print '*** Create Notification table';
CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    NotificationDate DATETIME2 DEFAULT GETDATE(),
    Message VARCHAR(255)
);
GO

Print '*** Insert data into SWC_DB ***';
Print 'Insert Data into BundleType table.';
INSERT INTO BundleType (BundleTypeName)
VALUES ('Biz'), ('Eco');
GO

Print 'Insert Data into BundleBrand table.';
INSERT INTO BundleBrand (BundleBrandName)
VALUES ('Dell'), ('HP');
GO

Print 'Insert Data into PartTypes table.';
INSERT INTO PartTypes (PartTypeName)
VALUES 
('Desktop'), 
('Monitor'), 
('Tablet'), 
('Keyboard'), 
('Mouse'), 
('Camera');
GO

Print 'Insert Data into Suppliers table.';
INSERT INTO Suppliers (SupplierName) VALUES 
('Dell'), 
('HP'), 
('Samsung'), 
('Lenovo'), 
('Max');
GO

Print 'Insert Data into Purchaser table.';
INSERT INTO Purchasers (FirstName, LastName, Email, StreetNumber, StreetName, City, Province, Country, PostalCode, Phone)
VALUES
('Joey', 'Lastname', 'joey@example.com', '123', 'Main St', 'City', 'Province', 'Canada', 'A1B2C3', '1234567890'),
('May', 'Lastname', 'may@example.com', '456', 'Elm St', 'City', 'Province', 'Canada', 'X1Y2Z3', '9876543210'),
('Troy', 'Lastname', 'troy@example.com', '789', 'Oak St', 'City', 'Province', 'Canada', 'M1N2O3', '4567890123'),
('Vinh', 'Lastname', 'vinh@example.com', '101', 'Maple St', 'City', 'Province', 'Canada', 'P4Q5R6', '7890123456');
GO

Print 'Insert Data into Bundles table.';
INSERT INTO Bundles (BundleTypeID, BundleBrandID, BundleDiscount) VALUES 
((SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Eco'), (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'Dell'), 0.10),
((SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Biz'), (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'HP'), 0.15),
((SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Eco'), (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'Dell'), 0),
((SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Biz'), (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'HP'), 0),
((SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Biz'), (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'Dell'), 1.00),
((SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Eco'), (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'HP'), 0.50),
((SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Biz'), (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'Dell'), 0),
((SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Eco'), (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'HP'), 0);
GO

Print 'Insert Data into Parts table.';
INSERT INTO Parts (SupplierID, PartTypeID, PartNumber, PartDescription, PartUnitPrice)
VALUES
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'Dell'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Desktop'), 'DL1010', 'Dell Optiplex 1010', 40.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'Dell'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Desktop'), 'DL5040', 'Dell Optiplex 5040', 150.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'Dell'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Monitor'), 'DLM190', 'Dell 19-inch Monitor', 35.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'HP'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Desktop'), 'HP400', 'HP Desktop Tower', 60.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'HP'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Desktop'), 'HP800', 'HP EliteDesk 800G1', 200.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'HP'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Monitor'), 'HPM270', 'HP 27-inch Monitor', 120.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'Samsung'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Tablet'), 'SM330', '7” Android Tablet', 110.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'Lenovo'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Keyboard'), 'LEN101', 'Computer Keyboard', 7.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'Lenovo'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Mouse'), 'LEN102', 'Lenovo Mouse', 5.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'Dell'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Monitor'), 'DLM240', 'Dell 24-inch Monitor', 80.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'HP'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Monitor'), 'HPM220', 'HP 22-inch Monitor', 45.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'Max'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Camera'), 'MAX901', 'Max Web Camera', 20.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'HP'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Keyboard'), 'HP501', 'Computer Keyboard', 9.00),
((SELECT SupplierID FROM Suppliers WHERE SupplierName = 'HP'), (SELECT PartTypeID FROM PartTypes WHERE PartTypeName = 'Mouse'), 'HP502', 'HP Mouse', 6.00);
(SELECT BundleID FROM Bundles WHERE BundleTypeID = 1 AND BundleBrandID = 1);
(SELECT PartID FROM Parts WHERE PartNumber = 'DL1010');
(SELECT PartID FROM Parts WHERE PartNumber = 'DLM190');
(SELECT BundleID FROM Bundles WHERE BundleTypeID = 2 AND BundleBrandID = 2);
(SELECT PartID FROM Parts WHERE PartNumber = 'HP800');
(SELECT PartID FROM Parts WHERE PartNumber = 'HPM270');
GO

Print 'Prepare Data for Purchases table.';
WITH PurchaseData AS (
    SELECT 'DL1010' AS PartNumber, 'Dell' AS Supplier, 'Desktop' AS PartType, 'Dell Optiplex 1010' AS PartDescription, 'Joey' AS Purchaser, 'Eco' AS BundleType, 'Dell' AS BundleBrand, '2022-10-31' AS PurchaseDate, 40.00 AS PartPrice, 25 AS Qty UNION ALL
    SELECT 'DL5040', 'Dell', 'Desktop', 'Dell Optiplex 5040', 'Joey', 'Biz', 'Dell', '2022-10-31', 150.00, 50 UNION ALL
    SELECT 'DLM190', 'Dell', 'Monitor', 'Dell 19-inch Monitor', 'Joey', 'Eco', 'Dell', '2022-10-31', 35.00, 25 UNION ALL
    SELECT 'HP400', 'HP', 'Desktop', 'HP Desktop Tower', 'May', 'Eco', 'HP', '2022-11-10', 60.00, 15 UNION ALL
    SELECT 'HP800', 'HP', 'Desktop', 'HP EliteDesk 800G1', 'May', 'Biz', 'HP', '2022-11-20', 200.00, 20 UNION ALL
    SELECT 'HPM270', 'HP', 'Monitor', 'HP 27-inch Monitor', 'May', 'Biz', 'HP', '2022-11-20', 120.00, 20 UNION ALL
    SELECT 'SM330', 'Samsung', 'Tablet', 'Samsung Galaxy Tab 7'' Android Tablet', 'Troy', NULL, NULL, '2022-11-30', 110.00, 10 UNION ALL
    SELECT 'LEN101', 'Lenovo', 'Keyboard', 'Lenovo 101-Key Computer Keyboard', 'Vinh', 'Eco', 'Dell', '2022-11-05', 7.00, 25 UNION ALL
    SELECT 'LEN101', 'Lenovo', 'Keyboard', 'Lenovo 101-Key Computer Keyboard', 'Vinh', 'Biz', 'Dell', '2022-11-05', 7.00, 25 UNION ALL
	SELECT 'LEN102', 'Lenovo', 'Mouse', 'Lenovo Mouse', 'Vinh', 'Biz', 'Dell', '2022-12-05', 5.00, 25 UNION ALL
    SELECT 'LEN102', 'Lenovo', 'Mouse', 'Lenovo Mouse', 'Vinh', 'Eco', 'Dell', '2022-12-05', 5.00, 25 UNION ALL
	SELECT 'DLM240', 'Dell', 'Monitor', 'Dell 24-inch Monitor', 'Vinh', 'Biz', 'Dell', '2022-12-05', 80.00, 80 UNION ALL
	SELECT 'HPM220', 'HP', 'Monitor', 'HP 22-inch Monitor', 'Joey', 'Eco', 'HP', '2022-12-10', 45.00, 30 UNION ALL
    SELECT 'LEN102', 'Lenovo', 'Mouse', 'Lenovo Mouse', 'Vinh', 'Biz', 'Dell', '2022-12-15', 5.00, 50 UNION ALL
    SELECT 'LEN102', 'Lenovo', 'Mouse', 'Lenovo Mouse', 'Vinh', 'Eco', 'Dell', '2022-12-15', 5.00, 50 UNION ALL
	SELECT 'MAX901', 'Max', 'Camera', 'Max Web Camera', 'Vinh', 'Biz', 'HP', '2022-12-15', 20.0, 40 UNION ALL
	SELECT 'HP501', 'HP', 'Keyboard', 'HP 101-Key Computer Keyboard', 'Troy', 'Eco', 'HP', '2022-12-20', 9.00, 100 UNION ALL
	SELECT 'HP502', 'HP', 'Mouse', 'HP Mouse', 'Troy', 'Biz', 'HP', '2022-12-20', 6.00, 100 
)

-- Insert data into Purchases table
INSERT INTO Purchases (PurchaserID, PartID, BundleID, PurchaseDate, Qty)
SELECT 
    pu.PurchaserID,
    CASE 
        WHEN p.BundleType IS NOT NULL AND p.BundleBrand IS NOT NULL THEN NULL 
        ELSE (SELECT TOP 1 PartID FROM Parts WHERE PartNumber = p.PartNumber)
    END AS PartID,
    CASE 
        WHEN p.BundleType IS NOT NULL AND p.BundleBrand IS NOT NULL THEN (SELECT TOP 1 BundleID FROM Bundles WHERE BundleTypeID = bt.BundleTypeID AND BundleBrandID = bb.BundleBrandID) -- Select Bundle
        ELSE NULL -- Select Part
    END AS BundleID,
     p.PurchaseDate AS PurchaseDate,
    p.Qty
FROM PurchaseData p
LEFT JOIN BundleType bt ON p.BundleType = bt.BundleTypeName
LEFT JOIN BundleBrand bb ON p.BundleBrand = bb.BundleBrandName
LEFT JOIN Purchasers pu ON p.Purchaser = pu.FirstName;
GO

Print 'Insert more Data for Purchases table.';
INSERT INTO Purchases (PurchaserID, BundleID, PurchaseDate, Qty)
VALUES
    -- Dell Optiplex 1010
    (1, (SELECT TOP 1 BundleID FROM Bundles WHERE BundleTypeID = 1 AND BundleBrandID = 1), '2022-10-31', 25),
    -- Dell 19-inch Monitor
    (1, (SELECT TOP 1 BundleID FROM Bundles WHERE BundleTypeID = 1 AND BundleBrandID = 1), '2022-10-31', 25),
-- Purchases for HP Biz Bundle
    -- HP EliteDesk 800G1
    (2, (SELECT TOP 1 BundleID FROM Bundles WHERE BundleTypeID = 2 AND BundleBrandID = 2), '2022-11-20', 20),
    -- HP 27-inch Monitor
    (2, (SELECT TOP 1 BundleID FROM Bundles WHERE BundleTypeID = 2 AND BundleBrandID = 2), '2022-11-20', 20);
	GO


Print 'Insert Data into BundleParts table.';
INSERT INTO BundleParts (BundleID, PartID)
VALUES 
    -- Dell Eco Bundle
    ((SELECT TOP 1 BundleID FROM Bundles WHERE BundleTypeID = (SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Eco') AND BundleBrandID = (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'Dell') AND BundleDiscount = 0.10), (SELECT PartID FROM Parts WHERE PartNumber = 'DL1010')),
    ((SELECT TOP 1 BundleID FROM Bundles WHERE BundleTypeID = (SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Eco') AND BundleBrandID = (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'Dell') AND BundleDiscount = 0.10), (SELECT PartID FROM Parts WHERE PartNumber = 'DLM190')),
    -- HP Biz Bundle
    ((SELECT TOP 1 BundleID FROM Bundles WHERE BundleTypeID = (SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Biz') AND BundleBrandID = (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'HP') AND BundleDiscount = 0.15), (SELECT PartID FROM Parts WHERE PartNumber = 'HP800')),
    ((SELECT TOP 1 BundleID FROM Bundles WHERE BundleTypeID = (SELECT BundleTypeID FROM BundleType WHERE BundleTypeName = 'Biz') AND BundleBrandID = (SELECT BundleBrandID FROM BundleBrand WHERE BundleBrandName = 'HP') AND BundleDiscount = 0.15), (SELECT PartID FROM Parts WHERE PartNumber = 'HPM270'));
GO


-- Question 10 Create a View to Display all purchase details with extended amount

CREATE VIEW View_PurchaseDetailsWithExtendedAmount AS
SELECT 
    p.PartNumber, 
    s.SupplierName, 
    pt.PartTypeName, 
    p.PartDescription, 
    pcr.FirstName, 
    pc.PurchaseDate, 
    p.PartUnitPrice, 
    pc.Qty, 
    p.PartUnitPrice * pc.Qty AS Extended_Amount
FROM 
    (SELECT 
        t1.PurchaseID, 
        t1.PurchaserID, 
        COALESCE(t1.PartID, t2.PartID) AS PartID, 
        t1.BundleID, 
        t1.PurchaseDate, 
        t1.Qty 
     FROM Purchases t1 
     LEFT JOIN BundleParts t2 ON t1.BundleID = t2.BundleID
     WHERE COALESCE(t1.PartID, t2.PartID) IS NOT NULL) pc
JOIN Parts p ON pc.PartID = p.PartID 
JOIN Purchasers pcr ON pc.PurchaserID = pcr.PurchaserID 
JOIN Suppliers s ON p.SupplierID = s.SupplierID 
JOIN PartTypes pt ON p.PartTypeID = pt.PartTypeID;
GO

-- Test Question 10 View to Display all purchase details with extended amount

print 'Test Question 10 View to Display all purchase details with extended amount';

SELECT *
FROM View_PurchaseDetailsWithExtendedAmount
ORDER BY FirstName, PurchaseDate, PartNumber;
GO

-- Question 11_A Create a View to display desktop bundles total coast

CREATE VIEW vw_DesktopBundlesTotalCost AS
SELECT bp.BundleID, SUM(p.PartUnitPrice) AS total_cost
FROM BundleParts bp JOIN Parts p ON bp.PartID = p.PartID
GROUP BY bp.BundleID;
Go

-- Test Question 11_A DesktopBundleTotalCost view
print 'Test Question 11_A DesktopBundleTotalCost view';
SELECT * FROM vw_DesktopBundlesTotalCost
ORDER BY BundleID;


--Question 11_B Stored Procedure "adds a new purchase record to the Purchases table."
GO

CREATE PROCEDURE sp_AddNewPurchase
    @purchaserID INT,
    @partID INT = NULL, -- Default NULL means it might be a bundle pwe4waurchase
    @bundleID INT = NULL, -- Default NULL means it might be a part purchase
    @purchaseDate DATE,
    @qty INT
AS
BEGIN
    -- Validate inputs to respect CHK_PartOrBundle constraint
    IF (@partID IS NOT NULL AND @bundleID IS NOT NULL) OR (@partID IS NULL AND @bundleID IS NULL)
    BEGIN
        RAISERROR('Each purchase must be for either a part or a bundle, not both or neither.', 16, 1);
        RETURN;
    END
    
    -- Insert the new purchase record
    INSERT INTO Purchases (PurchaserID, PartID, BundleID, PurchaseDate, Qty)
    VALUES (@purchaserID, @partID, @bundleID, @purchaseDate, @qty);
END;
GO

--Question 11_B Trigger "inserts a purchaser details into the Notifications table whenever a new purchase with a quantity greater than 100 is made in the Purchases table."

CREATE TRIGGER trg_LargePurchaseNotification
ON Purchases
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if the inserted purchase has a Qty greater than 100
    IF EXISTS (SELECT * FROM inserted WHERE Qty > 100)
    BEGIN
        INSERT INTO Notifications (Message)
        SELECT 'Large purchase made by PurchaserID ' + CAST(i.PurchaserID AS VARCHAR) + ' on ' + CAST(i.PurchaseDate AS VARCHAR) + '. Quantity: ' + CAST(i.Qty AS VARCHAR)
        FROM inserted i
        WHERE i.Qty > 100;
    END
END;
GO
