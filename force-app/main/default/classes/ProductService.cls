public with sharing class ProductService {
  private static final String PRODUCT_HANDLER_NAME = 'ProductTriggerHandler';
  public static void handleUpsert(AirtableWrapper data) {
    List<Product2> productsToUpsert = makeProductList(data);
    TriggerHandler.bypass(PRODUCT_HANDLER_NAME);
    upsertProducts(productsToUpsert);
    TriggerHandler.clearBypass(PRODUCT_HANDLER_NAME);
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

  private static List<Product2> makeProductList(AirtableWrapper data) {
    List<Product2> productsToUpsert = new List<Product2>();
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
    return productsToUpsert;
  }
}
