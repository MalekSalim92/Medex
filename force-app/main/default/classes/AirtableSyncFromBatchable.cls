public with sharing class AirtableSyncFromBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
  public String query;
  public AirtableSyncFromBatchable(String query) {
    this.query = query;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(query);
  }

  public void execute(
    Database.BatchableContext bc,
    List<SObject> recordsToGet
  ) {
    String offset = ProductService.syncFromAirtable();
    if (offset != null) {
      Database.executeBatch(new AirtableSyncFromBatchable(''));
    }
  }

  public void finish(Database.BatchableContext bc) {
  }
}
