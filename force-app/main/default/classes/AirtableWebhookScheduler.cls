public with sharing class AirtableWebhookScheduler implements Schedulable {
  public static void execute(SchedulableContext sc) {
    AirtableWebhookService.refreshWebhook();
  }
}
