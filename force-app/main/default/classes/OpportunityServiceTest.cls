/*
    Author: Myron Salazar
*/

@isTest
public class OpportunityServiceTest {
    
    @TestSetup
    static void testSetup(){
        Account testAccount = TestDataFactory.createAccount('Test Account', Constants.REGION_USA + ';' + Constants.REGION_AUS, true);

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

        //Setting up Opportunity products to use
        OpportunityLineItem oppProd1 = TestDataFactory.createOppLineItem(testOpp.Id, testProduct1.Id, 1, customPrice1.UnitPrice, Date.today().addDays(5), true);
        OpportunityLineItem oppProd2 = TestDataFactory.createOppLineItem(testOpp.Id, testProduct2.Id, 1, customPrice2.UnitPrice, Date.today().addDays(7), true);
    }

    @isTest
    static void validateCreateOrderForClosedWonOpp() {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE StageName = :Constants.OPP_PROSPECTING LIMIT 1];
        opp.StageName = Constants.OPP_CLOSED_WON;

        Test.startTest();
        update opp;
        Test.stopTest();

        List<Order> ordersCreated = [SELECT Id FROM Order];
        List<OrderItem> orderProdCreated = [SELECT Id FROM OrderItem];

        Assert.areEqual(2, ordersCreated.size(), 'No orders were created');
        Assert.areEqual(2, orderProdCreated.size(), 'No order items created');
    }
}