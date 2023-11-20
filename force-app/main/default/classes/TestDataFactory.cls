/*
    Author: Myron Salazar
*/

public with sharing class TestDataFactory {
    
    public static Account createAccount(String name, String regions, Boolean doInsert) {
        Account acc = new Account(
            Name = name, 
            Region__c = regions
        );
        if(doInsert) {
            insert acc;
        }
        return acc;
    }

    public static Contact createContact(Id accountId, Boolean doInsert) {
        Contact con = new Contact (
            Firstname = 'test', 
            LastName = 'Contact', 
            AccountId = accountId, 
            Email = 'testcontact@gmail.com'
        );
        if(doInsert){
            insert con;
        }
        return con;
    }

    public static Opportunity createOpportunity(Id accountId, String stageName, Id pricebookId, Boolean doInsert) {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = accountId,
            CloseDate = Date.today().addDays(3),
            StageName = stageName,
            Pricebook2Id = pricebookId
        );
        if(doInsert) {
            insert opp;
        }
        return opp;
    }

    public static OpportunityLineItem createOppLineItem(Id oppId, Id prodId, Integer quantity, Decimal unitPrice, Date deliveryDate, Boolean doInsert) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem(
            OpportunityId = oppId,
            Product2Id = prodId,
            Quantity = quantity,
            DeliveryDate__c = deliveryDate,
            UnitPrice = unitPrice
        );
        if(doInsert) {
            insert oppLineItem;
        }
        return oppLineItem;
    }
      

    public static Product2 createProduct(String name, String regions, Boolean doInsert){
        Product2 prod = new Product2(
            Name = name,
            IsActive = true,
            Region__c = regions
        );
        if(doInsert){
            insert prod;
        }
        return prod;
    }

    public static Pricebook2 createPriceBook(Boolean doInsert){
        Pricebook2 priceBook = new Pricebook2(
            Name = 'Test PriceBook',
            IsActive = true
        );
        if(doInsert) {
            insert priceBook;
        }
        return priceBook;
    }

    public static PricebookEntry createPriceBookEntry(Id pricebookId, Id productId, Integer unitPrice, Boolean doInsert){
        PricebookEntry pricebook = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = productId, 
            UnitPrice = unitPrice, 
            IsActive = true
        );
        if(doInsert){
            insert pricebook;
        }
        return pricebook;
    }

    public static TopBestSeller__c createTopBestSeller(String name, Id accountId, Id productId, String regions, Integer quantity, Boolean doInsert){
        TopBestSeller__c topSeller = new TopBestSeller__c(
            Name = name,
            CustomerAccount__c = accountId,
            Product__c = productId,
            Region__c = regions,
            TotalQuantitySold__c = quantity
        );
        if(doInsert){
            insert topSeller;
        }
        return topSeller;
    }

    public static Region__c createRegion(String name, Boolean doInsert){
        Region__c region = new Region__c(Name = name);
        if(doInsert){
            insert region;
        }
        return region;
    }

    public static TopProduct__c createTopProduct(String name, Id regionId, Id productId, Integer quantity, Boolean doInsert){
        TopProduct__c topProd = new TopProduct__c(
            Name = name,
            Region__c = regionId,
            Product__c = productId,
            TotalQuantitySold__c = quantity
        );
        if(doInsert){
            insert topProd;
        }
        return topProd;
    }

    public static Order createOrder(Id accountId, Id oppId, Id pricebookId, Boolean doInsert){
        Order ord = new Order (
            AccountId = accountId,
            OpportunityId = oppId,
            Status = Constants.STATUS_DRAFT,
            EffectiveDate = Date.today(),
            Pricebook2Id = pricebookId
        );
        if(doInsert){
            insert ord;
        }
        return ord;
    }
    
    public static OrderItem createOrderItem(Id orderId, Id prodId, Id pricebookEntryId, Integer quantity, Decimal unitPrice, Boolean doInsert){
        OrderItem orderItem = new OrderItem(
            OrderId = orderId,
            Product2Id = prodId,
            PricebookEntryId = pricebookEntryId,
            Quantity = quantity,
            UnitPrice = unitPrice
        );
        if(doInsert){
            insert orderItem;
        }
        return orderItem;
    }
}