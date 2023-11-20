/*
    Apex Learning Session Final Assignment
    Author: Myron Salazar
*/

public with sharing class OpportunityTriggerHandler {

    public void beforeInsert(List<Opportunity> newOpp){
        system.debug('Opportunity Trigger on before insert');
    }

    public void afterInsert(List<Opportunity> newOpp){
        system.debug('Opportunity Trigger on after insert ');
    }

    public void beforeUpdate(List<Opportunity> updatedOpp){
        system.debug('Opportunity Trigger on before update');
    }
    
    public void afterUpdate(List<Opportunity> updatedOpp) {
        system.debug('Opportunity Trigger on after update');
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity opp : updatedOpp){
            if(opp.StageName == Constants.OPP_CLOSED_WON){
                oppList.add(opp);
            }
        }
        //Only create orders when there's closed won opportunity
        if(!oppList.isEmpty()){
            OpportunityService.createOrderForClosedWonOpp(updatedOpp);
        }
    }
}