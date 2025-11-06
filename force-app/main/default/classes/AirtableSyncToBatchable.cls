public with sharing class AirtableSyncToBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts {
  public String query;
  public AirtableSyncToBatchable(String query) {
    this.query = query;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(query);
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
