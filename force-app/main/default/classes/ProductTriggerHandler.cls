public with sharing class ProductTriggerHandler extends TriggerHandler {
  public override void afterInsert() {
    AirtableService.syncToAirtable(Trigger.New);
  }
  public override void afterUpdate() {
    AirtableService.syncToAirtable(Trigger.New);
  }
  public override void afterDelete() {
  }
}
