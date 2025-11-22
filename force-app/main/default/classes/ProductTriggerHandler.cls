public with sharing class ProductTriggerHandler extends TriggerHandler {
  private static String OPERATION_TYPE = String.valueOf(Trigger.operationType);
  public override void afterInsert() {
    AirtableService.syncToAirtable(Trigger.New, OPERATION_TYPE);
  }
  public override void afterUpdate() {
    System.debug(Trigger.isInsert);
    AirtableService.syncToAirtable(Trigger.New, OPERATION_TYPE);
  }
  public override void afterDelete() {
  }
}
