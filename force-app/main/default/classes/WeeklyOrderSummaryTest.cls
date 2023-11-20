/*
    Author: Myron Salazar
*/

@isTest
public class WeeklyOrderSummaryTest {
    
    private static String CRON_EXP = '0 0 7 ? * MON';

    @TestSetup
    static void testSetup(){

        Account testAccount = TestDataFactory.createAccount('Test Account', Constants.REGION_USA, true);
        Contact testCon = TestDataFactory.createContact(testAccount.Id, true);

        testAccount.PrimaryContact__c = testCon.Id;
        update testAccount;

        //Setting up Product2s to use
        Product2 testProduct1 = TestDataFactory.createProduct('Product1', Constants.REGION_ALL, true);
        Product2 testProduct2 = TestDataFactory.createProduct('Product2', Constants.REGION_USA, true);

        //Pricebook and pricebook entry for Product1 and Product2
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 testPriceBook = TestDataFactory.createPriceBook(true);
        PricebookEntry standardPrice1 = TestDataFactory.createPriceBookEntry(pricebookId, testProduct1.Id, 2000, true);
        PricebookEntry customPrice1 = TestDataFactory.createPriceBookEntry(testPriceBook.Id, testProduct1.Id, 2500, true);

        PricebookEntry standardPrice2 = TestDataFactory.createPriceBookEntry(pricebookId, testProduct2.Id, 1800, true);
        PricebookEntry customPrice2 = TestDataFactory.createPriceBookEntry(testPriceBook.Id, testProduct2.Id, 2000, true);

        Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id, Constants.OPP_PROSPECTING, testPriceBook.Id, true);

        Order testOrder1 = TestDataFactory.createOrder(testAccount.Id, testOpp.Id, testPriceBook.Id, true);      
        Order testOrder2 = TestDataFactory.createOrder(testAccount.Id, testOpp.Id, testPriceBook.Id, true);
        OrderItem testOrderItem1 = TestDataFactory.createOrderItem(testOrder1.Id, testProduct1.Id, customPrice1.Id, 2, customPrice1.UnitPrice, true);
        OrderItem testOrderItem2 = TestDataFactory.createOrderItem(testOrder2.Id, testProduct2.Id, customPrice2.Id, 2, customPrice2.UnitPrice, true);
    }

    @isTest
    static void validateSendOrderSummary(){
        
        Test.startTest();
        Id jobId = System.schedule('TestScheduleJob', CRON_EXP, new WeeklyOrderSummary());
        Test.stopTest();

        //scheduleJobCount should increase by 1 if schedule job was successful
        Assert.areEqual(1, WeeklyOrderSummary.scheduleJobCount, 'Email was not sent to the customer.');
    }
}