/*
    Author: Myron Salazar
*/

public with sharing class MaintainTopBestSellersBatch implements Database.Batchable<sObject>, Database.stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Query Opportunity Product that are part of Closed Won Opportunity then change the order from highest Quantity sold to lowest
        String query = 'SELECT Id, Name, Opportunity.Account.Name, Opportunity.AccountId, Product2Id, Product2.Name, Product2.Region__c, Quantity ' + 
                       'FROM OpportunityLineItem WHERE Opportunity.StageName = \'Closed Won\' AND Opportunity.CloseDate >= LAST_N_DAYS:730 ' +
                       'ORDER BY Quantity DESC';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<OpportunityLineItem> scope) {
        //Map to hold region(key), Product2Id(key) and Total QuantitySold(value)
        Map<String, Map<Id, Integer>> regionTopProdMap = new Map<String, Map<Id, Integer>>();

        List<TopProduct__c> topProducts = new List<TopProduct__c>();
        
        //Sort Opportunity Products according to region
        for(OpportunityLineItem oli : scope) {
            String[] regions = oli.Product2.Region__c.split(';');
            for(String region : regions) {
                if(!regionTopProdMap.containsKey(region)) {
                    regionTopProdMap.put(region, new Map<Id, Integer>());
                }
                if(!regionTopProdMap.get(region).containsKey(oli.Product2Id)) {
                    regionTopProdMap.get(region).put(oli.Product2Id, Integer.valueOf(oli.Quantity));
                } else {
                    Integer currentQuantity = regionTopProdMap.get(region).get(oli.Product2Id);
                    regionTopProdMap.get(region).put(oli.Product2Id, currentQuantity + Integer.valueOf(oli.Quantity));
                }
            }
        }

        // Query the TopProduct__c records and delete to create new top Sellers
        List<TopProduct__c> topProdToDelete = [SELECT Id FROM TopProduct__c WHERE Region__r.Name IN :regionTopProdMap.keySet()];

        if(!topProdToDelete.isEmpty()){
            delete topProdToDelete;
        }

        for(Region__c region : [SELECT Id, Name FROM Region__c WHERE Region__c.Name IN :regionTopProdMap.keySet()]) {
            if(regionTopProdMap.containsKey(region.Name)) {
                Map<Id, Integer> prodQuantityMap = regionTopProdMap.get(region.Name);

                //To hold already created Product Ids and avoid duplicates
                Set<Id> processedProducts = new Set<Id>();

                //Add values of Map to a list for sorting
                List<Integer> sortedValues = new list<Integer>(prodQuantityMap.values());
                sortedValues.sort();

                //Create top 5 per region only taking the top 5 if the list is more than 5
                for(Integer i = sortedValues.size() - 1; i >= Math.max(sortedValues.size() - 5, 0); i--) {
                    //Total Quantity Sold
                    Integer quantity = sortedValues[i];

                    //Find product Ids associated with Quantity and add to a List
                    Set<Id> productIds = new Set<Id>();
                    for(Id id : prodQuantityMap.keySet()){
                        if(prodQuantityMap.get(id) == quantity) {
                            productIds.add(id);
                        }
                    }

                    //Create Top Product records based of Product Id
                    for(Id prodId : productIds) {
                        if(!processedProducts.contains(prodId)){
                            TopProduct__c topProd = new TopProduct__c(
                                Name = region.Name + ' best Seller',
                                Region__c = region.Id,
                                Product__c = prodId,
                                TotalQuantitySold__c = quantity
                            );
                            topProducts.add(topProd);
                            //Add the processed product to the Set
                            processedProducts.add(prodId);
                        }                
                    }
                }
            }
        }

        if(!topProducts.isEmpty()){
            insert topProducts;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Schedule/Batch job to Maintain Top Sellers per region done.');
    }
}