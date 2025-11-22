public with sharing class AirtableWebhookEventTriggerHandler extends TriggerHandler {
  public override void afterInsert() {
    ProductService.updateProductsOnPlatformEvent(Trigger.new);
  }
}
