public with sharing class AirtableWebhookService {
  public static void createWebhook() {
    HttpClient client = buildClient();
    String body = buildBody();
    System.debug(body);
    client.setHeader('Content-Type', 'application/json').post(body);
  }

  private static HttpClient buildClient() {
    MetadataSelector.AirtableConfig cfg = MetadataSelector.getAirtableBasePath();
    HttpClient client = new HttpClient(
      Constants.AIRTABLE_NAMED_CREDENTIAL,
      '/' + cfg.apiVersion + '/bases/' + cfg.url + '/webhooks'
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
}
