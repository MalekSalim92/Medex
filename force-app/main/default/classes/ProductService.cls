public with sharing class ProductService {
  private static final String PRODUCT_HANDLER_NAME = 'ProductTriggerHandler';
  public static String syncFromAirtable(String offset) {
    List<Product2> productsToUpsert = new List<Product2>();
    AirtableWrapper data = AirtableApi.getAirtableProducts(offset);
    List<AirtableWrapper.records> records = data.records;
    for (AirtableWrapper.Records record : records) {
      productsToUpsert.add(
        new Product2(
          Name = record.fields.Name,
          Reference_Id__c = record.fields.Reference,
          Discipline__c = record.fields.Discipline,
          Category__c = record.fields.Category,
          Size__c = record.fields.Size,
          Color__c = record.fields.Color,
          IsActive = true
        )
      );
    }
    TriggerHandler.bypass(PRODUCT_HANDLER_NAME);
    upsertProducts(productsToUpsert);
    TriggerHandler.clearBypass(PRODUCT_HANDLER_NAME);
    return data.offset ?? '';
  }

  public static void syncToAirtable(List<Product2> productsToSync) {
    Set<Id> productIds = new Map<Id, Product2>(productsToSync).keySet();
    AirtableSyncToBatchable batch = new AirtableSyncToBatchable(productIds);
    Database.executeBatch(batch, Constants.AIRTABLE_MAX_UPSERT_ALLOWED);
  }

  private static void upsertProducts(List<Product2> productsToUpsert) {
    boolean allowPartialSuccess = false;
    List<Database.UpsertResult> results = Database.upsert(
      productsToUpsert,
      Product2.Reference_Id__c,
      !allowPartialSuccess
    );

    for (Database.UpsertResult result : results) {
      if (!result.isSuccess()) {
        for (Database.Error error : result.getErrors()) {
          System.debug(
            'Upsert failed : ' +
              error.getMessage() +
              'Fields : ' +
              error.getFields()
          );
        }
      }
    }
  }
}
