public with sharing class AirtableSyncFromBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
  private String offset = '';
  public AirtableSyncFromBatchable() {
  }
  public AirtableSyncFromBatchable(String offset) {
    this.offset = offset;
  }

  public Iterable<Sobject> start(Database.BatchableContext bc) {
    Account dummy = new Account(Name = 'dummy');
    return new List<Account>{ dummy };
  }

  public void execute(
    Database.BatchableContext bc,
    List<SObject> recordsToGet
  ) {
    offset = AirtableService.syncFromAirtable(offset);
  }

  public void finish(Database.BatchableContext bc) {
    if (!String.isBlank(offset)) {
      Database.executeBatch((new AirtableSyncFromBatchable(offset)), 1);
    } else {
      System.debug('BATCH PROCESS FINISHED');
    }
  }
}
