/*
    Author: Myron Salazar
*/

public class WeeklyOrderSummary implements Schedulable {

    @TestVisible static Integer scheduleJobCount = 0;

    public void execute(SchedulableContext ctx) {

        //Call batch class to send Order Summary to customers
        Id batchId = Database.executeBatch(new SendOrderSummaryEmailBatch());

        //Used for assertion in related Test class as Limit Email from the related classes doesn't show in the testclass
        scheduleJobCount++;

        System.debug('Job for the batch Id for sending Order Summary ::: ' + batchId);
    }
}