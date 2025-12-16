/**
 * Created by malek on 2025-12-16.
 */

public with sharing class CustomMetadataUpdater {
    public static void updateMetadata() {


        Metadata.CustomMetadata cmd = new Metadata.CustomMetadata();
        cmd.fullName = 'Airtable_Configuration__mdt.Airtable_configs';
        cmd.label = 'Airtable Configs';

        Metadata.CustomMetadataValue val = new Metadata.CustomMetadataValue();
        val.field = 'api_version__c';
        val.value = 'newVersion';

        cmd.values = new List<Metadata.CustomMetadataValue>{val};

        Metadata.DeployContainer container = new Metadata.DeployContainer();
        container.addMetadata(cmd);

        Id jobId = Metadata.Operations.enqueueDeployment(container, null);
        System.debug('Job Id: ' + jobId);
    }
}