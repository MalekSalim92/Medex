public with sharing class MetadataSelector {
  public static String getAirtableTableId(String tableName) {
    List<Airtable_Table__mdt> table = [
      SELECT DeveloperName, Table_Id__c
      FROM Airtable_Table__mdt
      WHERE DeveloperName = :tableName.toUpperCase()
      LIMIT 1
    ];
    if (table.isEmpty()) {
      throw new AirtableException('Table not found');
    }
    return table[0].Table_Id__c;
  }

  public static AirtableConfig getAirtableBasePath() {
    List<Airtable_Configuration__mdt> configs = [
      SELECT DeveloperName, Base_Path__c, api_version__c
      FROM Airtable_Configuration__mdt
      WHERE DeveloperName = 'Airtable_configs'
      LIMIT 1
    ];
    if (configs.isEmpty()) {
      throw new AirtableException('Path not found');
    }
    AirtableConfig configsWrapper = new AirtableConfig();
    configsWrapper.url = configs[0].Base_Path__c;
    configsWrapper.apiVersion = configs[0].api_version__c;
    return configsWrapper;
  }

  public static String getGuestSiteUrl() {
    List<Experience_Site_Setting__mdt> url = [
      SELECT url__c
      FROM Experience_Site_Setting__mdt
      WHERE DeveloperName = 'Guest_Site'
      LIMIT 1
    ];
    if (url.isEmpty()) {
      throw new AirtableException('Url not found');
    } else {
      return url[0].url__c;
    }
  }

  public class AirtableConfig {
    public String url;
    public String apiVersion;
  }
}
