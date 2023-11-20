/*
    Author: Myron Salazar
*/


public with sharing class AddBestSellerButtonController {
    
    @AuraEnabled
    //method used for the 'Add 5 best sellers' action button
    public Static Boolean addTopSellingProducts(Id oppId) {

        try {
            
            Set<Id> productIds = new Set<Id>();

            List<TopProduct__c> oppTopProds;

            Map<Id, Decimal> prodUnitPrice = new Map<Id, Decimal>();

            Map<Id, OpportunityLineItem> existingOliMap = new Map<Id, OpportunityLineItem>();

            List<OpportunityLineItem> oliToUpsert = new List<OpportunityLineItem>();

            Opportunity opp = [SELECT Id, Account.Region__c, Pricebook2Id FROM Opportunity WHERE Id = :oppId];

            String[] regionValue = opp.Account.Region__c.split(';');

            //Query all TopProduct__c if Account region is ALL else query using Account Region
            if(regionValue.contains(Constants.REGION_ALL)){
                oppTopProds = [SELECT Id, Product__c 
                               FROM TopProduct__c ORDER BY TotalQuantitySold__c DESC];
            } else {
                oppTopProds = [SELECT Id, Product__c
                               FROM TopProduct__c 
                               WHERE Region__r.Name IN :regionValue OR Region__r.Name = :Constants.REGION_ALL 
                               ORDER BY TotalQuantitySold__c DESC];
            }
 
            if(!oppTopProds.isEmpty()){

                //Collect Product Ids
                for(TopProduct__c topProd : oppTopProds) {
                    if(!productIds.contains(topProd.Product__c)) {
                        productIds.add(topProd.Product__c);

                        //break out of the loop if set Size is 5
                        if(productIds.size() == 5) {
                            break;
                        }
                    }
                }

                //Map to get Unit Prices and add prices to map
                for(PricebookEntry pbe : [SELECT Product2Id, UnitPrice FROM PricebookEntry 
                                        WHERE Pricebook2Id =: opp.Pricebook2Id AND Product2Id IN : productIds]) {
                    prodUnitPrice.put(pbe.Product2Id, pbe.UnitPrice);
                }

                //Check for existing Opportunity Line Items from related Opportunity record and add in Map
                List<OpportunityLineItem> existingOpportunityLineItems = [SELECT Id, OpportunityId, Product2Id, Quantity, UnitPrice FROM OpportunityLineItem
                                                              WHERE OpportunityId =: opp.Id];
                
                
                for(OpportunityLineItem oli : existingOpportunityLineItems) {
                    existingOliMap.put(oli.Product2Id, oli);
                }

                for(Id productId : productIds) {

                    Decimal unitPrice = prodUnitPrice.get(productId);

                    if(unitPrice != null) { //Check to ensure that there's a unit price for the product
                        OpportunityLineItem oli;
                        //If Opportunity Line Item already exist then just add 1 more in quantity
                        if(existingOliMap.containsKey(productId)) {
                            oli = existingOliMap.get(productId);
                            oli.Quantity += 1;
                        } else {
                            //If there's no existing Opportunity Product then insert new records
                            oli = new OpportunityLineItem (
                                OpportunityId = opp.Id,
                                Product2Id = productId,
                                Quantity = 1,
                                UnitPrice = unitPrice
                            );
                        }
                        oliToUpsert.add(oli);
                    }    
                }
                //Upsert combined Opportunity Line items
                if(!oliToUpsert.isEmpty()){
                    upsert oliToUpsert;
                }
            }

            return true;

        } catch(Exception e) {
            System.debug('Error adding top best sellers: ' + e.getMessage());
            return false;
        } 
    }
}