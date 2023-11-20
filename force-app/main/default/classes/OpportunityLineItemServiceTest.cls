/*
    Apex Learning Session Final Assignment
    Author: Myron Salazar
*/

@isTest
public with sharing class OpportunityLineItemServiceTest {
    
    @TestSetup
    static void testSetup(){

        Account testAccount = TestDataFactory.createAccount('Test Account', Constants.REGION_USA + ';' + Constants.REGION_AUS, true);
        Product2 testProduct1 = TestDataFactory.createProduct('Product1', Constants.REGION_ALL, true);
        Product2 testProduct2 = TestDataFactory.createProduct('Product2', Constants.REGION_EMEA, true);
        Pricebook2 testPriceBook = TestDataFactory.createPriceBook(true);
        Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id, Constants.OPP_PROSPECTING, testPriceBook.Id, true);
    }

    @isTest
    static void validatePositiveCheckOppProdRegion(){

        Product2 thisProd = [SELECT Id, Name, Region__c from Product2 WHERE Name = 'Product1'];
        Opportunity thisOpp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Pricebook2 thisPb = [SELECT Id, Name FROM Pricebook2 LIMIT 1];
        
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = TestDataFactory.createPriceBookEntry(pricebookId, thisProd.Id, 2000, true);
        PricebookEntry customPrice = TestDataFactory.createPriceBookEntry(thisPb.Id, thisProd.Id, 2500, true);

        PricebookEntry thisPbe = [SELECT Id, Name, UnitPrice FROM PricebookEntry WHERE UnitPrice = 2500 LIMIT 1];

        //Add Opportunity product for Positive Result = Account Region matches Product Region
        //Account Region is USA and AU while Product Region is ALL
        Test.startTest();
        OpportunityLineItem oppProd = TestDataFactory.createOppLineItem(thisOpp.Id, thisProd.Id, 1, thisPbe.UnitPrice, Date.today().addDays(7), true);
        Test.stopTest();

        List<OpportunityLineItem> newOppProd = [SELECT Id FROM OpportunityLineItem];

        Assert.areEqual(1, newOppProd.size(), 'No Opportunity Product was added');
    }

    @isTest
    static void validateNegativeCheckOppProdRegion(){
        Product2 thisProd = [SELECT Id, Name, Region__c from Product2 WHERE Name = 'Product2'];
        Opportunity thisOpp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Pricebook2 thisPb = [SELECT Id, Name FROM Pricebook2 LIMIT 1];
        
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = TestDataFactory.createPriceBookEntry(pricebookId, thisProd.Id, 2000, true);
        PricebookEntry customPrice = TestDataFactory.createPriceBookEntry(thisPb.Id, thisProd.Id, 2500, true);

        PricebookEntry thisPbe = [SELECT Id, Name, UnitPrice FROM PricebookEntry WHERE UnitPrice = 2500 LIMIT 1];

        //Add Opportunity product for Negative Result = Account Region didn't match Product Region
        //Account Region is USA and AU while Product Region is EMEA
        OpportunityLineItem oppProd = TestDataFactory.createOppLineItem(thisOpp.Id, thisProd.Id, 1, thisPbe.UnitPrice, Date.today().addDays(7), false);

        Test.startTest();
        Database.SaveResult result = Database.insert(oppProd, false);
        Test.stopTest();

        Assert.areEqual(false, result.isSuccess(), 'Error message did not appear. As Opportunity Product was added');
        Assert.areEqual(1, result.getErrors().size(), 'Error message did not appear. As Opportunity Product was added');
    }
}