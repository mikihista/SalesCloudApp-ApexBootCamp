/*
    Author: Myron Salazar
*/

@isTest
public with sharing class MaintainTopSellerSchedTest {

    private static String CRON_EXP = '0 0 7 * * ?';

    @TestSetup
    static void testSetup(){
        Account testAccount = TestDataFactory.createAccount('Test Account', Constants.REGION_USA + ';' + Constants.REGION_AUS, true);

        //Setting up Product2s to use
        Product2 testProduct1 = TestDataFactory.createProduct('Product1', Constants.REGION_USA, true);
        Product2 testProduct2 = TestDataFactory.createProduct('Product2', Constants.REGION_USA, true);
        Product2 testProduct3 = TestDataFactory.createProduct('Product3', Constants.REGION_AUS, true);
        Product2 testProduct4 = TestDataFactory.createProduct('Product4', Constants.REGION_AUS, true);


        //Setting up Pricebook, Standard and customer Pricebook entry and opportunity
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 testPriceBook = TestDataFactory.createPriceBook(true);
        PricebookEntry standardPrice1 = TestDataFactory.createPriceBookEntry(pricebookId, testProduct1.Id, 2500, true);
        PricebookEntry standardPrice2 = TestDataFactory.createPriceBookEntry(pricebookId, testProduct2.Id, 3000, true);
        PricebookEntry standardPrice3 = TestDataFactory.createPriceBookEntry(pricebookId, testProduct3.Id, 2300, true);
        PricebookEntry standardPrice4 = TestDataFactory.createPriceBookEntry(pricebookId, testProduct4.Id, 1500, true);

        PricebookEntry customPrice1 = TestDataFactory.createPriceBookEntry(testPriceBook.Id, testProduct1.Id, 2500, true);
        PricebookEntry customPrice2 = TestDataFactory.createPriceBookEntry(testPriceBook.Id, testProduct2.Id, 3000, true);
        PricebookEntry customPrice3 = TestDataFactory.createPriceBookEntry(testPriceBook.Id, testProduct3.Id, 2300, true);
        PricebookEntry customPrice4 = TestDataFactory.createPriceBookEntry(testPriceBook.Id, testProduct4.Id, 1500, true);

        Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id, Constants.OPP_CLOSED_WON, testPriceBook.Id, true);
        testOpp.CloseDate = Date.Today();

        //Setting up Region records to use
        Region__c testRegion1 = TestDataFactory.createRegion(Constants.REGION_USA, true);
        Region__c testRegion2 = TestDataFactory.createRegion(Constants.REGION_AUS, true);
        TopProduct__c testTopProd1 = TestDataFactory.createTopProduct('test Top Product 1', testRegion1.Id, testProduct1.Id, 4, true);
        TopProduct__c testTopProd2 = TestDataFactory.createTopProduct('test Top Product 2', testRegion2.Id, testProduct2.Id, 3, true);

        //Setting up multiple Opportunity Products
        OpportunityLineItem testOppProd1 = TestDataFactory.createOppLineItem(testOpp.Id, testProduct1.Id, 15, customPrice1.UnitPrice, testOpp.CloseDate, true);
        OpportunityLineItem testOppProd2 = TestDataFactory.createOppLineItem(testOpp.Id, testProduct2.Id, 14, customPrice2.UnitPrice, testOpp.CloseDate, true);
        OpportunityLineItem testOppProd3 = TestDataFactory.createOppLineItem(testOpp.Id, testProduct3.Id, 13, customPrice3.UnitPrice, testOpp.CloseDate, true);
        OpportunityLineItem testOppProd4 = TestDataFactory.createOppLineItem(testOpp.Id, testProduct4.Id, 8, customPrice4.UnitPrice, testOpp.CloseDate, true);
        OpportunityLineItem testOppProd5 = TestDataFactory.createOppLineItem(testOpp.Id, testProduct4.Id, 7, customPrice4.UnitPrice, testOpp.CloseDate, true);

    }

    @isTest
    static void validateMaintainTopSellers() {

        Test.startTest();
        Id jobId = System.schedule('TestScheduleJob', CRON_EXP, new MaintainTopSellerSched());
        Id batchId = Database.executeBatch(new MaintainTopBestSellersBatch());
        Test.stopTest();

        List<TopProduct__c> topProdUSA = [SELECT Id, Region__r.Name, Product__r.Name FROM TopProduct__c WHERE Region__r.Name = :Constants.REGION_USA];
        List<TopProduct__c> topProdAU = [SELECT Id, Region__r.Name, Product__r.Name FROM TopProduct__c WHERE Region__r.Name = :Constants.REGION_AUS];

        //scheduleJobCount should increase by 1 if schedule job was successful
        Assert.areEqual(1, MaintainTopSellerSched.scheduleBatchJobCount, 'Schedule batch job was unsuccessful.');
        Assert.areEqual(2, topProdUSA.size(), 'Top Products were not created for Region USA.');
        Assert.areEqual(2, topProdAU.size(), 'Top Products were not created for Region Australia.');
    }
}