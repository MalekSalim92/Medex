trigger AirtableWebhookPayloadEventTrigger on Airtable_Webhook_Payload__e(
  after insert
) {
  new AirtableWebhookEventTriggerHandler().run();
}
