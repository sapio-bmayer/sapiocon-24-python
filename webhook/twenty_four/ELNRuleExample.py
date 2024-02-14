from sapiopylib.rest.WebhookService import AbstractWebhookHandler
from sapiopylib.rest.pojo.DataRecord import DataRecord
from sapiopylib.rest.pojo.webhook.VeloxRules import ElnEntryRecordResult
from sapiopylib.rest.pojo.webhook.WebhookContext import SapioWebhookContext
from sapiopylib.rest.pojo.webhook.WebhookResult import SapioWebhookResult
from sapiopylib.rest.utils.Protocols import ElnExperimentProtocol, ElnEntryStep

from webhook.data_type_models import PlateModel


class ELNRuleExample(AbstractWebhookHandler):
    def run(self, context: SapioWebhookContext) -> SapioWebhookResult:
        # ELN rules and on save rules have a rule result map that contains the data records references by the
        # rule and records the relationship between those records, if any.
        results_map: dict[str, list[ElnEntryRecordResult]] = context.velox_eln_rule_result_map

        # Parse the rule result map to get the plate records that are related to the samples entry.
        entry_results: list[ElnEntryRecordResult] = results_map.get("Samples")
        plate_records: set[DataRecord] = set()
        for record_result in entry_results:
            for result in record_result.rule_result_list:
                for record in result.data_records:
                    if record.data_type_name == PlateModel.DATA_TYPE_NAME:
                        plate_records.add(record)

        # Since this webhook was invoked from within an experiment, the experiment is already present in the context
        # as a protocol object. Once again get the entry that we want and add records to it.
        # noinspection PyTypeChecker
        protocol: ElnExperimentProtocol = context.active_protocol
        entries: dict[str, ElnEntryStep] = {x.get_name(): x for x in protocol.get_sorted_step_list()}
        plates_entry: ElnEntryStep = entries.get("Plates")
        plates_entry.add_records(list(plate_records))
        return SapioWebhookResult(True)
