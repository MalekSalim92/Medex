public with sharing class AirtableService {
  public static String syncFromAirtable(String offset) {
    AirtableWrapper data = AirtableApi.getAirtableProducts(offset);
    ProductService.handleUpsert(data);
    return data.offset;
  }

  public static void syncToAirtable(List<Product2> productsToSync) {
    Set<Id> productIds = new Map<Id, Product2>(productsToSync).keySet();
    AirtableSyncToBatchable batch = new AirtableSyncToBatchable(productIds);
    Database.executeBatch(batch, Constants.AIRTABLE_MAX_UPSERT_ALLOWED);
  }
}
