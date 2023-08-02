@isTest
public class InstagramAuthHelperTest {
    static testmethod void testsample(){  
        Case caseRec = new Case();
        caseRec.Tweet_Id__c = 'tweetId';
        insert caserec;
        
        Post_Comments__c postComment = new Post_Comments__c();
        postComment.Case__c= caserec.Id;
        postComment.Comment_Id__c = 'commentId';
        postComment.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=123, text=Test Reply 1, username=testuser1, timeStamp=2023-07-29T12:34:56+0000,Case__c=caseId])])';
		insert postComment;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramAuthHelper.getAllPostsFromInstaForUserId();
        Test.stopTest();
    }
    
    
    static testmethod void getHashtagIdFromInsta_test(){  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramAuthHelper.getHashtagIdFromInsta('INSTA');
        Test.stopTest();
    }
    
    static testmethod void getPostDetailsByHashTagId_test(){  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramAuthHelper.getPostDetailsByHashTagId('INSTA');
        Test.stopTest();
    }
    
    static testmethod void getAllDetailsOfMedia_test(){  
        Case caseRec = new Case();
        caseRec.Tweet_Id__c = 'tweetId';
        insert caserec;
        
        Post_Comments__c postComment = new Post_Comments__c();
        postComment.Case__c= caserec.Id;
        postComment.Comment_Id__c = 'commentId';
		insert postComment;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramAuthHelper.getAllDetailsOfMedia('INSTA');
        Test.stopTest();
    }
    
     static testmethod void testsamplelast(){  
        Case caseRec = new Case();
        caseRec.Tweet_Id__c = 'tweetId';
        insert caserec;
        
        Post_Comments__c postComment = new Post_Comments__c();
        postComment.Case__c= caserec.Id;
        postComment.Comment_Id__c = 'commentId';
        postComment.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=123, text=Test Reply 1, username=testuser1, timeStamp=2023-07-29T12:34:56+0000,Case__c=caseId])])';
		insert postComment;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramAuthHelper.getAllPostsFromInstaForUserIdDummy();
        Test.stopTest();
    }
    
    
    static testmethod void getAllDetailsOfComments_test(){  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramAuthHelper.getAllDetailsOfComments('INSTA');
        Test.stopTest();
    }
}