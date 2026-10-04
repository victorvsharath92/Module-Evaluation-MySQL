USE ecomm;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(3);

UPDATE customer_churn
SET ComplaintReceived = CASE
    WHEN Complain = 1 THEN 'Yes'
    ELSE 'No'
END;

ALTER TABLE customer_churn
ADD COLUMN ChurnStatus VARCHAR(7);

UPDATE customer_churn
SET ChurnStatus = CASE
    WHEN Churn = 1 THEN 'Churned'
    ELSE 'Active'
END;

SET SQL_SAFE_UPDATES = 1;
USE ecomm;

ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;
USE ecomm;

SELECT ChurnStatus, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY ChurnStatus;
USE ecomm;

SELECT 
    AVG(Tenure) AS AverageTenure,
    SUM(CashbackAmount) AS TotalCashbackAmount
FROM customer_churn
WHERE ChurnStatus = 'Churned';
USE ecomm;

SELECT 
    ROUND(
        100.0 * SUM(CASE WHEN ComplaintReceived = 'Yes' THEN 1 ELSE 0 END) 
        / COUNT(*),
        2
    ) AS ComplaintPercentage
FROM customer_churn
WHERE ChurnStatus = 'Churned';
USE ecomm;

SELECT 
    CityTier,
    COUNT(*) AS ChurnedCustomers
FROM customer_churn
WHERE ChurnStatus = 'Churned'
  AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY ChurnedCustomers DESC
LIMIT 1;
USE ecomm;

SELECT 
    PreferredPaymentMode,
    COUNT(*) AS CustomerCount
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY CustomerCount DESC
LIMIT 1;
USE ecomm;

SELECT SUM(OrderAmountHikeFromLastYear) AS TotalOrderAmountHike
FROM customer_churn
WHERE MaritalStatus = 'Single'
  AND PreferredOrderCat = 'Mobile Phone';
  USE ecomm;

SELECT AVG(NumberOfDeviceRegistered) AS AverageDevicesRegistered
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';
USE ecomm;

SELECT CityTier, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;
USE ecomm;

SELECT Gender, SUM(CouponsUsed) AS TotalCouponsUsed
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCouponsUsed DESC
LIMIT 1;
USE ecomm;

SELECT PreferredOrderCat,
       COUNT(*) AS CustomerCount,
       MAX(HoursSpentOnApp) AS MaxHoursSpentOnApp
FROM customer_churn
GROUP BY PreferredOrderCat;
USE ecomm;

SELECT SUM(OrdersCount) AS TotalOrderCount
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (
      SELECT MAX(SatisfactionScore)
      FROM customer_churn
  );
  USE ecomm;

SELECT AVG(SatisfactionScore) AS AverageSatisfactionScore
FROM customer_churn
WHERE ComplaintReceived = 'Yes';
USE ecomm;

SELECT PreferredOrderCat
FROM customer_churn
WHERE CouponsUsed > 5;
USE ecomm;

SELECT DISTINCT PreferredOrderCat
FROM customer_churn
WHERE CouponsUsed > 5;
USE ecomm;

SELECT
    PreferredOrderCat,
    AVG(CashbackAmount) AS AverageCashbackAmount
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY AverageCashbackAmount DESC
LIMIT 3;
USE ecomm;

SELECT DISTINCT PreferredPaymentMode
FROM customer_churn
WHERE Tenure = 10
  AND OrdersCount > 500;
  USE ecomm;

SELECT
    CASE
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory, ChurnStatus;
USE ecomm;

SELECT
    CustomerID,
    MaritalStatus,
    CityTier,
    OrdersCount,
    PreferredOrderCat,
    PreferredPaymentMode,
    OrderAmountHikeFromLastYear,
    CashbackAmount
FROM customer_churn
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrdersCount > (
      SELECT AVG(OrdersCount)
      FROM customer_churn
  );
  USE ecomm;

CREATE TABLE customer_returns (
    ReturnID INT,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount INT
);

INSERT INTO customer_returns
(ReturnID, CustomerID, ReturnDate, RefundAmount)
VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);
SELECT * FROM customer_returns;
USE ecomm;

SELECT
    r.ReturnID,
    r.CustomerID,
    r.ReturnDate,
    r.RefundAmount,
    c.Gender,
    c.MaritalStatus,
    c.CityTier,
    c.Tenure,
    c.PreferredOrderCat,
    c.PreferredPaymentMode,
    c.OrdersCount,
    c.SatisfactionScore,
    c.ChurnStatus,
    c.ComplaintReceived
FROM customer_returns r
INNER JOIN customer_churn c
    ON r.CustomerID = c.CustomerID
WHERE c.ChurnStatus = 'Churned'
  AND c.ComplaintReceived = 'Yes';