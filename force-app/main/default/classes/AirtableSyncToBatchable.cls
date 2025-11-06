public with sharing class AirtableSyncToBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts {
  private Set<Id> productIds;
  public AirtableSyncToBatchable(Set<Id> productIds) {
    this.productIds = productIds;
  }

  public Iterable<SObject> start(Database.BatchableContext bc) {
    return [
      SELECT
        Id,
        Name,
        Reference_Id__c,
        Discipline__c,
        Category__c,
        Size__c,
        Color__c
      FROM Product2
      WHERE Id IN :productIds
    ];
  }

  public void execute(
    Database.BatchableContext bc,
    List<SObject> recordsToUpsert
  ) {
    AirtableApi.upsertAirtableProducts(recordsToUpsert);
  }

  public void finish(Database.BatchableContext bc) {
  }
}
