/*
    Author: Myron Salazar
*/

public class MaintainTopSellerSched implements Schedulable {

    @TestVisible static Integer scheduleBatchJobCount = 0;

    public void execute(SchedulableContext ctx) {

        //Call batch class to send Order Summary to customers
        Id batchId = Database.executeBatch(new MaintainTopBestSellersBatch());

        //Used for assertion in related Test class as Limit Email from the related classes doesn't show in the testclass
        scheduleBatchJobCount++;

        System.debug('Job for the batch Id for Maintaining Best Sellers ::: ' + batchId);
    }
}