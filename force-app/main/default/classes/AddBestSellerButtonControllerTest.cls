/*
    Author: Myron Salazar
*/

@isTest
public with sharing class AddBestSellerButtonControllerTest {
    
    @TestSetup
    static void testSetup(){

        Account testAccount = TestDataFactory.createAccount('Test Account', Constants.REGION_USA + ';' + Constants.REGION_AUS, true);

        //Setting up Product2s to use
        Product2 testProduct1 = TestDataFactory.createProduct('Product1', Constants.REGION_USA, true);
        Product2 testProduct2 = TestDataFactory.createProduct('Product2', Constants.REGION_AUS, true);

        //Setting up Region Records and TopProducts
        Region__c testRegion1 = TestDataFactory.createRegion(Constants.REGION_USA, true);
        Region__c testRegion2 = TestDataFactory.createRegion(Constants.REGION_AUS, true);
        TopProduct__c testTopProd1 = TestDataFactory.createTopProduct('test Top Product 1', testRegion1.Id, testProduct1.Id, 4, true);
        TopProduct__c testTopProd2 = TestDataFactory.createTopProduct('test Top Product 2', testRegion2.Id, testProduct2.Id, 3, true);

        //Pricebook and pricebook entry for Product1 - will be used for creating Opp Product after calling the topBestSelling class
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = TestDataFactory.createPriceBookEntry(pricebookId, testProduct1.Id, 2000, true);
        Pricebook2 testPriceBook = TestDataFactory.createPriceBook(true);
        PricebookEntry customPrice = TestDataFactory.createPriceBookEntry(testPriceBook.Id, testProduct1.Id, 2500, true);

        Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id, Constants.OPP_PROSPECTING, testPriceBook.Id, true);
    }

    @isTest
    static void validateAddTopSellingProducts(){
        Product2 thisProd = [SELECT Id, Name, Region__c from Product2 WHERE Name = 'Product2'];
        Opportunity thisOpp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        
        //Pricebook and pricebook entry for Opp Product before calling the topBestSelling class
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = TestDataFactory.createPriceBookEntry(pricebookId, thisProd.Id, 2000, true);
        Pricebook2 thisCustomPb = [SELECT Id, Name FROM Pricebook2 LIMIT 1];
        PricebookEntry customPrice = TestDataFactory.createPriceBookEntry(thisCustomPb.Id, thisProd.Id, 2300, true);

        PricebookEntry thisPbe = [SELECT Id, Name, UnitPrice FROM PricebookEntry WHERE UnitPrice = 2300 LIMIT 1];
       
        //Adding an existing Opp Product before calling the class
        OpportunityLineItem oppProd = TestDataFactory.createOppLineItem(thisOpp.Id, thisProd.Id, 1, thisPbe.UnitPrice, Date.today().addDays(7), true);

        Test.startTest();
        Boolean result = AddBestSellerButtonController.addTopSellingProducts(thisOpp.Id);
        Test.stopTest();

        List<OpportunityLineItem> totalOppProd = [SELECT Id, Product2.Name, Product2.Region__c FROM OpportunityLineItem WHERE OpportunityId = :thisOpp.Id];
        
        Assert.isTrue(result, 'Add 5 Button did not work');
        Assert.areEqual(2, totalOppProd.size(), 'No Top Sellers were added to Opportunity record.');
    }
}