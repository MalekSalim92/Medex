public with sharing class ProductService {
  public static String syncFromAirtable() {
    List<Product2> productsToUpsert = new List<Product2>();
    AirtableWrapper data = AirtableApi.getAirtableProducts();
    List<AirtableWrapper.records> records = data.records;
    for (AirtableWrapper.Records record : records) {
      productsToUpsert.add(
        new Product2(
          Name = record.fields.Name,
          Reference_Id__c = record.fields.Reference,
          Discipline__c = record.fields.Discipline,
          Category__c = record.fields.Category,
          Size__c = record.fields.Size,
          Color__c = record.fields.Color
        )
      );
    }
    upsertProducts(productsToUpsert);
    return data.offset ?? null;
  }

  public static void syncToAirtable() {
    String query = 'SELECT Id,Name,Reference_Id__c,Discipline__c,Category__c,Size__c,Color__c FROM Product2';
    AirtableSyncToBatchable batch = new AirtableSyncToBatchable(query);
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
