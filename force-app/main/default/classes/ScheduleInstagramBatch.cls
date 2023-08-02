global class ScheduleInstagramBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
      InstagramBatchForPosts b = new InstagramBatchForPosts(); 
      Database.executeBatch(b);
   }
}