@isTest
public class InstagramBatchForPostsTest {
    
    static testMethod void testme(){
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        insert testCase;
        
        // Create a test Post_Comments__c record associated with the Case
        Post_Comments__c commentRecord = new Post_Comments__c();
        commentRecord.Comment_Id__c = 'TestCommentId';
        commentRecord.Comment__c = 'Test Comment';
        commentRecord.Post_Url__c = 'https://www.example.com/test-post-url';
        commentRecord.Post_comment_Time__c =string.valueof(Datetime.now());
        commentRecord.Case__c = testCase.Id;
        insert commentRecord; 
        
        Test.setMock(HttpCalloutMock.class, new BatchSyncMock());
        InstagramBatchForPosts bs = new InstagramBatchForPosts();
        
        Test.startTest();
        database.executeBatch(bs,200);
        Test.stopTest();
        
        
    }
    
    static testMethod void testme1(){
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        testCase.Tweet_Id__c = 'asdfghj';
        insert testCase;
        
        // Create a test Post_Comments__c record associated with the Case
        Post_Comments__c commentRecord = new Post_Comments__c();
        commentRecord.Comment_Id__c = 'TestCommentId';
        commentRecord.Comment__c = 'Test Comment';
        commentRecord.Post_Url__c = 'https://www.example.com/test-post-url';
        commentRecord.Post_comment_Time__c =string.valueof(Datetime.now());
        commentRecord.Case__c = testCase.Id;
        insert commentRecord; 
        
        Case caseRec = new Case();
        caseRec.Tweet_Id__c = 'tweetId';
        insert caserec;
        
        Post_Comments__c postComment = new Post_Comments__c();
        postComment.Case__c= caserec.Id;
        postComment.Comment_Id__c = 'commentId';
        postComment.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=123, text=Test Reply 1, username=testuser1, timeStamp=2023-07-29T12:34:56+0000,Case__c=caseId])])';
		insert postComment;

        
        Test.setMock(HttpCalloutMock.class, new BatchSyncMock());
        
        InstagramBatchForPosts bs = new InstagramBatchForPosts();
        InstagramBatchForMentions bs1 = new InstagramBatchForMentions();
          InstagramBatchForHashTags bs2 = new InstagramBatchForHashTags();
        
        Test.startTest();
        database.executeBatch(bs,200);
        database.executeBatch(bs1,200);
        database.executeBatch(bs2,200);
        Test.stopTest();
        
    }
}