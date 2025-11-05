public with sharing class ProductService {
  public static void syncFromAirtable() {
    List<Product2> productsToUpsert = new List<Product2>();
    List<AirtableWrapper.Records> records = AirtableApi.getProducts();
    for (AirtableWrapper.Records record : records) {
      productsToUpsert.add(
        new Product2(
          Name = record.fields.Name,
          Reference_Id__c = record.fields.SKU,
          Discipline__c = record.fields.Discipline,
          Category__c = record.fields.Category,
          Size__c = record.fields.Size,
          Color__c = record.fields.Color
        )
      );
    }
    upsertProducts(productsToUpsert);
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
