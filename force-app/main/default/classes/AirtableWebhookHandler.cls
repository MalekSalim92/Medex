@RestResource(urlMapping='/api/airtable/*')
global without sharing class AirtableWebhookHandler {
  @HttpPost
  global static void handle() {
    String body = RestContext.request.requestBody.toString();
    System.debug('RestContext.request : ' + RestContext.request);
    System.debug('BODY FROM AIRTABLE : ' + body);
    System.debug('BODY FROM AIRTABLE : ' + body);
    String payload = AirtableWebhookService.getWebhookPayload();
    AirtableWebhookService.createPlatformEvent(payload);
  }
}
