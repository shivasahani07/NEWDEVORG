global class InstagramBatchForPosts implements Database.Batchable<SObject>,Database.AllowsCallouts {
    
    private static Instagram_Api_Details__c fap = Instagram_Api_Details__c.getInstance();
    
    private static final String CLIENT_ID        = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET          = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI           = fap.REDIRECT_URI__c; 
    private static String accessToken            = fap.accessToken__c;
    private static String basicUrl               = fap.basicUrl__c;
    private static String businessUserId         = fap.businessUserId__c;
    private static Id caseRecordTypeId           = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String query = 'Select id,subject,Description,Caption__c,Tweet_Id__c,(Select Comment__c,Comment_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case where recordTypeId = :caseRecordTypeId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext batchableContext, List<case> existingInstaCases) {
        system.debug('existingInstaCases-->'+existingInstaCases.size());
        integer numberOfexistingCases = existingInstaCases.size();
        List<case> existingCaseList = [Select id,subject,Description,Caption__c,Tweet_Id__c,(Select Comment__c,Comment_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case where recordTypeId = :caseRecordTypeId];
        
        List<Post_Comments__c> postCommentList                    = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentListToBeUpdated         = new List<Post_Comments__c>();
        map<String,List<Post_Comments__c>> commentsOnPostByPostId = new map<String,List<Post_Comments__c>>();
        map<String,String> caseIdByPostId                         = new map<String,String>();
        map<String,String> postCommentIdByPostId                  = new map<String,String>();
        List<String> casePostIds                                  = new List<String>();
        for(Case caseRec : existingCaseList){
            commentsOnPostByPostId.put(caseRec.Tweet_Id__c,caseRec.Post_Comments__r);
            caseIdByPostId.put(caseRec.Tweet_Id__c,caseRec.Id);
            for(Post_Comments__c pocRec : caseRec.Post_Comments__r){
                postCommentIdByPostId.put(pocRec.Comment_Id__c,pocRec.Id);
            }
        }
        system.debug('commentsOnPostByPostId'+commentsOnPostByPostId);
        String endpointUrl = 'https://graph.facebook.com/v17.0/'+businessUserId+'/media';
        String fieldsParam = 'fields=media_url,comments_count,permalink,caption,media_type,shortcode,timestamp,username,comments{id,like_count,user,media,timestamp,username,replies{text,username,timestamp},text}';
        Id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
        String fullUrl = endpointUrl + '?' + fieldsParam + '&access_token=' + accessToken;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(fullUrl);
        request.setMethod('GET');
       
        HttpResponse response = http.send(request);
        System.debug('response.getBody() === > '+response.getBody());
        FacebookApiResponse responseWrapper = (FacebookApiResponse) JSON.deserialize(response.getBody(), FacebookApiResponse.class);
        system.debug('responseWrapper'+responseWrapper);
        for(FacebookApiResponse.DataWrapper postInfo : responseWrapper.data){
            System.debug('postInfo === >'+postInfo);
            if(!commentsOnPostByPostId.keyset().contains(postInfo.Id)){
                Case newCase = new case();
                newCase.tweet_related_to__c = postInfo.username;
                newCase.Origin = 'Instagram';
                newCase.Tweet_Id__c = postInfo.id;
                newcase.Tweet_Created_Time__c = String.valueOf(postInfo.timestamp).removeEnd('+0000');
                newcase.Tweet_URL__c = postInfo.permalink;
                newcase.recordtypeId = caseRecordTypeId;
                if((postInfo.comments != null)){
                    newcase.Tweet_Comments__c = string.valueOf(postInfo.comments.data);
                }
                newcase.Priority = 'High';
                newcase.Type = 'Post Comment';
                newcase.Subject = 'Post from instagram.Related to '+postInfo.username+'. Created Date-Time : '+newcase.Tweet_Created_Time__c;
                newcase.Description = postInfo.caption;
                if(!commentsOnPostByPostId.keyset().contains(newCase.Tweet_Id__c)){
                    insert newcase;
                }
                System.debug('postInfo.comments  If == >'+postInfo.comments );
                if((postInfo.comments != null)){
                    if(newcase.Id != null){
                        for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                            Post_Comments__c commentRec = new Post_Comments__c();
                            commentRec.Case__c = newcase.Id;
                            commentRec.Comment__c = postInfoRec.text;
                            commentRec.Comment_Id__c = postInfoRec.Id;
                            commentRec.Commented_By__c = postInfoRec.username;
                            commentRec.Post_comment_Time__c = postInfoRec.timestamp;
                            commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                            commentRec.Post_Url__c	 = postInfo.permalink;
                            postCommentList.add(commentRec);
                        }      
                    }
                }
            }else{
                if(postInfo.comments != null){
                    for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                        if(commentsOnPostByPostId.containsKey(postInfo.Id)){
                            List<String> postCommentIds = new List<String>();
                            for(Post_Comments__c poCom :  commentsOnPostByPostId.get(postInfo.Id)){
                                postCommentIds.add(poCom.Comment_Id__c);
                            }
                            if(!postCommentIds.contains(postInfoRec.Id)){
                                Post_Comments__c commentRec = new Post_Comments__c();
                                commentRec.Case__c = caseIdByPostId.get(postInfo.Id);
                                commentRec.Comment__c = postInfoRec.text;
                                commentRec.Comment_Id__c = postInfoRec.Id;
                                commentRec.Commented_By__c = postInfoRec.username;
                                commentRec.Post_comment_Time__c = postInfoRec.timestamp;
                                commentRec.Post_Url__c	 = postInfo.permalink;
                                commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                                system.debug('replies are'+postInfoRec.replies);
                                postCommentList.add(commentRec);
                            }else{
                                system.debug('replies are'+postInfoRec.replies);
                                Post_Comments__c commentRec = new Post_Comments__c();
                                commentRec.Id = postCommentIdByPostId.get(postInfoRec.Id);
                                commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                                postCommentListToBeUpdated.add(commentRec);
                            }
                        }
                    }
                }else{
                    system.debug('postInfo.comments'+postInfo.comments);
                }
            }
        }
        system.debug('postCommentList'+postCommentList);
        system.debug('postCommentList'+postCommentList.size());
        insert postCommentList;
        update postCommentListToBeUpdated;
    }
    public void finish(Database.BatchableContext batchableContext) {
        InstagramBatchForMentions ib = new InstagramBatchForMentions();
        database.executeBatch(ib);
    }
}