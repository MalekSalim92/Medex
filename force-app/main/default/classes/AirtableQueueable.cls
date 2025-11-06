public with sharing class AirtableQueueable implements Queueable, Database.allowsCallouts {
  public List<Product2> productsToUpsert;
  public Integer startIndex;
  public AirtableQueueable(
    List<Product2> productsToUpsert,
    Integer startIndex
  ) {
    this.productsToUpsert = productsToUpsert;
    this.startIndex = startIndex;
  }
  public void execute(QueueableContext qc) {
    Integer endIndex = Math.min(
      startIndex + Constants.AIRTABLE_MAX_UPSERT_ALLOWED,
      productsToUpsert.size()
    );
    List<Product2> batch = new List<Product2>();
    for (Integer i = startIndex; i < endIndex; i++) {
      batch.add(productsToUpsert[i]);
    }
    ProductService.syncToAirtable(batch);
    if (endIndex < productsToUpsert.size()) {
      System.enqueueJob(new AirtableQueueable(productsToUpsert, endIndex));
    }
  }
}
