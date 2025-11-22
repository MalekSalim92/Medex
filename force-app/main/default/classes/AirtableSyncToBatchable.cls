public with sharing class AirtableSyncToBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts {
  private Set<Id> productIds;
  private String operationType;
  public AirtableSyncToBatchable(Set<Id> productIds, String operationType) {
    this.productIds = productIds;
    this.operationType = operationType;
  }

  public Iterable<SObject> start(Database.BatchableContext bc) {
    return ProductSelector.productsByIds(productIds);
  }

  public void execute(
    Database.BatchableContext bc,
    List<SObject> recordsToUpsert
  ) {
    if (operationType.contains('INSERT'))
      AirtableApi.insertAirtableProducts(recordsToUpsert);
    else {
      AirtableApi.updateAirtableProducts(recordsToUpsert);
    }
  }

  public void finish(Database.BatchableContext bc) {
  }
}
