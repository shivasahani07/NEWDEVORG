global class InstagramBatchForHashTags implements Database.Batchable<SObject>,Database.AllowsCallouts {
    
    private static Instagram_Api_Details__c fap = Instagram_Api_Details__c.getInstance();
    
    private static final String CLIENT_ID        = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET          = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI           = fap.REDIRECT_URI__c;
    private static String accessToken            = fap.accessToken__c;
    private static String basicUrl               = fap.basicUrl__c;
    private static String businessUserId         = fap.businessUserId__c;
    private static String hashTagName            = fap.HashTag__c;
    private static Id caseRecordTypeId           = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String query = 'Select id,subject,Description,Caption__c,Tweet_Id__c,(Select Comment__c,Comment_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case where recordTypeId = :caseRecordTypeId';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext batchableContext, List<case> existingInstaCases) {
        system.debug('existingInstaCases-->'+existingInstaCases.size());
        integer numberOfexistingCases = existingInstaCases.size();
        List<case> existingCaseList = [Select id,subject,Description,Caption__c,Tweet_Id__c,(Select Comment__c,Comment_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case where recordTypeId = :caseRecordTypeId];
        
        List<Case> caseList = new List<Case>();
        String hashTagId = InstagramAuthHelper.getHashtagIdFromInsta(hashTagName);
        system.debug('hashTagId'+hashTagId);
        
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
        String endpointUrl = basicUrl+hashTagId+'/recent_media?fields=media_url,media_type,caption,permalink,timestamp&user_id='+businessUserId;
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
        system.debug('Response==>'+response.getBody());
        
        if (response.getStatusCode() == 200) {
            instaJSONHandler jsonResponse = instaJSONHandler.parse(response.getBody());
            for(instaJSONHandler.cls_data postInfo : jsonResponse.data){
                if(!commentsOnPostByPostId.keyset().contains(postInfo.Id)){
                    Case newCase = new case();
                    newCase.tweet_related_to__c = postInfo.username;
                    newCase.Origin = 'Instagram';
                    newCase.Tweet_Id__c = postInfo.id;
                    newcase.Tweet_Created_Time__c = String.valueOf(postInfo.timestamp).removeEnd('+0000');
                    newcase.Tweet_URL__c = postInfo.permalink;
                    newcase.Tweet_Comments__c = string.valueOf(postInfo.repliesOnPost);
                    newcase.Priority = 'High';
                    newcase.Type = 'Hash Tags(#)';
                    newcase.RecordTypeId = caseRecordTypeId;
                    newcase.Subject = 'Hash Tag Post from instagram.Related to #'+hashtagName+'. Created Date-Time : '+newcase.Tweet_Created_Time__c;
                    newcase.Description = postInfo.caption;
                    newcase.HashTag__c = hashtagName;
                    newcase.Tweet_Comment_Id__c = hashTagId;
                    if(!commentsOnPostByPostId.keyset().contains(newCase.Tweet_Id__c)){
                        caseList.add(newCase);
                    }
                }else{
                      System.debug('Duplicate Post');
                }
            }
            if(caseList.size() > 0){
                insert caseList;    
            }
        } else {
            String errorMessage = 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            System.debug(errorMessage);
        }
        
    }
    public void finish(Database.BatchableContext batchableContext) {
        // Perform any cleanup or post-processing if required
    }
}