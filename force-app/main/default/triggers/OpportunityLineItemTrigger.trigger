/*
    Apex Learning Session Final Assignment
    Author: Myron Salazar
*/

trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after insert, after update, before delete) {

    OpportunityLineItemTriggerHandler handler = new OpportunityLineItemTriggerHandler();

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            handler.beforeInsert(trigger.New);
        } else {
            handler.afterInsert(trigger.New);
        }
    } else if (Trigger.isUpdate){
        if(Trigger.isBefore){
            handler.beforeUpdate(trigger.New);
        } else {
            handler.afterUpdate(trigger.New);
        }
    }
}