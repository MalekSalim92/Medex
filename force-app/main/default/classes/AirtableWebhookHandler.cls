@RestResource(urlMapping='/api/airtable/*')
global without sharing class AirtableWebhookHandler {
  @HttpPost
  global static void handle() {
    String body = RestContext.request.requestBody.toString();
    Decimal cursor = AirtableSelector.getWebhookRecord().Cursor__c;
    String payload = AirtableWebhookService.getWebhookPayload(cursor);
    AirtableWebhookService.createPlatformEvent(payload);
  }
}
