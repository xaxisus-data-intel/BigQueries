/*Average Bid and Clear Price by Site*/

SELECT Site, (AVG(BidPrice)/1000000) AS AvgBidPrice, (AVG(ClearPrice)/1000000) AS AvgClearPrice 
FROM [focus-terra-177621:Lufthansa_test.Lufthansa_Impression_Data] 
GROUP BY Site, ORDER BY AvgBidPrice desc;

/*Average Bid and Clear Price by Exchange*/

SELECT A.Exchange AS Exchange_Name, (AVG(B.BidPrice)/1000000) AS AvgBidPrice, (AVG(B.ClearPrice)/1000000) AS AvgClearPrice
FROM [focus-terra-177621:Lufthansa_test.Exchange_Map] AS A
JOIN [focus-terra-177621:Lufthansa_test.Lufthansa_Impression_Data] AS B
ON A.Exchange_ID = B.ExchangeID
GROUP BY Exchange_Name
ORDER BY AvgBidPrice Desc;

/*Average Bid and Clear Price by DMA*/

SELECT A.DMA_Name AS DMA, (AVG(B.BidPrice)/1000000) AS AvgBidPrice, (AVG(B.ClearPrice)/1000000) AS AvgClearPrice
FROM [focus-terra-177621:Lufthansa_test.DMA_Map] AS A
JOIN [focus-terra-177621:Lufthansa_test.Lufthansa_Impression_Data] AS B
ON A.DMA_Code = B.DMAID
GROUP BY DMA
ORDER BY AvgBidPrice Desc;

/*Average Bid and Clear Price by Creative*/
SELECT A.Creative AS Creative_Name, (AVG(B.BidPrice)/1000000) AS AvgBidPrice, (AVG(B.ClearPrice)/1000000) AS AvgClearPrice
FROM [focus-terra-177621:Lufthansa_test.Creative_Map] AS A
JOIN [focus-terra-177621:Lufthansa_test.Lufthansa_Impression_Data] AS B
ON A.Creative_ID = B.CreativeID
GROUP BY Creative_Name
ORDER BY AvgBidPrice Desc;

/*Bid Price Quantiles by Site*/
/*This requires some processing once the file is exported*/

SELECT Site, (QUANTILES(BidPrice, 5)/1000000) AS BidPriceQuantiles 
FROM [focus-terra-177621:Lufthansa_test.Lufthansa_Impression_Data] 
GROUP BY Site;

/*Count of users exposed to multiple sites*/
select A.Site_Count as Site_Bucket, count(DISTINCT A.DBM_User_ID) AS User_Count
from (
select count(Site) as Site_Count, DBM_User_ID
from [focus-terra-177621:Lufthansa_test.Lufthansa_Impression_Data] as A
WHERE DBM_User_ID != '0'
group by 2) 
group by 1
order by 1 

/*Bid Price Quantiles*/
SELECT (QUANTILES(BidPrice,10)/1000000) FROM [focus-terra-177621:Lufthansa_test.Lufthansa_Impression_Data];

/*I used the results of the above quantiles to build out this bidding distribution */
SELECT COUNT(DBM_User_ID), bucket
FROM (
    SELECT DBM_USER_ID, CASE WHEN (BidPrice/1000000) >= 0.006252 AND (BidPrice/1000000) < 0.350872 THEN 1
                             WHEN (BidPrice/1000000) >= 0.350872 AND (BidPrice/1000000) < 0.649765 THEN 2
                             WHEN (BidPrice/1000000) >= 0.649765 AND (BidPrice/1000000) < 0.88203 THEN 3
                             WHEN (BidPrice/1000000) >= 0.88203 AND (BidPrice/1000000) < 1.141625 THEN 4
                             WHEN (BidPrice/1000000) >= 1.141625 AND (BidPrice/1000000) < 1.494419 THEN 5
                             WHEN (BidPrice/1000000) >= 1.494419 AND (BidPrice/1000000) < 2.032877 THEN 6
							 WHEN (BidPrice/1000000) >= 2.032877 AND (BidPrice/1000000) < 2.968552 THEN 7
							 WHEN (BidPrice/1000000) >= 2.968552 AND (BidPrice/1000000) < 4.32781 THEN 8
							 WHEN (BidPrice/1000000) >= 4.32781 AND (BidPrice/1000000) < 10.0 THEN 9
							 ELSE -1 END AS bucket
		FROM [focus-terra-177621:Lufthansa_test.Lufthansa_Impression_Data])
GROUP BY bucket;

/*Joining Impression Logs to Conversion Logs for Attribution*/

SELECT A.Event_Date, A.DBM_Auction_ID, A.DBM_Line_Item_ID, A.DBM_Creative_ID, A.DBM_Bid_Price__USD_, A.Domain, A.DBM_Site_ID, A.DBM_Exchange_ID, A.DBM_Designated_Market_Area__DMA__ID, A.DBM_Operating_System_ID, A.DBM_ISP_ID, A.DBM_Matching_Targeted_Segments, A.DBM_Device_Type,
A.DBM_Media_Cost__USD_, A.Active_View__Eligible_Impressions, A.Active_View__Measurable_Impressions, A.Active_View__Viewable_Impressions, CASE WHEN A.DBM_Auction_ID = B.DBM_Auction_ID THEN 1 ELSE 0 END AS IsConv
FROM `focus-terra-177621.Lufthansa_test.Lufthansa_Impression_Logs` AS A
LEFT JOIN `focus-terra-177621.Lufthansa_test.Lufthansa_Activity_Logs` AS B 
ON A.DBM_Auction_ID = B.DBM_Auction_ID
WHERE A.Event_Date BETWEEN '2018-04-01' AND '2018-04-03';
