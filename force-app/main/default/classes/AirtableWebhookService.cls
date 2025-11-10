public with sharing class AirtableWebhookService {
  private static final String WEBHOOK_ID = AirtableSelector.getWebhookRecord()
    .webhookId__c;
  private static final MetadataSelector.AirtableConfig AIRTABLE_CONFIGS = MetadataSelector.getAirtableBasePath();
  private static final String AIRTABLE_BASEURL = AIRTABLE_CONFIGS.url;
  private static final String AIRTABLE_APIVERSION = AIRTABLE_CONFIGS.apiVersion;

  public static void hardRefreshWebhook() {
    if (String.isNotBlank(WEBHOOK_ID)) {
      deleteWebhook();
    }
    createWebhook();
  }
  public static void refreshWebhook() {
    HttpClient client = buildClient('/' + WEBHOOK_ID + '/refresh');
    HttpResponse response = client.post(null);
    updateWebhookRecord(response.getBody());
  }

  public static String getWebhookPayload(Decimal cursor) {
    HttpClient client = buildClient(
      '/' + WEBHOOK_ID + '/payloads?cursor=' + cursor
    );
    HttpResponse response = client.get();
    return response.getBody();
  }

  public static void createPlatformEvent(String payload) {
    Airtable_Webhook_Payload__e webhookEvent = new Airtable_Webhook_Payload__e(
      payload__c = payload
    );
    EventBus.publish(webhookEvent);
  }
  private static void createWebhook() {
    HttpClient client = buildClient(null);
    String body = buildBody();
    System.debug(body);
    HttpResponse response = client.setHeader('Content-Type', 'application/json')
      .post(body);
    updateWebhookRecord(response.getBody());
  }

  private static void deleteWebhook() {
    HttpClient client = buildClient('/' + WEBHOOK_ID);
    client.remove();
  }

  private static HttpClient buildClient(String pathSuffix) {
    MetadataSelector.AirtableConfig cfg = MetadataSelector.getAirtableBasePath();
    String endpoint =
      '/' +
      AIRTABLE_APIVERSION +
      '/bases/' +
      AIRTABLE_BASEURL +
      '/webhooks';
    if (String.isNotBlank(pathSuffix))
      endpoint += pathSuffix;
    HttpClient client = new HttpClient(
      Constants.AIRTABLE_NAMED_CREDENTIAL,
      endpoint
    );

    return client;
  }
  private static String buildBody() {
    Map<String, Object> filters = new Map<String, Object>{
      'dataTypes' => new List<String>{ 'tableData' }
    };
    Map<String, Object> options = new Map<String, Object>{
      'filters' => filters
    };
    Map<String, Object> specifications = new Map<String, Object>{
      'options' => options
    };
    Map<String, Object> obj = new Map<String, Object>{
      'notificationUrl' => MetadataSelector.getGuestSiteUrl() +
      '/services/apexrest/' +
      Constants.AIRTABLE_WEBHOOK_URL,
      'specification' => specifications
    };

    String body = JSON.serialize(obj);
    return body;
  }
  private static void updateWebhookRecord(String response) {
    Airtable_Webhook_Configuration__c record = AirtableSelector.getWebhookRecord();

    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );
    record.webhookId__c = (String) responseMap.get('id') ?? record.webhookId__c;
    String timeStamp = (String) responseMap.get('expirationTime');
    record.expirationTime__c = (Datetime) JSON.deserialize(
      '"' + timeStamp + '"',
      Datetime.class
    );

    update record;
  }
  public static void updateWebhookCursor(Integer cursor) {
    Airtable_Webhook_Configuration__c record = AirtableSelector.getWebhookRecord();
    record.Cursor__c = cursor;
    update record;
  }
}
