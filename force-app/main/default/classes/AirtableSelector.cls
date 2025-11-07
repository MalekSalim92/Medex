public with sharing class AirtableSelector {
  public static Airtable_Webhook_Configuration__c getWebhookRecord() {
    return [
      SELECT Id, webhookId__c
      FROM Airtable_Webhook_Configuration__c
      LIMIT 1
    ];
  }
}
