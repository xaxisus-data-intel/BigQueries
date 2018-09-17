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

/*Grouping Domain bid patterns by DoW*/
SELECT DOMAIN, FORMAT_DATE('%A', Event_Date) AS DoW, AVG(( DBM_Bid_Price__USD_/1000000)) AS AVG_Bid_Price, AVG(( DBM_Media_Cost__USD_/1000000)) AS AVG_Clear_Price FROM `focus-terra-177621.Lufthansa_test.Lufthansa_Impression_Logs`
GROUP BY DOMAIN, DoW
ORDER BY AVG_Bid_Price DESC;

/*Grouping Domain Bid Patterns by Hour Of Day*/
SELECT DOMAIN, HOUR(Event_Time) AS HourOfDay, AVG(( DBM_Bid_Price__USD_/1000000)) AS AVG_Bid_Price, AVG(( DBM_Media_Cost__USD_/1000000)) AS AVG_Clear_Price FROM [focus-terra-177621:Lufthansa_test.Lufthansa_Impression_Logs] 
GROUP BY DOMAIN, HourOfDay
ORDER BY AVG_Bid_Price DESC;

/*Averages by Device Type*/
SELECT device_type, AVG(buyer_bid) AS avg_bid, AVG( media_cost_dollars_cpm) AS avg_cost FROM [xaxis-1:Xaxis_Analytics.AN_ImpressionLog] GROUP BY device_type;

/*Frequency Distribution (Number of unique users with frequency 1, 2, 3, etc)*/
SELECT A.user_count as Freq_bucket, count(DISTINCT A.user_id_64) AS User_Count
FROM (
SELECT count(user_id_64) AS user_count, user_id_64
FROM [Xaxis_Analytics.AN_ImpressionLog] AS A
WHERE insertion_order_id = 695953
AND datetime > '2018-08-01 00:00:00 UTC'
AND user_id_64 != 0
GROUP BY 2)
GROUP BY 1
ORDER BY 1;

/*Bundling Tactics*/
select case 
          when a.insertion_order_id in (795547,714645) then "Bundle A"
          when a.insertion_order_id in (722362,753916) then "Bundle B"
          END as tactic_name
          , sum(a.is_imp)
          from [xaxis-1:Xaxis_Analytics.AN_ImpressionLog] as a
where a.is_imp=1
and insertion_order_id in (795547,714645,722362,753916)
and datetime >'2018-05-19 14:50:50'
group by 1

** Overlap Report along with UNIQUE users exposed only to campaign A and Only to campaign B **
** RUN only the INNER query to get the overlap piece of the Venn diagram **
** RUN the entire query to get the A-B and B-A piece. Please make sure to change the Insertion_order_id as per the campaign name. We can use this query to dynamically change the campaign/placement name (bundles) as per the requirements.
** We can also add in the domain names if required (requirement based)
** Just use the Inner query and remove the condition //a1.insertion_order_id != a2.insertion_order_id// 
      this would give Total A, Total B and AnB. Once we have the data in excel, we can just subtract Total A from AnB to get Only A and similarly for B

Select 
A.insertion_order_id as Campaign_A,
COUNT(DISTINCT uo1.user_id_64) as Unique_Users_A,
from xaxis-1.Xaxis_Analytics.AN_ImpressionLog as A
where A.insertion_order_id= 719065
and A.is_imp=1
and A.datetime between '2018-08-01' and '2018-08-05'
and A.user_id_64 NOT IN 
                        (SELECT
                          a1.insertion_order_id as Campaign_1,
                          a2.insertion_order_id as Campaign_2,
                          COUNT(DISTINCT uo1.user_id_64) as Overlap_users
                        FROM
                          xaxis-1.Xaxis_Analytics.AN_ImpressionLog as a1
                        JOIN
                          xaxis-1.Xaxis_Analytics.AN_ImpressionLog as a2
                        ON
                          (a1.user_id_64 = a2.user_id_64
                            AND a1.insertion_order_id != a2.insertion_order_id
                            )
                        WHERE a1.insertion_order_id in (719065,718827)
                        and a2.insertion_order_id in (719065,718827)
                        and a1.is_imp = 1
                        and a2.is_imp = 1
                        and a1.datetime between '2018-08-01' and '2018-08-05'
                        and a2.datetime between '2018-08-01' and '2018-08-05'
                        GROUP BY
                         a1.insertion_order_id,
                          a2.insertion_order_id) as B
                          
                          
                          
                          
                          
 ** Reach and Frequency--- overall reach and Unique reach broken down by each frequency bucket----- ***
 
 SELECT B.user_count as Freq_bucket, count(DISTINCT B.user_id_64) AS User_Count
FROM (
SELECT count(A.user_id_64) AS user_count, A.user_id_64
FROM [Xaxis_Analytics.AN_ImpressionLog] AS A
WHERE A.insertion_order_id = 719065
AND A.datetime > '2018-08-01 00:00:00 UTC'
AND A.user_id_64 != 0
AND A.is_imp=1
GROUP BY 2) B
GROUP BY 1
ORDER BY 1;

/*T2C Query*/
SELECT A.insertion_order_id, A.is_imp AS Imp, B.post_view_conv AS pv_conv, B.post_click_conv AS pc_convs, A.datetime as impdate, B.datetime as convdate
FROM [Sample_Query_Test.Blackrock_Imps] AS A
LEFT JOIN [Sample_Query_Test.Blackrock_convs] AS B
ON A.auction_id_64 = B.auction_id_64
WHERE A.datetime > '2018-07-01 00:00:00 UTC' AND A.datetime < '2018-07-31 23:59:59 UTC'
AND (timestamp_to_SEC(B.datetime) - timestamp_to_SEC(A.datetime)) < 2592000;

/*Attribution with viewability*/
SELECT A.insertion_order_id, A.view_result, SUM(A.is_imp) AS Imps, SUM(B.post_view_conv) AS pv_convs, SUM(B.post_click_conv) AS pc_convs
FROM [Sample_Query_Test.Blackrock_Imps] AS A
LEFT JOIN [Sample_Query_Test.Blackrock_convs] AS B
ON A.auction_id_64 = B.auction_id_64
WHERE A.datetime > '2018-07-01 00:00:00 UTC' AND A.datetime < '2018-07-31 23:59:59 UTC'
AND (timestamp_to_SEC(B.datetime) - timestamp_to_SEC(A.datetime)) < 2592000
GROUP BY A.insertion_order_id, A.view_result;
