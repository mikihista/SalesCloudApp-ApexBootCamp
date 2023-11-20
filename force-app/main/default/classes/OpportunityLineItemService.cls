/*
    Author: Myron Salazar
*/

public with sharing class OpportunityLineItemService {
    
    public static void checkOppProdRegion(List<OpportunityLineItem> oliFromTrigger) {

        //Prepare maps for Opp and Prod
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, Product2> prodMap = new Map<Id, Product2>();

        //List to hold Account and Product regions
        List<String> accRegions = new List<String>();
        List<String> prodRegions = new List<String>();

        //List to hold common regions between Account and Product
        Set<String> commonRegions = new Set<String>();

        //Add keyset to Map
        for(OpportunityLineItem oli : oliFromTrigger){
            oppMap.put(oli.OpportunityId, null);
            prodMap.put(oli.Product2Id, null);
        }

        //Add field values to Map
        oppMap.putAll([SELECT Id, Account.Name, Account.Region__c FROM Opportunity WHERE Id IN :oppMap.keySet()]);
        prodMap.putAll([SELECT Id, Region__c FROM Product2 WHERE Id IN :prodMap.keySet()]);

        for(OpportunityLineItem oli : oliFromTrigger){
            //Initialise lists outside for loop - H comment
            accRegions = oppMap.get(oli.OpportunityId).Account.Region__c.split(';');
            prodRegions = prodMap.get(oli.Product2Id).Region__c.split(';');
            
            //Check if regions is All then continue
            if((accRegions.contains(Constants.REGION_ALL) || prodRegions.contains(Constants.REGION_ALL))) {
                continue;
                
            } else {

                //Check to see if there are any common regions shared between 2 list
                commonRegions.addAll(accRegions);
                commonRegions.retainAll(prodRegions);

                //Send error if Set is empty
                if(commonRegions.isEmpty()) {
                    oli.addError('Product you are trying to add is not available in ' + oppMap.get(oli.OpportunityId).Account.Name + '\'s region.');
                }
            }
        }
    }
}