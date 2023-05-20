# ![Babbel](https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Babbel_logo.svg/2560px-Babbel_logo.svg.png)
This repository was created for the Take-Home Test from Babbel.


# Design Questions
● **Question 1:** How would you handle duplicate events?
>**Answer 1:** It depends on our architecture. There are some options for handling duplicate records;
>- We can add a Lambda Function after the Kinesis Data Stream. This function takes the unique identifier of records (sequence number or event_uuid) and compares it with existing records (maybe in the last 7 days). If the record already exists, we'll send that record to a dead-letter queue. If not, we'll ingest it.
>- We can handle this in the data lake after all records are ingested. Let's say, in Redshift or Snowflake, we can create a layer like raw_data, and all ingested records are stored there. After that, we can create a layer like data_lake or something like that. This layer stores the data without duplicates and corrupted records.
>- I would say the 2nd option is the most reliable solution.

●**Question 2:** How would you partition the data to ensure good querying performance and scalability?
>**Answer 2:** 
> - We have 100 different types of events, and all delivering mixed together. So, if we store all records in 1 table - I wouldn't do that- we can partition our table with created_date derived from the created_at field, and event_type derived from event_name.
> - I would recommend splitting those events and storing each of them on their own table (e.g. account_creation_event, payment_order_completed_event). After that, we can partition each of the event tables with the created_date that is derived from the created_at field.

● **Question 3:** What format would you use to store the data?
>**Answer 3:** I would use the parquet as the format of our events on S3. Then I would create my event tables with Delta formatted.

● **Question 4:** How would you test the different components of your proposed architecture?
>**Answer 4:** TBD

● **Question 5:** How would you ensure the architecture deployed can be replicable across environments?
>**Answer 5:** We can use tools like Packer to ensure our proposed architecture replicable across environments, and to keep up-to-date.

● **Question 6:** Would your proposed solution still be the same if the amount of events is 1000 times smaller or bigger?
>**Answer 6:** Yes, I would use same architecture because AWS Kinesis is the fully-managed queue service which easily upscale or downscale of itself. (On-demand mode)

● **Question 7:** Would your proposed solution still be the same if adding fields / transforming the data is no longer needed?
>**Answer:7 -** Yes, it would be the same because I would handle the corrupted, duplicated records and enhensment of the existing data on DB Level.

# Architecture Options
**Alternative-1**
![image](https://github.com/emrekabalcii/babbel/assets/9528391/bcd8c433-49c0-4267-9565-9e53955d8f06)


**Alternative-2**
![image](https://github.com/emrekabalcii/babbel/assets/9528391/6252ee8e-1762-4cfc-bfeb-b4d84bc6d739)
