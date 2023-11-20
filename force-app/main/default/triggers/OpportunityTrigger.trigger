/*
    Apex Learning Session Final Assignment
    Author: Myron Salazar
*/

trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update, before delete) {

    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

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