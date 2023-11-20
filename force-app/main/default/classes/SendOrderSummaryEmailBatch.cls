/*
    Author: Myron Salazar
*/

public with sharing class SendOrderSummaryEmailBatch implements Database.Batchable<sObject>, Database.stateful {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, PrimaryContact__c, PrimaryContact__r.FirstName, PrimaryContact__r.Email, ' + 
        '(SELECT Id, AccountId FROM Orders WHERE CreatedDate >= LAST_WEEK) ' + 
        'FROM Account WHERE Id IN (SELECT AccountId FROM Order)';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

        Map<Id, Decimal> amountMap = new Map<Id, Decimal>();

        //Map for adding total amount per account order
        for(Order ord : [SELECT Id, AccountId, TotalAmount FROM Order WHERE AccountId IN :scope]) {
            if(!amountMap.containsKey(ord.AccountId)){
                amountMap.put(ord.AccountId, ord.TotalAmount);
            } else {
                amountMap.put(ord.AccountId, amountMap.get(ord.AccountId) + ord.TotalAmount);
            }
        }

        for(Account acc : scope) {
            if(acc.PrimaryContact__c != null && acc.PrimaryContact__r.Email != null && amountMap.containsKey(acc.Id)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                //Adding Primary Contact's email add
                List<String> sendTo = new List<String>();
                sendTo.add(acc.PrimaryContact__r.Email);
                mail.setToAddresses(sendTo);

                //Set email contents
                mail.setSenderDisplayName(Constants.RCP_NAME);
                mail.setSubject(acc.Name + ' order summary from last week.');
                String body = 'Hi ' + acc.PrimaryContact__r.FirstName + ', ';
                body += 'Here is your last week\'s order summary for ' + acc.Name + ': ';
                body += 'In total you have ' + acc.Orders.size() + ' orders, with a total amount of $' + amountMap.get(acc.Id) + '. ';
                body += 'Hope you have a great week.';
                mail.setHtmlBody(body);

                mailsToSend.add(mail);
            }
        }

        try {
            Messaging.sendEmail(mailsToSend); //MessageResult class for best practice
            //To use for assertion for the related test class
        } catch (Exception e) {
            System.debug('Error during batch email ::: ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Order Email Summary Sent ::: ' + Limits.getEmailInvocations());
    }
}