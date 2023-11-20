/*
    Author: Myron Salazar
*/

public with sharing class OpportunityService {
    
    public static void createOrderForClosedWonOpp(List<Opportunity> oppsFromTrigger) {
        //Map to group DeliveryDates and OpportunityLineItems
        Map<String, OpportunityLineItem> oppLineItemMap = new Map<String, OpportunityLineItem>();
        
        //List to create Order record for Closed Won Opportunity
        List<Order> closedWonOppOrder = new List<Order>();

        //Create map for newly created Order to use for creating OrderItem
        Map<String, Order> newOrderMap = new Map<String, Order>();

        //List to hold Opp Line items that needs to be created
        List<OrderItem> orderItemList = new List<OrderItem>();

        //Iterate over list of opportunity and put the ID in a Set to avoid any duplicates
        List<OpportunityLineItem> oppLineItemList = [SELECT Id, Product2Id, OpportunityId, Opportunity.AccountId, Quantity, UnitPrice, DeliveryDate__c, PricebookEntryId, PricebookEntry.PriceBook2Id
                                        FROM OpportunityLineItem WHERE OpportunityId IN :oppsFromTrigger];

        for(OpportunityLineItem oli : oppLineItemList){
            oppLineItemMap.put(oli.OpportunityId + ':' + oli.DeliveryDate__c, oli);
        }

        for(String key : oppLineItemMap.keySet()){
            Order newOrder = new Order (
                AccountId = oppLineItemMap.get(key).Opportunity.AccountId,
                OpportunityId = oppLineItemMap.get(key).OpportunityId,
                Status = Constants.STATUS_DRAFT,
                EffectiveDate = oppLineItemMap.get(key).DeliveryDate__c,
                Pricebook2Id = oppLineItemMap.get(key).PricebookEntry.PriceBook2Id
            );

            closedWonOppOrder.add(newOrder);
        }

        if(!closedWonOppOrder.isEmpty()){
            insert closedWonOppOrder;
        }

        //Query newly created Orders
        List<Order> newOrderList = [SELECT Id, OpportunityId, EffectiveDate FROM Order WHERE OpportunityId IN :oppsFromTrigger];

        for(Order ord : newOrderList) {
            newOrderMap.put(ord.OpportunityId + ':' + ord.EffectiveDate, ord);
        }

        for(OpportunityLineItem oli : oppLineItemList) {
            if(oli.DeliveryDate__c == newOrderMap.get(oli.OpportunityId + ':' + oli.DeliveryDate__c).EffectiveDate){
                OrderItem newOrderItem = new OrderItem(
                    OrderId = newOrderMap.get(oli.OpportunityId + ':' + oli.DeliveryDate__c).Id,
                    Product2Id = oli.Product2Id,
                    Quantity = oli.Quantity,
                    UnitPrice = oli.UnitPrice,
                    PricebookEntryId = oli.PricebookEntryId
                );
                orderItemList.add(newOrderItem);
            }
        }

        if(!orderItemList.isEmpty()){
            insert orderItemList;
        }
    }
}