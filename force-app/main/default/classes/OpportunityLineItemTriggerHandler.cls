/*
    Apex Learning Session Final Assignment
    Author: Myron Salazar
*/

public with sharing class OpportunityLineItemTriggerHandler {

    public void beforeInsert(List<OpportunityLineItem> newOppLineItem){
        system.debug('OpportunityLineItem Trigger on before insert');

        OpportunityLineItemService.checkOppProdRegion(newOppLineItem);
    }

    public void afterInsert(List<OpportunityLineItem> newOppLineItem){
        system.debug('OpportunityLineItem Trigger on after insert ');
    }

    public void beforeUpdate(List<OpportunityLineItem> updatedOppLineItem){
        system.debug('OpportunityLineItem Trigger on before update');
    }
    
    public void afterUpdate(List<OpportunityLineItem> updatedOppLineItem) {
        system.debug('OpportunityLineItem Trigger on after update');
    }
}