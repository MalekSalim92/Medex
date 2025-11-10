public with sharing class AirtableWebhookEventTriggerHandler extends TriggerHandler {
  public override void afterInsert() {
    System.debug('Trigger ::::: ' + Trigger.new);
    ProductService.updateProductsOnPlatformEvent(Trigger.new);
  }
}
