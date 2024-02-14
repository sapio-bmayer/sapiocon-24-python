from typing import Any

from sapiopylib.rest.DataMgmtService import DataMgmtServer
from sapiopylib.rest.WebhookService import AbstractWebhookHandler
from sapiopylib.rest.pojo.DataRecord import DataRecord
from sapiopylib.rest.pojo.webhook.WebhookContext import SapioWebhookContext
from sapiopylib.rest.pojo.webhook.WebhookResult import SapioWebhookResult
from sapiopylib.rest.utils.recordmodel.RecordModelManager import RecordModelManager

from webhook.data_type_models import SampleModel


class ScheduledRuleExample(AbstractWebhookHandler):
    def run(self, context: SapioWebhookContext) -> SapioWebhookResult:
        # Run a predefined search to get the record IDs of the unassigned samples.
        report_man = DataMgmtServer.get_custom_report_manager(context.user)
        report: list[list[Any]] = report_man.run_system_report_by_name("Unassigned Samples").result_table
        # If there are no results in the search then there's nothing to assign.
        if not report:
            return SapioWebhookResult(True)

        # Query the samples by their record IDs and wrap them as SampleModels for easier handling.
        rec_man = RecordModelManager(context.user)
        inst_man = rec_man.instance_manager
        sample_records: list[DataRecord] = context.data_record_manager\
            .query_data_records_by_id(SampleModel.DATA_TYPE_NAME, [x[0] for x in report]).result_list
        sample_models: list[SampleModel] = inst_man.add_existing_records_of_type(sample_records, SampleModel)

        # Assign half the samples to Jonathan and the other half to Brodi.
        half_way: int = len(sample_records) // 2
        first_half: list[SampleModel] = sample_models[:half_way]
        second_half: list[SampleModel] = sample_models[half_way:]
        for sample in first_half:
            sample.set_ExemplarSampleStatus_field("Ready for - Jonathan")
        for sample in second_half:
            sample.set_ExemplarSampleStatus_field("Ready for - Brodi")

        # Commit the changes made to the sample models.
        rec_man.store_and_commit()
        return SapioWebhookResult(True)
