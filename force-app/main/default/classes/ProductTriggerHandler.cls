public with sharing class ProductTriggerHandler extends TriggerHandler {
  public override void afterInsert() {
    ProductService.syncToAirtable(Trigger.New);
  }
  public override void afterUpdate() {
    ProductService.syncToAirtable(Trigger.New);
  }
  public override void afterDelete() {
  }
}
