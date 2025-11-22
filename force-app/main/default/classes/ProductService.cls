public with sharing class ProductService {
  private static final String PRODUCT_HANDLER_NAME = 'ProductTriggerHandler';

  public static void updateProductsOnPlatformEvent(
    List<Airtable_Webhook_Payload__e> triggerObject
  ) {
    List<Product2> productsToUpsert = new List<Product2>();
    Integer cursor;
    for (Airtable_Webhook_Payload__e payloadRecord : triggerObject) {
      cursor = parseAirtableWebhookCursor(payloadRecord.payload__c);
      Map<String, Map<String, Object>> parsedPayload = parseAirtableWebhookPayloadToProduct(
        payloadRecord.payload__c
      );
      List<Product2> productToUpsert = buildProductToUpsert(parsedPayload);

      productsToUpsert.addAll(productToUpsert);
    }
    if (cursor != null) {
      AirtableWebhookService.updateWebhookCursor(cursor);
    }
    if (!productsToUpsert.isEmpty()) {
      TriggerHandler.bypass(PRODUCT_HANDLER_NAME);
      upsertProducts(productsToUpsert);
      TriggerHandler.clearBypass(PRODUCT_HANDLER_NAME);
    }
  }

  public static void upsertProductOnBatchCallout(AirtableWrapper data) {
    List<Product2> productsToUpsert = makeProductList(data);
    TriggerHandler.bypass(PRODUCT_HANDLER_NAME);
    upsertProducts(productsToUpsert);
    TriggerHandler.clearBypass(PRODUCT_HANDLER_NAME);
  }

  private static Integer parseAirtableWebhookCursor(String body) {
    Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    return (Integer) payload.get('cursor');
  }

  private static Map<String, Map<String, Object>> parseAirtableWebhookPayloadToProduct(
    String body
  ) {
    Map<String, String> fieldMapping = MetadataSelector.getAirtableFieldsMappingById();
    Map<String, Map<String, Object>> recordsToUpsert = new Map<String, Map<String, Object>>();
    Map<String, Object> mappedFields = new Map<String, Object>();

    Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    List<Object> payloads = (List<Object>) payload.get('payloads');
    for (Object payloadObj : payloads) {
      Map<String, Object> payloadMap = (Map<String, Object>) payloadObj;
      Map<String, Object> changedTables = (Map<String, Object>) payloadMap.get(
        'changedTablesById'
      );

      for (String tableId : changedTables.keySet()) {
        Map<String, Object> changedTable = (Map<String, Object>) changedTables.get(
          tableId
        );
        Map<String, Object> changedRecords = (Map<String, Object>) changedTable.get(
          'changedRecordsById'
        );

        for (String recordId : changedRecords.keySet()) {
          Map<String, Object> recordWrapper = (Map<String, Object>) changedRecords.get(
            recordId
          );
          Map<String, Object> currentRecord = (Map<String, Object>) recordWrapper.get(
            'current'
          );
          if (currentRecord == null)
            continue;

          Map<String, Object> cellValues = (Map<String, Object>) currentRecord.get(
            'cellValuesByFieldId'
          );
          if (cellValues == null)
            continue;

          for (String fieldId : cellValues.keySet()) {
            if (fieldMapping.containsKey(fieldId)) {
              String sfField = fieldMapping.get(fieldId);
              Object value = cellValues.get(fieldId);

              // If the value is a nested map with a 'name', take the name
              if (value instanceof Map<String, Object>) {
                Map<String, Object> valueMap = (Map<String, Object>) value;
                if (valueMap.containsKey('name')) {
                  value = valueMap.get('name');
                }
              }

              mappedFields.put(sfField, value);
            }
          }

          if (!mappedFields.isEmpty()) {
            recordsToUpsert.put(recordId, mappedFields);
          }
        }
      }
    }

    return recordsToUpsert;
  }

  private static List<Product2> buildProductToUpsert(
    Map<String, Map<String, Object>> parsedPayload
  ) {
    Map<String, Product2> productToAirtableId = new Map<String, Product2>();
    List<Product2> productsToUpsert = new List<Product2>();
    List<String> salesforceFieldNames = MetadataSelector.getAirtableFieldsMappingById()
      .values();
    for (Product2 prod : ProductSelector.products()) {
      productToAirtableId.put(prod.Airtable_Id__c, prod);
    }
    for (String airtableId : parsedPayload.keySet()) {
      Product2 prod;
      if (productToAirtableId.containsKey(airtableId)) {
        prod = productToAirtableId.get(airtableId);
      } else {
        prod = new Product2();
        prod.Airtable_Id__c = airtableId;
      }
      Map<String, Object> fields = parsedPayload.get(airtableId);

      for (String fieldName : salesforceFieldNames) {
        if (fields.containsKey(fieldName)) {
          prod.put(fieldName, fields.get(fieldName));
        }
      }

      productsToUpsert.add(prod);
    }

    return productsToUpsert;
  }
  private static void upsertProducts(List<Product2> productsToUpsert) {
    boolean allowPartialSuccess = false;
    List<Database.UpsertResult> results = Database.upsert(
      productsToUpsert,
      Product2.Airtable_Id__c,
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
          Airtable_Id__c = record.id,
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
