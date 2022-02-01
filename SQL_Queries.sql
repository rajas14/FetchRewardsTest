
-- Q1: What are the top 5 brands by receipts scanned for most recent month?
SELECT COUNT(a.barcode) as TimesBought, a.barcode, a.brandCode FROM allitems as a INNER JOIN receiptfinal as b ON a._Id = b._Id 
WHERE MONTH(b.DateScanned) IN (SELECT MONTH(MAX(k.DateScanned)) FROM receiptfinal as k) GROUP BY a.barcode ORDER BY COUNT(a.barcode) DESC LIMIT 5;

-- Q2: How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
SELECT COUNT(a.barcode) as TimesBought, a.barcode, a.brandCode, MONTH(b.DateScanned) as MonthOfReceipt, 
DENSE_RANK() OVER(PARTITION BY MONTH(b.DateScanned) ORDER BY COUNT(a.barcode) DESC) as DenseRankBrands
FROM allitems as a INNER JOIN receiptfinal as b ON a._Id = b._Id 
WHERE MONTH(b.DateScanned) = (SELECT MONTH(MAX(k.DateScanned)) FROM receiptfinal as k) 
OR MONTH(b.DateScanned) = (SELECT MONTH(MAX(l.DateScanned)) - 1 FROM receiptfinal as l)
GROUP BY a.barcode, MONTH(b.DateScanned) ORDER BY COUNT(a.barcode) DESC;

-- Q3: Average Spent for Receipts with Status as Rejected and Accepted. -- Assumed that Finished is Accepted
SELECT AVG(totalSpent) as AvgSpent, rewardsReceiptStatus FROM receiptfinal WHERE rewardsReceiptStatus IN ('FINISHED', 'REJECTED')
 GROUP BY rewardsReceiptStatus ORDER BY AvgSpent DESC;
 
 -- Q4: When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT rewardsReceiptStatus, SUM(purchasedItemCount) as ItemsCount FROM receiptfinal WHERE rewardsReceiptStatus IN ('FINISHED', 'REJECTED') 
GROUP BY rewardsReceiptStatus ORDER BY ItemsCount;

-- Q5: Which brand has the most spend among users who were created within the past 6 months?
SELECT a.brandCode, a.name, a.barcode, COUNT(a.barcode), SUM(b.finalPrice) FROM brandsfinal as a RIGHT JOIN allitems as b ON a.barcode = b.barcode 
INNER JOIN receiptfinal as c ON b._Id = c._Id 
WHERE c.userId IN (SELECT Id FROM userfinal WHERE (YEAR(str_to_date(CreatedDate, '%m/%d/%Y %H:%i:%s')) = 2021 AND MONTH(str_to_date(CreatedDate, '%m/%d/%Y %H:%i:%s')) IN (1, 2, 3)
OR YEAR(str_to_date(CreatedDate, '%m/%d/%Y %H:%i:%s')) = 2020 AND MONTH(str_to_date(CreatedDate, '%m/%d/%Y %H:%i:%s')) IN (9, 10, 11, 12))) GROUP BY a.barcode 
ORDER BY SUM(b.finalPrice) DESC;
