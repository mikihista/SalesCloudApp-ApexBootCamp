# Apex BootCamp Project - Sales Cloud App

As part of an internal Apex Bootcamp course which ran for 5 weeks, we've learned about Apex such as Triggers, Test Classes, Implementing Batchable and Schedulable. This project is our final assignment.

I've tried my best to follow best practice and find solution to answer the tasks.

Things that aid me in this project:
- Reaching out to Senior Consultants for Advices, specially in the architetural space.
- Utilising Chat GPT to help with Logic and Debugging
- Good ol googling

## Project Background

RCP traders is a company selling multiple manufacturing products across the globe. Recently they have come up with a requirement to enhance their standard Sales cloud implementation to fulfil their business needs and drive some automation.

## Setup

1.	RCP traders have a multi-select picklist as “Region” on Account and Product objects. Values in the field can be – EMEA, APAC, USA, Australia and All
2.	Each product and customer in the org is tagged with one or multiple regions.
3.	Opportunity product has a delivery date field. Which is used to define when this product needs to be delivered.

## Requirements and Solution

1.	If a product getting added on opportunity is not available for customer’s region. It should prevent user from adding it and display a message – “Product you are trying to add is not available in (Customer Name)’s region.”
    Solution:
    - Used .addError() method to display message if Customer’s region doesn’t match Product region.
    - Class created: OpportunityLineItemService.checkOppProdRegion

2.	If a button on opportunity “Add 5 best sellers” is clicked it auto adds top 5 best seller products in customer’s region with a quantity of one each.
    Solution:
    - Part of the solution is that I created 2 new custom objects Region__c which holds region records and a child object called TopProduct__c which holds Region Id and Product Id. TopProduct__c records will also be used to hold information for task 3.
    - Created Headless quick action LWC. Decided to go with an LWC as I want to challenge myself to create one.
    - Class created: AddBestSellerButtonController.addTopSellingProducts () – class called by LWC quick action to add the Top 5 best sellers according to the customer’s region.
    - Some of the additional features I added is the new RefreshEvent() in the .JS file of the LWC to refresh the records automatically after record creation.

3.	Add a logic to maintain top 5 best seller products across region to run every morning (Weekdays only) 7:00 am. These should be measured over Closed-Won opportunities not older than 2 years. How to and where to maintain this across the region list needs to be solved as a part of this assignment.
    Solution:
    - Class created: MaintainTopBestSellerSched (Schedule) and MaintainTopBestSellersBatch (Batch) - Decided to used batchable to avoid hitting any governor limits in case the org becomes big and it starting to deal with tons of data.
    - MaintainTopBestSellersBatch will query all OpportunityLineItem that is part of Closed Won Opportunities that is not older than 2 years. The order is organized by the number of quantity sold as per OpportunityLineItem record. This is the criteria I used to check whether this will be included in the Top 5 Products per region.
    - As part of the solution, I implemented a logic in the code that deletes all TopProductRecords so that it’s easier to store and maintain the Top 5 products per region every morning at 7AM.
    - The MaintainTopBestSellerSched apex schedule can either be called via Setup or via the Anonymous Apex Window.

4.	Each closed won opportunity should be auto converted to multiple orders based on delivery date. We need Order date to be populated as a delivery date on opportunity products. Example, If an opportunity has 3 products on it. Two of them are with delivery date of 25 August 2023 and one with 30 August 2023. Then, in total 2 orders should be created one for 25 Aug and other one for 30 August. We also need to add order line items based on date split. 
    Solution:
    - Class created: OpportunityService.createOrderForClosedWonOpp 
    - This class is called during after update of the OpportunityTrigger only when the Opportunity StageName == ‘Closed Won’.

5.	All the customers should receive a weekly email with their order summary mentioning the number of orders made and total order amount for the week. 
    Solution:
    - Classes created: WeeklyOrderSummary (Schedulable) and SendOrderSummaryEmailBatch(Batchable) 
    - Decided to used batchable to avoid hitting any governor limits in case the org becomes big and it starting to deal with tons of data.
    - The WeeklyOrderSummary apex schedule can either be called via Setup or via the Anonymous Apex Window.

6.  Test classes to be written for all classes.
    Solution:
    - TestDataFactory and test classes created for all Classes in this assignment.

### Classes/LWC Component created for this project:

1.	OpportunityLineItemTrigger.Trigger(Task 1)
2.	OpportunityLineItemTriggerHandler.cls (Task 1)
3.	OpportunityLineItemService.cls (Task 1) 
4.	OpportunityLineItemServiceTest.cls(Task 6)
5.	AddBestSellerButtonController (Task 2)
6.	Top5BestSellerButton LWC (Task 2 – Has 3 files: HTML, XML and JS)
7.	AddBestSellerButtonControllerTest(Task 6)
8.	MaintainTopBestSellersBatch.cls (Task 3)
9.	MaintainTopSellerSched.cls (Task 3)
10.	MaintainTopSellerSchedTest.cls(Task 6)
11.	OpportunityTrigger.trigger (Task 4)
12.	OpportunityTriggerHandler.cls (Task 4)
13.	OpportunityService.cls (Task 4)
14.	OpportunityServiceTest.cls(Task 6)
15.	WeeklyOrderSummary.cls(Task 5)
16.	SendOrderSummaryEmailBatch.cls(Task 5)
17.	WeeklyOrderSummaryTest.cls(Task 6)
18.	TestDataFactory.cls (Task 6)


### Potential Future enhancements:
- Refactoring the code
- Use of Selector classes per object
- Use of Database class

